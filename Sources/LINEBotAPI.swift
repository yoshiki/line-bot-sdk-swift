import HMACHash
import JSON
import Environment

public enum LINEBotAPIError: ErrorType {
    case ChannelInfoNotFound
}

public struct LINEBotAPI {
    let client: APIClient

    init() throws {
        let env = Environment()
        guard let channelId = env.getVar("LINE_CHANNEL_ID"),
            channelSecret = env.getVar("LINE_CHANNEL_SECRET"),
            channelMid = env.getVar("LINE_BOT_MID") else {
            throw LINEBotAPIError.ChannelInfoNotFound
        }

        let baseUri = "https://trialbot-api.line.me"
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

    public func sendImage(to mid: String..., imageUrl: String, previewUrl: String) throws {
        try send(to: mid, content: JSON.from([
            "toType": JSON.from(ToType.ToUser.rawValue),
            "contentType": JSON.from(ContentType.Image.rawValue),
            "originalContentUrl": JSON.from(imageUrl),
            "previewImageUrl": JSON.from(previewUrl),
        ]))
    }

    public func sendVideo(to mid: String..., videoUrl: String, previewUrl: String) throws {
        try send(to: mid, content: JSON.from([
            "toType": JSON.from(ToType.ToUser.rawValue),
            "contentType": JSON.from(ContentType.Video.rawValue),
            "originalContentUrl": JSON.from(videoUrl),
            "previewImageUrl": JSON.from(previewUrl),
        ]))
    }

    public func sendAudio(to mid: String..., audioUrl: String, duration: Int) throws {
        let metaData = JSON.from([ "AUDLEN": "\(duration)" ])
        try send(to: mid, content: JSON.from([
            "toType": JSON.from(ToType.ToUser.rawValue),
            "contentType": JSON.from(ContentType.Audio.rawValue),
            "originalContentUrl": JSON.from(audioUrl),
            "contentMetadata": metaData,
        ]))
    }

    public func sendLocation(to mid: String..., text: String, address: String, latitude: String, longitude: String) throws {
        let location = JSON.from([
            "title": JSON.from(address),
            "latitude": JSON.from(latitude),
            "longitude": JSON.from(longitude),
        ])
        try send(to: mid, content: JSON.from([
            "toType": JSON.from(ToType.ToUser.rawValue),
            "contentType": JSON.from(ContentType.Location.rawValue),
            "text": JSON.from(text),
            "location": location,
        ]))
    }

    public func sendSticker(to mid: String..., stkId: String, stkPkgId: String, stkVer: String) throws {
        let metaData = JSON.from([
            "STKID": JSON.from(stkId),
            "STKPKGID": JSON.from(stkPkgId),
            "STKVER": JSON.from(stkVer),
        ])
        try send(to: mid, content: JSON.from([
            "toType": JSON.from(ToType.ToUser.rawValue),
            "contentType": JSON.from(ContentType.Sticker.rawValue),
            "contentMetadata": metaData,
        ]))
    }

    public func validateSignature(json: String, channelSecret: String, signature: String) -> Bool {
        let calced = HMACHash().hmac(.SHA256, key: channelSecret, data: json)
        return (calced.hexString() == signature)
    }
}
