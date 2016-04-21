import PackageDescription

let package = Package(
    name: "LINEBotAPI",
    dependencies: [
        .Package(url: "https://github.com/IBM-Swift/CCurl.git", majorVersion: 0),
        .Package(url: "https://github.com/Zewo/HTTPSServer.git", majorVersion: 0, minor: 5),
        .Package(url: "https://github.com/Zewo/HTTPServer.git", majorVersion: 0, minor: 5),
        .Package(url: "https://github.com/Zewo/Router.git", majorVersion: 0, minor: 5),
        .Package(url: "https://github.com/Zewo/JSON.git", majorVersion: 0, minor: 5),
        .Package(url: "https://github.com/Zewo/Base64.git", majorVersion: 0, minor: 5),
    ],
    exclude: [ "EnvironmentTests" ]
)
