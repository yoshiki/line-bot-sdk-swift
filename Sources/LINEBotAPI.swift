import JSON
import OpenSSL
import Base64
import HTTP

public enum LINEBotAPIError: Error {
    case ChannelInfoNotFound
    case ContentNotFound
}

public class LINEBotAPI {
    private typealias ContentHandler = (C7.JSON) throws -> Void
    
    internal let client: Client
    private let headers: Headers
    
    public let channelSecret: String
    
    public var failureResponse: Response = Response(status: .forbidden)

    public init() throws {
        guard let channelSecret = Env.getVar(name: "CHANNEL_SECRET"),
            let accessToken = Env.getVar(name: "ACCESS_TOKEN") else {
            throw LINEBotAPIError.ChannelInfoNotFound
        }
        self.headers = [
            ("Content-Type", "application/json; charset=utf-8"),
            ("Authorization", "Bearer \(accessToken)")
        ]
        self.channelSecret = channelSecret
        self.client = Client(headers: headers)
    }

    public func validateSignature(message: String, channelSecret: String, signature: String) throws -> Bool {
        let hashed = Hash.hmac(.sha256, key: Data(channelSecret), message: Data(message))
        let base64 = Base64.encode(Data(hashed))
        return (base64 == signature)
    }
    
    public func parseRequest(_ request: Request, handler: ContentHandler) throws -> Response {
        var body: String = ""
        if case .buffer(let data) = request.body {
            body = String(describing: data)
        } else {
            return failureResponse
        }

        // validate signature
        guard let signature = request.headers["X-LINE-ChannelSignature"] else {
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
}

extension LINEBotAPI {
    internal func send(to userId: String, messages: C7.JSON) throws {
        let to = userId.asJSON
        let json = JSON.infer([ "to": to, "messages": messages ])
        try client.post(uri: "https://api.line.me/v2/bot/message/push", json: json)
    }

    public func sendText(to userId: String, text: String) throws {
        let builder = MessageBuilder()
        builder.addText(text: text)
        if let messages = try builder.build() {
            try send(to: userId, messages: messages)
        }
    }

    public func sendImage(to userId: String, imageUrl: String, previewUrl: String) throws {
        let builder = MessageBuilder()
        builder.addImage(imageUrl: imageUrl, previewUrl: previewUrl)
        if let messages = try builder.build() {
            try send(to: userId, messages: messages)
        }
    }

    public func sendVideo(to userId: String, videoUrl: String, previewUrl: String) throws {
        let builder = MessageBuilder()
        builder.addVideo(videoUrl: videoUrl, previewUrl: previewUrl)
        if let messages = try builder.build() {
            try send(to: userId, messages: messages)
        }
    }

    public func sendAudio(to userId: String, audioUrl: String, duration: Int) throws {
        let builder = MessageBuilder()
        builder.addAudio(audioUrl: audioUrl, duration: duration)
        if let messages = try builder.build() {
            try send(to: userId, messages: messages)
        }
    }

    public func sendLocation(to userId: String, title: String, address: String, latitude: String, longitude: String) throws {
        let builder = MessageBuilder()
        builder.addLocation(title: title, address: address, latitude: latitude, longitude: longitude)
        if let messages = try builder.build() {
            try send(to: userId, messages: messages)
        }
    }

    public func sendSticker(to userId: String, stickerId: String, packageId: String) throws {
        let builder = MessageBuilder()
        builder.addSticker(stickerId: stickerId, packageId: packageId)
        if let messages = try builder.build() {
            try send(to: userId, messages: messages)
        }
    }
}

extension LINEBotAPI {
    public typealias MessageBuild = (MessageBuilder) -> Void
    public func sendMultipleMessage(to userId: String, construct: MessageBuild) throws {
        let builder = MessageBuilder()
        construct(builder)

        guard let messages = try builder.build(),
            let arr = messages.arrayValue, arr.count > 0 else {
            throw BuilderError.ContentsNotFound
        }
        
        let newMessages = JSON.infer([
            "messageNotified": JSON.infer(0),
            "messages": messages,
        ])
        try send(to: userId, messages: newMessages)
    }
}

extension LINEBotAPI {
    public typealias RichMessageBuild = (RichMessageBuilder) -> Void
    public func sendRichMessage(to userId: String, imageUrl: String, height: Int = 1040, altText: String, construct: RichMessageBuild) throws {
        let builder = try RichMessageBuilder(height: height)
        construct(builder)
        
        guard let markupJSON = try builder.build() else {
            throw BuilderError.ContentsNotFound
        }
        
        var contentMetadata = JSON.infer([:])
        contentMetadata["SPEC_REV"] = JSON.infer("1") // Fixed 1
        contentMetadata["DOWNLOAD_URL"] = JSON.infer(imageUrl)
        contentMetadata["ALT_TEXT"] = JSON.infer(altText)
        contentMetadata["MARKUP_JSON"] = JSON.infer(markupJSON.description)
        let content = JSON.infer([
//            "contentType": JSON.infer(ContentType.Rich.rawValue),
            "contentMetadata": contentMetadata,
        ])
        try send(to: userId, messages: content)
    }
}
