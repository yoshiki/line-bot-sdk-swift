import JSON

public enum BuilderError: Error {
    case messagesNotFound
}

public protocol Builder {
    func build() throws -> JSON?
}
