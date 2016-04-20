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
        let curl = Curl(url: "\(self.baseUri)\(path)", headers: headers)
        curl.get()
    }

    public func post(path: String, json: JSON) throws {
        let curl = Curl(url: "\(self.baseUri)\(path)", headers: headers)
        curl.post(JSONSerializer().serialize(json))
    }
}
