import JSON

public enum ContentParserError: ErrorProtocol {
    case UnknownEventType
}

public struct ContentParser {
    public static func parse(_ json: JSON) throws -> Content? {
        let eventType = json.get(path: "eventType")
            .flatMap { $0.string }
            .flatMap { EventType(rawValue: $0) }
        if let eventType = eventType {
            switch eventType {
            case .ReceivingMessage:
                return try MessageParser.parse(json)
            case .ReceivingOperation:
                return try OperationParser.parse(json)
            default:
                throw ContentParserError.UnknownEventType
            }
        }
        return nil
    }
}