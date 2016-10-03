import JSON

extension String {
    public var asJSON: JSON {
        return JSON.infer(self)
    }
}
