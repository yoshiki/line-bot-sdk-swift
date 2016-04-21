#LINEBotAPI

## Overview

**LINEBotAPI** is a SDK of the LINE BOT API Trial for Swift.

- Written in Swift3
- Use [Zewo](https://github.com/Zewo/Zewo)
- Linux Ready

## A Work In progress

LINEBotAPI is currently in development.

# Getting started

## Instlation

### Install swiftenv

Install [`swiftenv`](https://github.com/kylef/swiftenv).

```
% git clone https://github.com/kylef/swiftenv.git ~/.swiftenv
```
and add setting for your shell.

### Install Swift

Install Swift snapshot named `DEVELOPMENT-SNAPSHOT-2016-04-12-a`

```
% swiftenv install DEVELOPMENT-SNAPSHOT-2016-04-12-a
```

### Install libraries relevant to [Zewo](https://github.com/Zewo/Zewo).

#### On OS X

Install Zewo dependencies

```
% brew install zewo/tap/zewo
```

#### On Linux

Install Clang and ICU

```
% sudo apt-get install clang libicu-dev
```

Install Zewo dependencies

```
% echo "deb [trusted=yes] http://apt.zewo.io/deb ./" | sudo tee --append /etc/apt/sources.list
% sudo apt-get update
% sudo apt-get install zewo
```

### Install other libraries.

#### On OS X
```
% brew install openssl
% brew link --force openssl
```
#### On Linux
```
% sudo apt-get install build-essential libcurl4-openssl-dev
```

### Create project

Make project directory.

```
% mkdir linebot && cd linebot
```

Set swift version to `DEVELOPMENT-SNAPSHOT-2016-04-12-a`

```
% swift local DEVELOPMENT-SNAPSHOT-2016-04-12-a
```

Create project.

```
% swift build --init
```

Edit `Package.swift` to use `LINEBotAPI`.

```swift
import PackageDescription

let package = Package(
    name: "linebot",
    dependencies: [
        .Package(url: "https://github.com/yoshik/LINEBotAPI.git", majorVersion: 0, minor: 1),
    ]
)
```

Edit `main.swift`.

```swift
do {
    if let to = getVar(name: "TO_MID") {
        let bot = try LINEBotAPI()
        try bot.sendText(to: to, text: "Hello! Hello!")
    } else {
        print("set env TO_MID")
    }
} catch let e {
    print(e)
}
```

### Build project

Specify lib/include directory to your local path.

```
% make
```
or
```
% swift build -Xlinker -L/usr/local/lib -Xcc -I/usr/local/include -Xswiftc -I/usr/local/include
```

### Run `linebot`

Specify `LINE_CHANNEL_ID`, `LINE_CHANNEL_SECRET` and `LINE_BOT_MID` to yours.

```
% env LINE_CHANNEL_ID=XXXXXXXXX LINE_CHANNEL_SECRET=XXXXXXXXXXXXXXXXXXXXXXXXXXXXX LINE_BOT_MID=XXXXXXXXXXXXXXXXXXXXXXXXXXXXX  TO_MID=XXXXXXXXXXXXXXXXXXXXXXXXXXXXX .build/debug/linebot
```

You must be able to get a message from bot on LINE if you had setup setting on bot management page.

## Set up server

Open `main.swift` and make it look like this:

```swift
import HTTPServer
import Router
import JSON
import String

func handle(bot: LINEBotAPI, content: JSON) throws {
    if let message = try bot.parseMessage(json: content) {
        if let to = message.fromMid {
            try bot.sendText(to: to, text: "Hi! Hi!")
        }
    }
}

do {
    let bot = try LINEBotAPI()
    let router = Router { (route) in
        route.post("/linebot/callback") { request -> Response in
            // get body
            var body: String = ""
            if case .buffer(let data) = request.body {
                body = String(data)
            } else {
                return Response(status: Status.forbidden)
            }

            // validate signature
            guard let signature = request.headers["X-LINE-ChannelSignature"].first else {
                return Response(status: Status.forbidden)
            }

            let isValid = try bot.validateSignature(
                json: body,
                channelSecret: bot.channelSecret,
                signature: signature
            )

            if !isValid {
                return Response(status: Status.forbidden)
            }

            // handle contents
            let json = try JSONParser().parse(data: Data(body))
            if let result = json.get(path: "result") {
                let contents = try result.asArray()
                for content in contents {
                    try handle(bot: bot, content: content)
                }
                return Response(status: Status.ok, headers: [:], body: Data("accepted"))
            }
            return Response(status: Status.forbidden)
        }
    }

    try Server(router).start()
} catch let e {
    print(e)
}
```

and run it.

```
% env LINE_CHANNEL_ID=XXXXXXXXX LINE_CHANNEL_SECRET=XXXXXXXXXXXXXXXXXXXXXXXXXXXXX LINE_BOT_MID=XXXXXXXXXXXXXXXXXXXXXXXXXXXXX  TO_MID=XXXXXXXXXXXXXXXXXXXXXXXXXXXXX .build/debug/linebot
```

then start server on port 8080.

This server wait POST request from Bot Server on `/linebot/callback`.

## Tips

### Can I develop on Xcode?

Yes, sure. You can generate a xcode project file with following command.

```
% make xcode
```
or
```
% swift build -Xlinker -L/usr/local/lib -Xcc -I/usr/local/include -Xswiftc -I/usr/local/include -X
```

### Can I use https server?

Maybe. We are developing it using reverse proxy, but you must be able to support https because Zewo has `HTTPSServer`.

## License

LINEBotAPI is released under the MIT license. See LICENSE for details.
