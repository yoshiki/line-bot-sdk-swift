import JSON
import OpenSSL
import Base64
import S4

public enum LINEBotAPIError: ErrorProtocol {
    case ChannelInfoNotFound
    case ContentNotFound
}

public typealias ContentHandler = (JSON) throws -> Void

public class LINEBotAPI {
    private let client: APIClient
    private let headers: Headers
    
    public let channelId: String
    public let channelSecret: String
    public let channelMid: String
    
    public var failureResponse: Response = Response(status: .forbidden)

    public init() throws {
        guard let channelId = Env.getVar(name: "LINE_CHANNEL_ID"),
            channelSecret = Env.getVar(name: "LINE_CHANNEL_SECRET"),
            channelMid = Env.getVar(name: "LINE_BOT_MID") else {
            throw LINEBotAPIError.ChannelInfoNotFound
        }
        self.headers = [
            ("Content-Type", "application/json; charset=utf-8"),
            ("X-Line-ChannelID", channelId),
            ("X-Line-ChannelSecret", channelSecret),
            ("X-Line-Trusted-User-With-ACL", channelMid),
        ]
        self.channelId = channelId
        self.channelSecret = channelSecret
        self.channelMid = channelMid
        self.client = APIClient(headers: headers)
    }

    public func validateSignature(message: String, channelSecret: String, signature: String) throws -> Bool {
        let hashed = Hash.hmac(.SHA256, key: Data(channelSecret), message: Data(message))
        let base64 = try Base64.encode(hashed)
        return (base64 == signature)
    }
    
    public func parseRequest(_ request: Request, handler: ContentHandler) throws -> Response {
        var body: String = ""
        if case .buffer(let data) = request.body {
            body = String(data)
        } else {
            return failureResponse
        }

        // validate signature
        guard let signature = request.headers["X-LINE-ChannelSignature"].first else {
            return Response(status: .forbidden)
        }
        
        let isValid = try validateSignature(
            message: body,
            channelSecret: channelSecret,
            signature: signature
        )

        if isValid {
            let json = try JSONParser().parse(data: Data(body))
            if let result = json.get(path: "result") {
                let contents = try result.asArray()
                for content in contents {
                    try handler(content)
                }
                return Response(status: .ok)
            }
        }
        return failureResponse
    }

    private func send(to mid: [String], eventType: EventType = .SendingMessage, content: JSON) throws {
        let to = JSON.from(mid.map(JSON.from))
        var newContent = content
        if case .SendingMessage = eventType {
            newContent["toType"] = JSON.from(ToType.ToUser.rawValue)
        }
        let json = JSON.from([
            "to": to,
            "toChannel": JSON.from(BotAPISendingChannelId),
            "eventType": JSON.from(eventType.rawValue),
            "content": newContent,
        ])
        try client.post(uri: "https://trialbot-api.line.me/v1/events", json: json)
    }

    public func sendText(to mid: String..., text: String) throws {
        let builder = MessageBuilder()
        builder.addText(text: text)
        if let content = try builder.build() {
            try send(to: mid, content: content)
        }
    }

    public func sendImage(to mid: String..., imageUrl: String, previewUrl: String) throws {
        let builder = MessageBuilder()
        builder.addImage(imageUrl: imageUrl, previewUrl: previewUrl)
        if let content = try builder.build() {
            try send(to: mid, content: content)
        }
    }

    public func sendVideo(to mid: String..., videoUrl: String, previewUrl: String) throws {
        let builder = MessageBuilder()
        builder.addVideo(videoUrl: videoUrl, previewUrl: previewUrl)
        if let content = try builder.build() {
            try send(to: mid, content: content)
        }
    }

    public func sendAudio(to mid: String..., audioUrl: String, duration: Int) throws {
        let builder = MessageBuilder()
        builder.addAudio(audioUrl: audioUrl, duration: duration)
        if let content = try builder.build() {
            try send(to: mid, content: content)
        }
    }

    public func sendLocation(to mid: String..., text: String, address: String, latitude: String, longitude: String) throws {
        let builder = MessageBuilder()
        builder.addLocation(text: text, address: address, latitude: latitude, longitude: longitude)
        if let content = try builder.build() {
            try send(to: mid, content: content)
        }
    }

    public func sendSticker(to mid: String..., stkId: String, stkPkgId: String, stkVer: String) throws {
        let builder = MessageBuilder()
        builder.addSticker(stkId: stkId, stkPkgId: stkPkgId, stkVer: stkVer)
        if let content = try builder.build() {
            try send(to: mid, content: content)
        }
    }
}

extension LINEBotAPI {
    public typealias MessageBuild = MessageBuilder -> Void
    public func sendMultipleMessage(to mid: String..., construct: MessageBuild) throws {
        let builder = MessageBuilder()
        construct(builder)

        guard let contents = try builder.build(), arr = contents.array where arr.count > 0 else {
            throw BuilderError.ContentsNotFound
        }
        
        let content = JSON.from([
            "messageNotified": JSON.from(0),
            "messages": contents,
        ])
        try send(to: mid, eventType: .SendingMultipleMessage, content: content)
    }
}

extension LINEBotAPI {
    public typealias RichMessageBuild = RichMessageBuilder -> Void
    public func sendRichMessage(to mid: String..., imageUrl: String, height: Int = 1040, altText: String, construct: RichMessageBuild) throws {
        let builder = try RichMessageBuilder(height: height)
        construct(builder)
        
        guard let markupJSON = try builder.build() else {
            throw BuilderError.ContentsNotFound
        }
        
        var contentMetadata = JSON.from([:])
        contentMetadata["SPEC_REV"] = JSON.from("1") // Fixed 1
        contentMetadata["DOWNLOAD_URL"] = JSON.from(imageUrl)
        contentMetadata["ALT_TEXT"] = JSON.from(altText)
        contentMetadata["MARKUP_JSON"] = JSON.from(markupJSON.description)
        let content = JSON.from([
            "contentType": JSON.from(ContentType.Rich.rawValue),
            "contentMetadata": contentMetadata,
        ])
        try send(to: mid, eventType: .SendingMessage, content: content)
    }
}
