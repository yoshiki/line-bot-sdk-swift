import JSON
import Curl

public typealias Headers = [(String,String)]

public enum ClientError: Error {
    case invalidURI, unknownError
}

public struct Client {
    var headers: Headers
    let curl = Curl()

    public init(headers: Headers) {
        self.headers = headers
    }

    public func get(uri: String) -> Data? {
        return curl.get(url: uri, headers: headers)
    }

    public func post(uri: String, json: JSON? = nil) -> Data? {
        if let json = json {
            return curl.post(url: uri, headers: headers, body: JSONSerializer().serialize(json: json))
        } else {
            return curl.post(url: uri, headers: headers, body: "")
        }
    }
}
