import HTTPSClient
import URI
import JSON

public enum APIClientError: ErrorType {
    case InvalidURI
}

public struct APIClient {
    let baseUri: String

    public init(baseUri: String) {
        self.baseUri = baseUri
    }

    public func get(path: String) throws -> Response? {
        let uri = try URI(string: baseUri)
        if let host = uri.host {
            let client = try Client(host: host, port: 443)
            return try client.get(path)
        } else {
            return nil
        }
    }

    public func post(path: String, json: JSON) throws -> Response? {
        let uri = try URI(string: baseUri)
        if let host = uri.host {
            let client = try Client(host: host, port: 443)
            return try client.post(path, body: JSONSerializer().serialize(json))
        } else {
            return nil
        }
    }
}
