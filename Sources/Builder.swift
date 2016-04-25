import JSON

public enum BuilderError: ErrorProtocol {
    case BuildFailed, ContentsNotFound
}

public typealias BuilderType = Builder -> Void

public protocol Builder {
    func build() throws -> JSON?
}