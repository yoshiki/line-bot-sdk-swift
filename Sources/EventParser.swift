import JSON

public struct EventParser {
    private static func parseMessage(_ json: JSON) -> Event? {
        if let message = json["message"]?.objectValue,
            let type = message["type"]?.stringValue,
            let messageType = MessageType(rawValue: type) {
            switch messageType {
            case .text:
                return TextMessage(json: json)
            case .image:
                return ImageMessage(json: json)
            case .video:
                return VideoMessage(json: json)
            case .audio:
                return AudioMessage(json: json)
            case .location:
                return LocationMessage(json: json)
            case .sticker:
                return StickerMessage(json: json)
            default:
                return nil
            }
        } else {
            return nil
        }
    }
    
    public static func parse(_ json: JSON) -> Event? {
        let eventType = json["type"]
            .flatMap { $0.stringValue }
            .flatMap { EventType(rawValue: $0) }
        if let eventType = eventType {
            switch eventType {
            case .message:
                return parseMessage(json)
            case .follow:
                return FollowEvent(json: json)
            case .unfollow:
                return UnfollowEvent(json: json)
            case .join:
                return JoinEvent(json: json)
            case .leave:
                return LeaveEvent(json: json)
            case .postback:
                return PostbackEvent(json: json)
            case .beacon:
                return BeaconEvent(json: json)
            }
        } else {
            return nil
        }
    }
}

