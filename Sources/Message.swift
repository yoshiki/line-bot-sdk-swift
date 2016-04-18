import JSON
import Data

public enum ContentType: Int {
    case Text     = 1
    case Image    = 2
    case Video    = 3
    case Audio    = 4
    case Location = 7
    case Sticker  = 8
    case Contact  = 10
}

public protocol MessageType {
    var json: JSON { get }
    init(json: JSON)
}

extension MessageType {
    public var contentId: String? {
        return self["result.content.id"].flatMap { $0.string }
    }

    public var contentType: ContentType? {
        return self["result.content.contentType"].flatMap { $0.int }
          .flatMap { ContentType(rawValue: $0) }
    }

    public var createTime: String? {
        return self["result.content.createdTime"].flatMap { $0.string }
    }

    public var fromMid: String? {
        return self["result.content.from"].flatMap { $0.string }
    }

    public subscript(path: String) -> JSON? {
        return json.get(path: path)
    }
}

public class Message: MessageType {
    public var json: JSON
    public required init(json: JSON) {
        self.json = json
    }

    public static func initFromJSON(json jsonString: String) throws -> MessageType? {
        let json = try JSONParser().parse(Data(jsonString))
        let contentType = json.get(path: "result.content.contentType")
                          .flatMap { $0.int }
                          .flatMap { ContentType(rawValue: $0) }
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
            case .Contact:
                return ContactMessage(json: json)
            }
        } else {
            return nil
        }
    }
}

public class TextMessage: Message {
    public var text: String? {
        return json.get(path: "result.content.text").flatMap{ $0.string }
    }
}

public class ImageMessage: Message {}

public class VideoMessage: Message {}

public class AudioMessage: Message {}

public class LocationMessage: Message {
    var title: String? {
        return json.get(path: "result.content.location.title").flatMap{ $0.string }
    }
    var address: String? {
        return json.get(path: "result.content.location.address").flatMap{ $0.string }
    }
    var latitude: String? {
        return json.get(path: "result.content.location.latitude").flatMap{ $0.string }
    }
    var longitude: String? {
        return json.get(path: "result.content.location.longitude").flatMap{ $0.string }
    }
}

public class StickerMessage: Message {
    var stkPkgId: String? {
        return json.get(path: "result.content.contentMetadata.STKPKGID").flatMap{ $0.string }
    }
    var stkId: String? {
        return json.get(path: "result.content.contentMetadata.STKID").flatMap{ $0.string }
    }
    var stkVer: String? {
        return json.get(path: "result.content.contentMetadata.STKVER").flatMap{ $0.string }
    }
    var stkTxt: String? {
        return json.get(path: "result.content.contentMetadata.STKTXT").flatMap{ $0.string }
    }
}

public class ContactMessage: Message {
    var mid: String? {
        return json.get(path: "result.content.contentMetadata.mid").flatMap{ $0.string }
    }
    var displayName: String? {
        return json.get(path: "result.content.contentMetadata.displayName").flatMap{ $0.string }
    }
}
