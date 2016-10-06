import JSON
import OpenSSL
import Base64
import HTTP

public enum LINEBotAPIError: Error {
    case channelInfoNotFound
    case cventNotFound
}

public class LINEBotAPI {
    private typealias EventHandler = (Event) throws -> Void
    
    internal let client: Client
    private let headers: Headers
    
    public let channelSecret: String
    
    public var failureResponse: Response = Response(status: .forbidden)

    public init() throws {
        guard let channelSecret = Env.getVar(name: "CHANNEL_SECRET"),
            let accessToken = Env.getVar(name: "ACCESS_TOKEN") else {
            throw LINEBotAPIError.channelInfoNotFound
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
    
    public func parseRequest(_ request: Request, handler: EventHandler) throws -> Response {
        var body: String = ""
        if case .buffer(let data) = request.body {
            body = try String(data: data)
        } else {
            return failureResponse
        }

        // validate signature
        guard let signature = request.headers["X-Line-Signature"] else {
            return Response(status: .forbidden)
        }
        
        let isValidSignature = try validateSignature(
            message: body,
            channelSecret: channelSecret,
            signature: signature
        )

        if isValidSignature {
            let json = try JSONParser().parse(data: Data(body))
            if let events = json["events"]?.arrayValue {
                try events.forEach {
                    try EventParser.parse($0).flatMap(handler)
                }
                return Response(status: .ok)
            }
        }
        return failureResponse
    }
}

extension LINEBotAPI {
    public func replyMessage(replyToken: String, messages: C7.JSON) throws {
        let json = JSON.infer([ "replyToken": replyToken.asJSON, "messages": messages ])
        try client.post(uri: URLHelper.replyMessageURL(), json: json)
    }
}

extension LINEBotAPI {
    public func pushMessage(to userId: String, messages: C7.JSON) throws {
        let json = JSON.infer([ "to": userId.asJSON, "messages": messages ])
        try client.post(uri: URLHelper.pushMessageURL(), json: json)
    }

    public func sendText(to userId: String, text: String) throws {
        let builder = MessageBuilder()
        builder.addText(text: text)
        if let messages = try builder.build() {
            try pushMessage(to: userId, messages: messages)
        }
    }

    public func sendImage(to userId: String, imageUrl: String, previewUrl: String) throws {
        let builder = MessageBuilder()
        builder.addImage(imageUrl: imageUrl, previewUrl: previewUrl)
        if let messages = try builder.build() {
            try pushMessage(to: userId, messages: messages)
        }
    }

    public func sendVideo(to userId: String, videoUrl: String, previewUrl: String) throws {
        let builder = MessageBuilder()
        builder.addVideo(videoUrl: videoUrl, previewUrl: previewUrl)
        if let messages = try builder.build() {
            try pushMessage(to: userId, messages: messages)
        }
    }

    public func sendAudio(to userId: String, audioUrl: String, duration: Int) throws {
        let builder = MessageBuilder()
        builder.addAudio(audioUrl: audioUrl, duration: duration)
        if let messages = try builder.build() {
            try pushMessage(to: userId, messages: messages)
        }
    }

    public func sendLocation(to userId: String, title: String, address: String, latitude: String, longitude: String) throws {
        let builder = MessageBuilder()
        builder.addLocation(title: title, address: address, latitude: latitude, longitude: longitude)
        if let messages = try builder.build() {
            try pushMessage(to: userId, messages: messages)
        }
    }

    public func sendSticker(to userId: String, stickerId: String, packageId: String) throws {
        let builder = MessageBuilder()
        builder.addSticker(stickerId: stickerId, packageId: packageId)
        if let messages = try builder.build() {
            try pushMessage(to: userId, messages: messages)
        }
    }

    public func sendImagemap(to userId: String,
                             imagemapBuilder: ImagemapBuilder) throws {
        let builder = MessageBuilder()
        builder.addImagemap(imagemapBuilder: imagemapBuilder)
        if let messages = try builder.build() {
            try pushMessage(to: userId, messages: messages)
        }
    }
    
    public func sendTemplate(to userId: String, altText: String, templateBuilder: TemplateBuilder) throws {
        let builder = MessageBuilder()
        try builder.addTemplate(altText: altText, templateBuilder: templateBuilder)
        if let messages = try builder.build() {
            try pushMessage(to: userId, messages: messages)
        }
    }
}
