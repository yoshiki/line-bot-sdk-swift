import CCurl
import Data
import Environment

public struct Curl {
    class ReadStorage {
        let data: Data
        var currentIndex = 0
        init(data: Data) {
            self.data = data
        }
    }

    class WriteStorage {
        var data = Data()
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

        var readStorage = ReadStorage(data: Data(data))
        curlHelperSetOptInt(handle, CURLOPT_POSTFIELDSIZE, readStorage.data.count)

        curlHelperSetOptReadFunc(handle, &readStorage) { (buf: UnsafeMutablePointer<Int8>, size: Int, nMemb: Int, privateData: UnsafeMutablePointer<Void>) -> Int in
            let storage = UnsafePointer<ReadStorage?>(privateData)
            guard let data = storage.memory?.data else { return 0 }
            guard let currentIndex = storage.memory?.currentIndex else { return 0 }
            guard (size * nMemb) > 0 else { return 0 }
            guard currentIndex < data.count else { return 0 }

            let byte = data[currentIndex]
            let char = CChar(byte)
            buf.memory = char
            // storage.memory?.currentIndex += 1

            return 1
        }

        // set write func
        var writeStorage = WriteStorage()
        curlHelperSetOptWriteFunc(handle, &writeStorage) { (ptr: UnsafeMutablePointer<Int8>, size: Int, nMemb: Int, privateData: UnsafeMutablePointer<Void>) -> Int in
            // let storage = UnsafePointer<WriteStorage>(privateData)
            // let realsize = size * nMemb
            // var pointer = ptr
            // for _ in 1...realsize {
            //     let byte = pointer.memory
            //     storage.memory.data.bytes.append(Byte(byte))
            //     pointer = pointer.successor()
            // }
            // return realsize
            return size * nMemb
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
