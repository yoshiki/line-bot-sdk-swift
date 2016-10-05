import JSON

public enum BuilderError: Error {
    case contentsNotFound
}

public protocol Builder {
    func build() throws -> JSON?
}
