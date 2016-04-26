import JSON

public protocol Content {
    var json: JSON { get set }
    init(json: JSON)
}

extension Content {
    public subscript(path: String) -> JSON? {
        return json.get(path: path)
    }
}
