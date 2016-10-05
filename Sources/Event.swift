import JSON

public enum EventType: String, StringJSONConvertible {
    case message  = "message"
    case follow   = "follow"
    case unfollow = "unfollow"
    case join     = "join"
    case leave    = "leave"
    case postback = "postback"
    case beacon   = "beacon"
}

public enum MessageType: String, StringJSONConvertible {
    case text     = "text"
    case image    = "image"
    case video    = "video"
    case audio    = "audio"
    case location = "location"
    case sticker  = "sticker"
    case imagemap = "imagemap"
}

public enum SourceType: String, StringJSONConvertible {
    case user  = "user"
    case group = "group"
    case room  = "room"
}

public struct Source {
    public let type: SourceType
    public let id: String
}

public protocol GetContentAPI {}

public protocol Event {
    var json: JSON { get set }
    init(json: JSON)
}

extension Event {
    public subscript(path: String) -> JSON? {
        return json.get(path: path)
    }
    
    public var replyToken: String? {
        return json["replyToken"]?.stringValue
    }
    
    public var eventType: EventType? {
        return self["type"]
            .flatMap { $0.stringValue }
            .flatMap { EventType(rawValue: $0) }
    }
    
    public var timestamp: String? {
        return self["timestamp"]
            .flatMap { $0.stringValue }
    }
    
    public var source: Source? {
        return self["source"]
            .flatMap { $0.objectValue }
            .flatMap { (s) -> Source? in
                if let type = s["type"]?.stringValue,
                    let sourceType = SourceType(rawValue: type) {
                    switch sourceType {
                    case .user:
                        if let id = s["userId"]?.stringValue {
                            return Source(type: sourceType, id: id)
                        }
                    case .group:
                        if let id = s["groupId"]?.stringValue {
                            return Source(type: sourceType, id: id)
                        }
                    case .room:
                        if let id = s["roomId"]?.stringValue {
                            return Source(type: sourceType, id: id)
                        }
                    }
                }
                return nil
            }
    }
}

public protocol MessageEvent: Event {}

extension MessageEvent {
    public var message: JSON? {
        return json["message"]
    }
    
    public var messageId: String? {
        return message
            .flatMap { $0.objectValue }
            .flatMap { $0["id"]?.stringValue }
    }

    public var messageType: MessageType? {
        return message
            .flatMap { $0.objectValue }
            .flatMap { $0["type"]?.stringValue }
            .flatMap { MessageType(rawValue: $0) }
    }
}

public struct TextMessage: MessageEvent {
    public var json: JSON
    
    public init(json: JSON) {
        self.json = json
    }
    
    public var text: String? {
        return message
            .flatMap { $0.objectValue }
            .flatMap { $0["text"]?.stringValue }
    }
}

public struct ImageMessage: MessageEvent, GetContentAPI {
    public var json: JSON

    public init(json: JSON) {
        self.json = json
    }
}

public struct VideoMessage: MessageEvent, GetContentAPI {
    public var json: JSON
    
    public init(json: JSON) {
        self.json = json
    }
}

public struct AudioMessage: MessageEvent, GetContentAPI {
    public var json: JSON
    
    public init(json: JSON) {
        self.json = json
    }
}

public struct LocationMessage: MessageEvent {
    public var json: JSON
    
    public init(json: JSON) {
        self.json = json
    }
    
    var title: String? {
        return message
            .flatMap { $0["title"]?.stringValue }
    }
    var address: String? {
        return message
            .flatMap { $0["address"]?.stringValue }
    }
    var latitude: String? {
        return message
            .flatMap { $0["latitude"]?.stringValue }
    }
    var longitude: String? {
        return message
            .flatMap { $0["latitude"]?.stringValue }
    }
}

// See also: https://devdocs.line.me/files/sticker_list.pdf
public struct StickerMessage: MessageEvent {
    public var json: JSON
    
    public init(json: JSON) {
        self.json = json
    }
    
    var packageId: String? {
        return message
            .flatMap { $0["packageId"]?.stringValue }
    }
    var stickerId: String? {
        return message
            .flatMap { $0["stickerId"]?.stringValue }
    }
}

public struct FollowEvent: Event {
    public var json: JSON
    
    public init(json: JSON) {
        self.json = json
    }
    
    public var userId: String? {
        return source?.id
    }
}

public struct UnfollowEvent: Event {
    public var json: JSON
    
    public init(json: JSON) {
        self.json = json
    }
    
    public var userId: String? {
        return source?.id
    }
}

public struct JoinEvent: Event {
    public var json: JSON
    
    public init(json: JSON) {
        self.json = json
    }

    public var groupId: String? {
        return source?.id
    }
}


public struct LeaveEvent: Event {
    public var json: JSON
    
    public init(json: JSON) {
        self.json = json
    }

    public var groupId: String? {
        return source?.id
    }
}


public struct PostbackEvent: Event {
    public var json: JSON
    
    public init(json: JSON) {
        self.json = json
    }
    
    public var postback: JSON? {
        return json["postback"]
    }
    
    public var data: String? {
        return postback
            .flatMap { $0.objectValue }
            .flatMap { $0["data"]?.stringValue }
    }
}

public struct BeaconEvent: Event {
    public var json: JSON
    
    public init(json: JSON) {
        self.json = json
    }
    
    public var beacon: JSON? {
        return json["beacon"]
    }
    
    public var hwid: String? {
        return beacon
            .flatMap { $0.objectValue }
            .flatMap { $0["hwid"]?.stringValue }
    }
    
    public var type: String? {
        return beacon
            .flatMap { $0.objectValue }
            .flatMap { $0["type"]?.stringValue }
    }
}
