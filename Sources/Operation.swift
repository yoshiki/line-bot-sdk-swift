import JSON

public enum OpType: Int {
    case Added = 4
    case Blocked = 8
}

public protocol Operation: Content {}

extension Operation {
    public var fromMid: String? {
        return self["content.params"]
            .flatMap { $0[0] }
            .flatMap { $0.string }
    }
    
    public var opType: OpType? {
        return self["content.opType"]
            .flatMap { $0.int }
            .flatMap { OpType(rawValue: $0) }
    }
    
    public var revision: Int? {
        return self["content.revision"].flatMap { $0.int }
    }
}

public struct AddOperation: Operation {
    public var json: JSON
    
    public init(json: JSON) {
        self.json = json
    }
}

public struct BlockOperation: Operation {
    public var json: JSON
    
    public init(json: JSON) {
        self.json = json
    }
}