import HMACHash
import JSON
import HTTPSClient

public struct LINEBotAPI {
    let channelId: String
    let channelSecret: String
    let channelMid: String
    let client = APIClient(baseUri: "https://trialbot-api.line.me/")

    public init(channelId: String, channelSecret: String, channelMid: String) {
        self.channelId = channelId
        self.channelSecret = channelSecret
        self.channelMid = channelMid
    }

    public func parseMessage(json: String) throws -> MessageType? {
        return try Message.initFromJSON(json: json)
    }

    private func send(to mid: [String], content: JSON) throws {
        let to = JSON.from(mid.map(JSON.from))
        let json = JSON.from([
            "to": to,
            "toChannel": JSON.from(BotAPISendingChannelId),
            "eventType": JSON.from(EventType.SendingMessage.rawValue),
            "content": content,
        ])
        try client.post("/v1/events", json: json)
    }

    public func sendText(to mid: String..., text: String) throws {
        try send(to: mid, content: JSON.from([
            "toType": JSON.from(ToType.ToUser.rawValue),
            "contentType": JSON.from(ContentType.Text.rawValue),
            "text": JSON.from(text),
        ]))
    }

    public func sendImage(to mid: String..., imageUrl: String, previewUrl: String) {
    }

    public func sendVideo(to mid: String..., videoUrl: String, previewUrl: String) {
    }

    public func sendAudio(to mid: String..., audioUrl: String, duration: Int) {
    }

    public func sendLocation(to mid: String..., text: String, address: String, latitude: String, longitude: String) {
    }

    public func sendSticker(to mid: String..., stkId: String, stkPkgId: String, stkVer: String) {
    }

    public func validateSignature(json: String, channelSecret: String, signature: String) -> Bool {
        let calced = HMACHash().hmac(.SHA256, key: channelSecret, data: json)
        return (calced.hexString() == signature)
    }
}
