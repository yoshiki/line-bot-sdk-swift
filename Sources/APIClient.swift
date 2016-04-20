import URI
import JSON
import Environment

public typealias Headers = [(String,String)]
public typealias ChannelInfo = [String:String]

public enum APIClientError: ErrorType {
    case InvalidURI
}

public struct APIClient {
    let baseUri: String
    let channelInfo: ChannelInfo

    var headers: Headers {
        return [
            ("Content-Type", "application/json; charset=utf-8"),
            ("X-Line-ChannelID", channelInfo["ChannelId"]!),
            ("X-Line-ChannelSecret", channelInfo["ChannelSecret"]!),
            ("X-Line-Trusted-User-With-ACL", channelInfo["ChannelMid"]!),
        ]
    }

    public init(baseUri: String, channelInfo: ChannelInfo) {
        self.baseUri = baseUri
        self.channelInfo = channelInfo
    }

    public func get(path: String) throws {
        let uri = try cleanupUri(baseUri: baseUri, path: path)
        let curl = Curl(url: uri.description, headers: headers)
        curl.get()
    }

    public func post(path: String, json: JSON) throws {
        let uri = try cleanupUri(baseUri: baseUri, path: path)
        let curl = Curl(url: uri.description, headers: headers)
        curl.post(JSONSerializer().serialize(json))
    }

    private func cleanupUri(baseUri baseUri: String, path: String) throws -> URI {
        let u = try URI(string: baseUri)
        return URI(scheme: u.scheme, host: u.host, path: path)
    }
}
