import URI
import JSON

public typealias Headers = [(String,String)]

public enum APIClientError: ErrorProtocol {
    case InvalidURI
}

public struct APIClient {
    var headers: Headers

    public init(headers: Headers) {
        self.headers = headers
    }

    public func get(uri: String) throws {
        let curl = Curl(url: uri, headers: headers)
        curl.get()
    }

    public func post(uri: String, json: JSON) throws {
        let curl = Curl(url: uri, headers: headers)
        curl.post(body: JSONSerializer().serialize(json: json))
    }
}
