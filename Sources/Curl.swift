import CCurl
import Environment

public struct Curl {
    class Received {
        var data = String()
    }

    class Send {
        let data: String
        init(data: String) {
            self.data = data
        }
    }

    private let url: String

    public init(url: String) {
        self.url = url
    }

    public func post(data: String) {
        let handle = curl_easy_init()

        // set url
        self.url.withCString {
            curlHelperSetOptString(handle, CURLOPT_URL, UnsafeMutablePointer($0))
        }

        // set timeout
        let timeout = 3
        curlHelperSetOptInt(handle, CURLOPT_TIMEOUT, timeout)

        // set post
        curlHelperSetOptBool(handle, CURLOPT_POST, CURL_TRUE)

        // set headers
        let env = Environment()
        var headersList: UnsafeMutablePointer<curl_slist> = nil
        let headers: [(String, String)] = [
            ("Content-Type", "application/json; charset=utf-8"),
            ("X-Line-ChannelID", env.getVar("LINE_CHANNEL_ID")!),
            ("X-Line-ChannelSecret", env.getVar("LINE_CHANNEL_SECRET")!),
            ("X-Line-Trusted-User-With-ACL", env.getVar("LINE_BOT_MID")!),
        ]
        for (key, value) in headers {
            let header = "\(key): \(value)"
            header.withCString {
                headersList = curl_slist_append(headersList, UnsafeMutablePointer($0))
            }
        }
        if headersList != nil {
            curlHelperSetOptHeaders(handle, headersList)
        }

        var send = Send(data: data)
        send.data.withCString {
            let data = UnsafeMutablePointer<Int8>($0)
            curlHelperSetOptInt(handle, CURLOPT_POSTFIELDSIZE, Int(strlen(data)))
        }

        curlHelperSetOptReadFunc(handle, &send) { (buf: UnsafeMutablePointer<Int8>, size: Int, nMemb: Int, privateData: UnsafeMutablePointer<Void>) -> Int in
            let p = UnsafePointer<Send?>(privateData)
            let len = size * nMemb
            if let data = p.memory?.data {
                memcpy(buf, data, len)
            }
            return len
        }

        // set write func
        var received = Received()
        curlHelperSetOptWriteFunc(handle, &received) { (ptr: UnsafeMutablePointer<Int8>, size: Int, nMemb: Int, privateData: UnsafeMutablePointer<Void>) -> Int in
            let p = UnsafePointer<Received?>(privateData)
            if let line = String.fromCString(ptr) {
                p.memory?.data.appendContentsOf(line)
            }
            return size * nMemb
        }

        // perform
        let ret = curl_easy_perform(handle)
        if ret == CURLE_OK {
            print(received.data)
        } else {
            let error = curl_easy_strerror(ret)
            if let errStr = String.fromCString(error) {
                print("error = \(errStr)")
            }
            print("ret = \(ret)")
        }

        // cleanup
        curl_easy_cleanup(handle)

        if headersList != nil {
            curl_slist_free_all(headersList)
        }
    }
}
