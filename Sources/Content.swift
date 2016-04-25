import JSON

public protocol Content {
    var json: JSON { get set }
    init(json: JSON)
}

