import JSON
import Curl

public typealias Headers = [(String,String)]

public enum ClientError: Error {
    case InvalidURI
}

public struct Client {
    var headers: Headers
    let curl = Curl()

    public init(headers: Headers) {
        self.headers = headers
    }

    public func get(uri: String) throws {
        let _ = curl.get(url: uri, headers: headers)
    }

    public func post(uri: String, json: JSON) throws {
        let _ = curl.post(url: uri, headers: headers, body: JSONSerializer().serialize(json: json))
    }
}
