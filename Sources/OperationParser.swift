import JSON

public struct OperationParser {
    public static func parse(_ json: JSON) throws -> Content? {
        let opType = json.get(path: "content.opType")
            .flatMap { $0.intValue }
            .flatMap { OpType(rawValue: $0) }
        if let opType = opType {
            switch opType {
            case .Added:
                return AddOperation(json: json)
            case .Blocked:
                return BlockOperation(json: json)
            }
        } else {
            return nil
        }
    }
}

