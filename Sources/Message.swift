import JSON

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
    var json: JSON { get set }
    init(json: JSON)
}

extension MessageType {
    public var contentId: String? {
        return self["content.id"].flatMap { $0.string }
    }

    public var contentType: ContentType? {
        return self["content.contentType"].flatMap { $0.int }
          .flatMap { ContentType(rawValue: $0) }
    }

    public var createTime: String? {
        return self["content.createdTime"].flatMap { $0.string }
    }

    public var fromMid: String? {
        return self["content.from"].flatMap { $0.string }
    }

    public subscript(path: String) -> JSON? {
        return json.get(path: path)
    }
}

public struct TextMessage: MessageType {
    public var json: JSON

    public init(json: JSON) {
        self.json = json
    }
    
    public var text: String? {
        return json.get(path: "content.text").flatMap{ $0.string }
    }
}

public struct ImageMessage: MessageType {
    public var json: JSON

    public init(json: JSON) {
        self.json = json
    }
}

public struct VideoMessage: MessageType {
    public var json: JSON
    
    public init(json: JSON) {
        self.json = json
    }
}

public struct AudioMessage: MessageType {
    public var json: JSON
    
    public init(json: JSON) {
        self.json = json
    }
}

public struct LocationMessage: MessageType {
    public var json: JSON
    
    public init(json: JSON) {
        self.json = json
    }
    
    var title: String? {
        return json.get(path: "content.location.title").flatMap{ $0.string }
    }
    var address: String? {
        return json.get(path: "content.location.address").flatMap{ $0.string }
    }
    var latitude: String? {
        return json.get(path: "content.location.latitude").flatMap{ $0.string }
    }
    var longitude: String? {
        return json.get(path: "content.location.longitude").flatMap{ $0.string }
    }
}

public struct StickerMessage: MessageType {
    public var json: JSON
    
    public init(json: JSON) {
        self.json = json
    }
    
    var stkPkgId: String? {
        return json.get(path: "content.contentMetadata.STKPKGID").flatMap{ $0.string }
    }
    var stkId: String? {
        return json.get(path: "content.contentMetadata.STKID").flatMap{ $0.string }
    }
    var stkVer: String? {
        return json.get(path: "content.contentMetadata.STKVER").flatMap{ $0.string }
    }
    var stkTxt: String? {
        return json.get(path: "content.contentMetadata.STKTXT").flatMap{ $0.string }
    }
}

public struct ContactMessage: MessageType {
    public var json: JSON
    
    public init(json: JSON) {
        self.json = json
    }
    
    var mid: String? {
        return json.get(path: "content.contentMetadata.mid").flatMap{ $0.string }
    }
    var displayName: String? {
        return json.get(path: "content.contentMetadata.displayName").flatMap{ $0.string }
    }
}
