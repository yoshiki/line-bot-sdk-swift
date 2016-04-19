import PackageDescription

let package = Package(
    name: "LINEBotAPI",
    dependencies: [
        .Package(url: "https://github.com/Zewo/JSON.git", majorVersion: 0, minor: 3),
        .Package(url: "https://github.com/yoshiki/HMACHash.git", majorVersion: 0, minor: 1),
        .Package(url: "https://github.com/IBM-Swift/CCurl.git", majorVersion: 0),
        .Package(url: "https://github.com/czechboy0/Environment.git", majorVersion: 0, minor: 1),
        .Package(url: "https://github.com/Zewo/Log.git", majorVersion: 0, minor: 3),
        .Package(url: "https://github.com/Zewo/URI.git", majorVersion: 0, minor: 3),
    ]
)
