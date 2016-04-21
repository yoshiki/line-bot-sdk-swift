import CCurl
import C7

public enum Method: String {
    case HEAD, GET, POST, PUT, DELETE
}

public struct Curl {
    class WriteStorage {
        var data = Data()
    }

    private let url: String
    private let headers: Headers

    var timeout = 3
    var verbose = false
    var method: Method = .GET

    public init(url: String, headers: Headers = []) {
        self.url = url
        self.headers = headers
    }

    public func get() {
        sendRequest(method: .GET)
    }

    public func post(body: Data) {
        sendRequest(method: .POST, body: body)
    }

    private func sendRequest(method: Method, body: Data = Data()) {
        let handle = curl_easy_init()

        // set url
        self.url.withCString {
            curlHelperSetOptString(handle, CURLOPT_URL, UnsafeMutablePointer($0))
        }

        // set timeout
        curlHelperSetOptInt(handle, CURLOPT_TIMEOUT, timeout)

        // set verbose
        curlHelperSetOptBool(handle, CURLOPT_VERBOSE, verbose ? CURL_TRUE : CURL_FALSE)

        // set method
        switch method {
        case .HEAD:
            curlHelperSetOptBool(handle, CURLOPT_NOBODY, CURL_TRUE)
            method.rawValue.withCString {
                curlHelperSetOptString(handle, CURLOPT_CUSTOMREQUEST, UnsafeMutablePointer($0))
            }
        case .GET:
            curlHelperSetOptBool(handle, CURLOPT_HTTPGET, CURL_TRUE)
        case .POST:
            curlHelperSetOptBool(handle, CURLOPT_POST, CURL_TRUE)
        default:
            method.rawValue.withCString {
                curlHelperSetOptString(handle, CURLOPT_CUSTOMREQUEST, UnsafeMutablePointer($0))
            }
        }

        // set headers
        var headersList: UnsafeMutablePointer<curl_slist>?
        for (key, value) in headers {
            let header = "\(key): \(value)"
            header.withCString { ptr in
                headersList = curl_slist_append(headersList, ptr)
            }
        }
        if headers.count > 0 {
            curlHelperSetOptHeaders(handle, headersList)
        }

        // set body
        if body.count > 0 {
            curlHelperSetOptInt(handle, CURLOPT_POSTFIELDSIZE, body.count)
            curlHelperSetOptString(handle, CURLOPT_POSTFIELDS, UnsafeMutablePointer<Int8>(body.bytes))
        }

        // set write func
        var writeStorage = WriteStorage()
        curlHelperSetOptWriteFunc(handle, &writeStorage) { (ptr, size, nMemb, privateData) -> Int in
            let storage = UnsafePointer<WriteStorage>(privateData)
            let realsize = size * nMemb

            var bytes: [UInt8] = [UInt8](repeating: 0, count: realsize)
            memcpy(&bytes, ptr, realsize)

            for byte in bytes {
                storage?.pointee.data.append(byte)
            }
            return realsize
        }

        // perform
        let ret = curl_easy_perform(handle)
        if ret == CURLE_OK {
            print(writeStorage.data)
        } else {
            let error = curl_easy_strerror(ret)
            if let errStr = String(validatingUTF8: error) {
                print("error = \(errStr)")
            }
            print("ret = \(ret)")
        }

        // cleanup
        curl_easy_cleanup(handle)
        
        if let _ = headersList {
            curl_slist_free_all(headersList!)
        }
    }
}
