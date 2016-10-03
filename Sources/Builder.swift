import JSON

public enum BuilderError: Error {
    case BuildFailed, ContentsNotFound, InvalidHeight
}

public protocol Builder {
    func build() throws -> JSON?
}
