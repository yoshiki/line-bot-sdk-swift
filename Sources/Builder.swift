import JSON

public enum BuilderError: ErrorProtocol {
    case BuildFailed, ContentsNotFound, InvalidHeight
}

public protocol Builder {
    func build() throws -> JSON?
}