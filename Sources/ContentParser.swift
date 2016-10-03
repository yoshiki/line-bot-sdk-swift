import JSON

public enum ContentParserError: Error {
    case UnknownEventType
}

public struct ContentParser {
    public static func parse(_ json: JSON) throws -> Content? {
        let eventType = json.get(path: "eventType")
            .flatMap { try? $0.asString() }
            .flatMap { EventType(rawValue: $0) }
//        if let eventType = eventType {
//            switch eventType {
//            case .ReceivingMessage:
//                return try MessageParser.parse(json)
//            case .ReceivingOperation:
//                return try OperationParser.parse(json)
//            default:
//                throw ContentParserError.UnknownEventType
//            }
//        }
        return nil
    }
}
