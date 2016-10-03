import JSON

public enum EventType: String {
    case Text     = "text"
    case Image    = "image"
    case Video    = "video"
    case Audio    = "audio"
    case Location = "location"
    case Sticker  = "sticker"
    case Imagemap = "imagemap"
    case Follow   = "follow"
    case Unfollow = "unfollow"
    case Join     = "join"
    case Leave    = "leave"
    case Postback = "postback"
    case Beacon   = "beacon"
    
    var asJSON: JSON {
        return JSON.infer(rawValue)
    }
}

public enum SourceType: String {
    case User  = "user"
    case Group = "group"
    case Room  = "room"
}

public struct Source {
    public let type: SourceType
    public let id: String
}

public struct Message {
    public let id: String
    public let type: EventType
    public let text: String
}

public protocol Event: Content {}

extension Event {
    public var type: EventType? {
        return self["type"]
            .flatMap { $0.stringValue }
            .flatMap { EventType(rawValue: $0) }
    }
    
    public var replyToken: String? {
        return self["replyToken"].flatMap { $0.stringValue }
    }
    
    public var timestamp: String? {
        return self["timestamp"].flatMap { $0.stringValue }
    }
    
    public var source: Source? {
        return self["source"]
            .flatMap { $0.objectValue }
            .flatMap { (s) -> Source? in
                if let type = s["type"]?.stringValue,
                    let id = s["id"]?.stringValue {
                    return Source(type: SourceType(rawValue: type)!, id: id)
                }
                return nil
            }
    }
}

public struct TextMessage: Event {
    public var json: JSON
    
    public init(json: JSON) {
        self.json = json
    }
    
    public var message: Message? {
        return self["message"]
            .flatMap { $0.objectValue }
            .flatMap { (m) -> Message? in
                if let id = m["id"]?.stringValue,
                    let type = m["type"]?.stringValue,
                    let text = m["text"]?.stringValue {
                    return Message(id: id, type: EventType(rawValue: type)!, text: text)
                }
                return nil
            }
    }
}

public struct ImageMessage: Event {
    public var json: JSON

    public init(json: JSON) {
        self.json = json
    }
}

public struct VideoMessage: Event {
    public var json: JSON
    
    public init(json: JSON) {
        self.json = json
    }
}

public struct AudioMessage: Event {
    public var json: JSON
    
    public init(json: JSON) {
        self.json = json
    }
}

public struct LocationMessage: Event {
    public var json: JSON
    
    public init(json: JSON) {
        self.json = json
    }
    
    var title: String? {
        return json.get(path: "content.location.title").flatMap{ $0.stringValue }
    }
    var address: String? {
        return json.get(path: "content.location.address").flatMap{ $0.stringValue }
    }
    var latitude: String? {
        return json.get(path: "content.location.latitude").flatMap{ $0.stringValue }
    }
    var longitude: String? {
        return json.get(path: "content.location.longitude").flatMap{ $0.stringValue }
    }
}

public struct StickerMessage: Event {
    public var json: JSON
    
    public init(json: JSON) {
        self.json = json
    }
    
    var stkPkgId: String? {
        return json.get(path: "content.contentMetadata.STKPKGID").flatMap{ $0.stringValue }
    }
    var stkId: String? {
        return json.get(path: "content.contentMetadata.STKID").flatMap{ $0.stringValue }
    }
    var stkVer: String? {
        return json.get(path: "content.contentMetadata.STKVER").flatMap{ $0.stringValue }
    }
    var stkTxt: String? {
        return json.get(path: "content.contentMetadata.STKTXT").flatMap{ $0.stringValue }
    }
}

public struct ContactMessage: Event {
    public var json: JSON
    
    public init(json: JSON) {
        self.json = json
    }
    
    var mid: String? {
        return json.get(path: "content.contentMetadata.mid").flatMap{ $0.stringValue }
    }
    var displayName: String? {
        return json.get(path: "content.contentMetadata.displayName").flatMap{ $0.stringValue }
    }
}
