import JSON
import OpenSSL
import Base64

public enum LINEBotAPIError: ErrorProtocol {
    case ChannelInfoNotFound
    case ContentNotFound
}

public class LINEBotAPI {
    private let client: APIClient
    private let headers: Headers
    
    public let channelId: String
    public let channelSecret: String
    public let channelMid: String

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

    public func validateSignature(json: String, channelSecret: String, signature: String) throws -> Bool {
        let hashed = Hash.hmac(.SHA256, key: Data(channelSecret), message: Data(json))
        let base64 = try Base64.encode(hashed)
        return (base64 == signature)
    }

    public func parseMessage(json: JSON) throws -> MessageType? {
        return try Message.initFromJSON(json: json)
    }

    private func send(to mid: [String], content: JSON) throws {
        let to = JSON.from(mid.map(JSON.from))
        var newContent = content
        newContent["toType"] = JSON.from(ToType.ToUser.rawValue)
        let json = JSON.from([
            "to": to,
            "toChannel": JSON.from(BotAPISendingChannelId),
            "eventType": JSON.from(EventType.SendingMessage.rawValue),
            "content": newContent,
        ])
        try client.post(uri: "https://trialbot-api.line.me/v1/events", json: json)
    }

    public func sendText(to mid: String..., text: String) throws {
        let builder = MessageBuilder()
        builder.addText(text: text)
        if let content = builder.content {
            try send(to: mid, content: content)
        }
    }

    public func sendImage(to mid: String..., imageUrl: String, previewUrl: String) throws {
        let builder = MessageBuilder()
        builder.addImage(imageUrl: imageUrl, previewUrl: previewUrl)
        if let content = builder.content {
            try send(to: mid, content: content)
        }
    }

    public func sendVideo(to mid: String..., videoUrl: String, previewUrl: String) throws {
        let builder = MessageBuilder()
        builder.addVideo(videoUrl: videoUrl, previewUrl: previewUrl)
        if let content = builder.content {
            try send(to: mid, content: content)
        }
    }

    public func sendAudio(to mid: String..., audioUrl: String, duration: Int) throws {
        let builder = MessageBuilder()
        builder.addAudio(audioUrl: audioUrl, duration: duration)
        if let content = builder.content {
            try send(to: mid, content: content)
        }
    }

    public func sendLocation(to mid: String..., text: String, address: String, latitude: String, longitude: String) throws {
        let builder = MessageBuilder()
        builder.addLocation(text: text, address: address, latitude: latitude, longitude: longitude)
        if let content = builder.content {
            try send(to: mid, content: content)
        }
    }

    public func sendSticker(to mid: String..., stkId: String, stkPkgId: String, stkVer: String) throws {
        let builder = MessageBuilder()
        builder.addSticker(stkId: stkId, stkPkgId: stkPkgId, stkVer: stkVer)
        if let content = builder.content {
            try send(to: mid, content: content)
        }
    }
}

extension LINEBotAPI {
    public func send(to mid: [String], contents: [JSON]) throws {
        guard contents.count != 0 else {
            throw LINEBotAPIError.ContentNotFound
        }
        let to = JSON.from(mid.map(JSON.from))
        let content = JSON.from([
            "messageNotified": JSON.from(0),
            "messages": JSON.from(contents),
        ])
        let json = JSON.from([
            "to": to,
            "toChannel": JSON.from(BotAPISendingChannelId),
            "eventType": JSON.from(EventType.SendingMultipleMessage.rawValue),
            "content": content,
        ])
        try client.post(uri: "https://trialbot-api.line.me/v1/events", json: json)
    }

    public func sendMultipleMessage(to mid: String..., f: MessageBuilderType) throws {
        let builder = MessageBuilder()
        f(builder)
        try send(to: mid, contents: builder.contents)
    }
}
