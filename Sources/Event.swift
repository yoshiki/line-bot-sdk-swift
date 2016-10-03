import JSON

public enum Type: String {
    case Text     = "text"
    case Image    = "image"
    case Video    = "video"
    case Audio    = "audio"
    case Location = "location"
    case Sticker  = "sticker"
    case Imagemap = "imagemap"
    
    var asJSON: JSON {
        return JSON.infer(rawValue)
    }
}

public struct Source {
    public let key: String
    public let value: String
}

public struct Message {
    public let id: String
    public let type: Type
    public let text: String
}

public protocol Event: Content {}

extension Event {
    public var type: Type? {
        return self["type"]
            .flatMap { $0.stringValue }
            .flatMap { Type(rawValue: $0) }
    }
    
    public var replyToken: String? {
        return self["replyToken"].flatMap { $0.stringValue }
    }
    
    public var timestamp: String? {
        return self["timestamp"].flatMap { $0.stringValue }
    }
    
    public var source: [Source]? {
        return self["source"]
            .flatMap { $0.objectValue }
            .flatMap { (s) -> [Source]? in
                var sources = [Source]()
                s.forEach({ (key, value) in
                    sources.append(Source(key: key, value: value.stringValue!))
                })
                return sources
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
                    return Message(id: id, type: Type(rawValue: type)!, text: text)
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
