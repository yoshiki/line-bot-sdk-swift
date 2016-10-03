import JSON

extension Int {
    public var asJSON: JSON {
        return JSON.infer(self)
    }
}

