import JSON
import Curl

public typealias Headers = [(String,String)]

public enum ClientError: Error {
    case invalidURI
}

public struct Client {
    var headers: Headers
    let curl = Curl()

    public init(headers: Headers) {
        self.headers = headers
    }

    public func get(uri: String) throws {
        let res = curl.get(url: uri, headers: headers)
        print(res)
    }

    public func post(uri: String, json: JSON) throws {
        let res = curl.post(url: uri, headers: headers, body: JSONSerializer().serialize(json: json))
        print(res?.description)
    }
}
