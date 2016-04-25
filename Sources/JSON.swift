import JSON

extension JSON {
    public func get(path: String) -> JSON? {
        let paths = path.characters.split(separator: ".").map { String($0) }
        var json = Optional(self)
        paths.forEach { key in
            json = json.flatMap {
                if let index = Int(key), arr = $0.array where index < arr.count {
                    return $0[index]
                } else {
                    return $0[key]
                }
            }
        }
        return json
    }
    
    public func toString() -> String {
        return JSONSerializer().serializeToString(json: self)
    }
    
    public func escape() -> JSON {
        var str = toString()
        str.replace(string: "\"", with: "\\\"")
        return JSON.from(str)
    }
}
