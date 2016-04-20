import HMACHash
import JSON
import Environment

public enum LINEBotAPIError: ErrorType {
    case ChannelInfoNotFound
    case ContentNotFound
}

public class LINEBotAPI {
    private let client: APIClient
    private var contents = [JSON]()

    public init() throws {
        let env = Environment()
        guard let channelId = env.getVar("LINE_CHANNEL_ID"),
            channelSecret = env.getVar("LINE_CHANNEL_SECRET"),
            channelMid = env.getVar("LINE_BOT_MID") else {
            throw LINEBotAPIError.ChannelInfoNotFound
        }

        let baseUri = "https://trialbot-api.line.me/"
        let channelInfo = [
            "ChannelId": channelId,
            "ChannelSecret": channelSecret,
            "ChannelMid": channelMid,
        ]
        self.client = APIClient(baseUri: baseUri, channelInfo: channelInfo)
    }

    public func parseMessage(json: String) throws -> MessageType? {
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
        try client.post("/v1/events", json: json)
    }

    public func sendText(to mid: String..., text: String) throws {
        let content = MessageBuilder().build(text: text)
        try send(to: mid, content: content)
    }

    public func sendImage(to mid: String..., imageUrl: String, previewUrl: String) throws {
        let content = MessageBuilder().build(imageUrl: imageUrl, previewUrl: previewUrl)
        try send(to: mid, content: content)
    }

    public func sendVideo(to mid: String..., videoUrl: String, previewUrl: String) throws {
        let content = MessageBuilder().build(videoUrl: videoUrl, previewUrl: previewUrl)
        try send(to: mid, content: content)
    }

    public func sendAudio(to mid: String..., audioUrl: String, duration: Int) throws {
        let content = MessageBuilder().build(audioUrl: audioUrl, duration: duration)
        try send(to: mid, content: content)
    }

    public func sendLocation(to mid: String..., text: String, address: String, latitude: String, longitude: String) throws {
        let content = MessageBuilder().build(text: text, address: address, latitude: latitude, longitude: longitude)
        try send(to: mid, content: content)
    }

    public func sendSticker(to mid: String..., stkId: String, stkPkgId: String, stkVer: String) throws {
        let content = MessageBuilder().build(stkId: stkId, stkPkgId: stkPkgId, stkVer: stkVer)
        try send(to: mid, content: content)
    }
}

extension LINEBotAPI {
    public func send(to mid: String...) throws {
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
        try client.post("/v1/events", json: json)
    }

    public func sendMultipleMessage() -> Self {
        contents.removeAll() // reset
        return self
    }

    public func addText(text text: String) -> Self {
        contents.append(MessageBuilder().build(text: text))
        return self
    }

    public func addImage(imageUrl: String, previewUrl: String) -> Self {
        contents.append(MessageBuilder().build(imageUrl: imageUrl, previewUrl: previewUrl))
        return self
    }

    public func addVideo(videoUrl videoUrl: String, previewUrl: String) -> Self {
        contents.append(MessageBuilder().build(videoUrl: videoUrl, previewUrl: previewUrl))
        return self
    }

    public func addAudio(audioUrl audioUrl: String, duration: Int) -> Self {
        contents.append(MessageBuilder().build(audioUrl: audioUrl, duration: duration))
        return self
    }

    public func addLocation(text text: String, address: String, latitude: String, longitude: String) -> Self {
        contents.append(MessageBuilder().build(text: text, address: address, latitude: latitude, longitude: longitude))
        return self
    }

    public func addSticker(stkId stkId: String, stkPkgId: String, stkVer: String) -> Self {
        contents.append(MessageBuilder().build(stkId: stkId, stkPkgId: stkPkgId, stkVer: stkVer))
        return self
    }

    public func validateSignature(json: String, channelSecret: String, signature: String) -> Bool {
        let calced = HMACHash().hmac(.SHA256, key: channelSecret, data: json)
        return (calced.hexString() == signature)
    }
}
