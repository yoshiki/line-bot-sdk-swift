import JSON

public protocol StringJSONConvertible: RawRepresentable {}

extension StringJSONConvertible {
    typealias RawValue = String
    public var asJSON: JSON {
        return JSON.infer(rawValue)
    }
}

public protocol IntJSONConvertible: RawRepresentable {}

extension IntJSONConvertible {
    typealias RawValue = Int
    public var asJSON: JSON {
        return JSON.infer(rawValue)
    }
}
