import CCurl
import Data
import Environment

public struct Curl {
    class WriteStorage {
        var data = Data()
    }

    private let url: String

    public init(url: String) {
        self.url = url
    }

    public func post(body: String) {
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

        // set body
        let data = Data(body)
        curlHelperSetOptInt(handle, CURLOPT_POSTFIELDSIZE, data.count)
        var bytes = unsafeBitCast(data.bytes, [CChar].self)
        curlHelperSetOptString(handle, CURLOPT_POSTFIELDS, &bytes)

        // set write func
        var writeStorage = WriteStorage()
        curlHelperSetOptWriteFunc(handle, &writeStorage) { (ptr: UnsafeMutablePointer<Int8>, size: Int, nMemb: Int, privateData: UnsafeMutablePointer<Void>) -> Int in
            let storage = UnsafePointer<WriteStorage>(privateData)
            let realsize = size * nMemb
            let data = Data(pointer: ptr, length: realsize)
            for byte in data.bytes {
                storage.memory.data.appendByte(byte)
            }
            return realsize
        }

        // perform
        let ret = curl_easy_perform(handle)
        if ret == CURLE_OK {
            print(writeStorage.data)
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
