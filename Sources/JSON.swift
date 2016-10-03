import JSON

extension JSON {
    public func get(path: String) -> JSON? {
        let paths = path.characters.split(separator: ".").map { String($0) }
        var json = Optional(self)
        paths.forEach { key in
            json = json.flatMap {
                if let index = Int(key), let arr = $0.arrayValue, index < arr.count {
                    return $0[index]
                } else {
                    return $0[key]
                }
            }
        }
        return json
    }
}
