import CCurl
import Data

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
        sendRequest(.GET)
    }

    public func post(body: Data) {
        sendRequest(.POST, body: body)
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
        var headersList: UnsafeMutablePointer<curl_slist> = nil
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
        if body.count > 0 {
            curlHelperSetOptInt(handle, CURLOPT_POSTFIELDSIZE, body.count)
            curlHelperSetOptString(handle, CURLOPT_POSTFIELDS, UnsafeMutablePointer<Int8>(body.bytes))
        }

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
