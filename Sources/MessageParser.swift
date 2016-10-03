import JSON

public struct MessageParser {
    public static func parse(_ json: JSON) throws -> Content? {
        let contentType = json.get(path: "type")
            .flatMap { $0.stringValue }
            .flatMap { EventType(rawValue: $0) }
        if let contentType = contentType {
            switch contentType {
            case .Text:
                return TextMessage(json: json)
            case .Image:
                return ImageMessage(json: json)
            case .Video:
                return VideoMessage(json: json)
            case .Audio:
                return AudioMessage(json: json)
            case .Location:
                return LocationMessage(json: json)
            case .Sticker:
                return StickerMessage(json: json)
            default:
                return nil
            }
        } else {
            return nil
        }
    }
}

