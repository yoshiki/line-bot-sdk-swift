import JSON

public typealias BuilderType = Builder -> Void

public protocol Builder {
    var contents: [JSON] { get set }
    init(contents: [JSON])
}