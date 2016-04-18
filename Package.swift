import PackageDescription

#if os(OSX)
    let COpenSSLURL = "https://github.com/Zewo/COpenSSL-OSX.git"
#else
    let COpenSSLURL = "https://github.com/Zewo/COpenSSL.git"
#endif

let package = Package(
    name: "LINEBotAPI",
    dependencies: [
        .Package(url: "https://github.com/Zewo/JSON.git", majorVersion: 0, minor: 3),
        .Package(url: "https://github.com/yoshiki/HMACHash.git", majorVersion: 0, minor: 1),
        .Package(url: COpenSSLURL, majorVersion: 0, minor: 2),
        .Package(url: "https://github.com/Zewo/HTTPSClient.git", majorVersion: 0, minor: 3),
        .Package(url: "https://github.com/czechboy0/Environment.git", majorVersion: 0, minor: 1),
        .Package(url: "https://github.com/Zewo/Log.git", majorVersion: 0, minor: 3),
    ]
)
