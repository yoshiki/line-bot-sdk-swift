# LINEBotAPI

[![Swift][swift-badge]][swift-url]
[![Platform][platform-badge]][platform-url]
[![License][mit-badge]][mit-url]
[![Bot][linebot-badge]][linebot-url]

## Overview

This library is **Unofficial**

**LINEBotAPI** is a SDK of the LINE Messaging API for Swift.

- Swift 3 support
- Using [Zewo](https://github.com/Zewo/)
- Linux Ready

## Features

- [x] Send text/image/video/audio/location/sticker message
- [x] Handle follow/unfollow/join/leave/postback/Beacon events
- [x] Send imagemap/template message

## A Work In progress

LINEBotAPI is currently in development.

## Attention

Currently LINEBotAPI works with `3.0`.

## Getting started

### Installation

Before we start, we need to install some tools and dependencies.

### Swift

Install Swift using swiftenv or use docker images([docker-swift](https://github.com/swiftdocker/docker-swift)).

### swiftenv

[`swiftenv`](https://github.com/kylef/swiftenv) allows you to easily install multiple versions of swift.

```
% git clone https://github.com/kylef/swiftenv.git ~/.swiftenv
```
and add settings for your shell(For more information, please see [swiftenv's wiki](https://github.com/kylef/swiftenv).

Then install Swift 3.0. This process does not need on Mac OS X installed Xcode 8, only Linux.

```
% swiftenv install 3.0
```

## Install other libraries.

- On OS X

    ```
    % brew install openssl curl
    % brew link --force openssl
    ```

- On Linux

    ```
    % sudo apt-get update
    % sudo apt-get install libcurl4-openssl-dev
    ```

# Create project

We got prepared for a creating project.

Let's create your LINE Bot!

## Make project directory.

```
% mkdir linebot && cd linebot
```

Set Swift version to `3.0` if you need.

```
% swiftenv local 3.0
```

Initialize project directory with Swift Package Manager(**SPM**).

```
% swift package init --type executable
```

Then this command will create the basic structure for executable command.

```
.
├── Package.swift
├── Sources
│   └── main.swift
└── Tests
```

## Package.swift

Open `Package.swift` and make it looks like this:

```swift
import PackageDescription

let package = Package(
    name: "linebot",
    dependencies: [
        .Package(url: "https://github.com/yoshik/LINEBotAPI.git", majorVersion: 1, minor: 0),
    ]
)
```

## main.swift

Next, write main program in `main.swift`.

```swift
import LINEBotAPI

do {
    if let userId = getVar(name: "USER_ID") {
        let bot = try LINEBotAPI()
        try bot.sendText(to: userId, text: "Hello! Hello!")
    } else {
        print("set env USER_ID")
    }
} catch let e {
    print(e)
}
```

This code:
- get target `userId`(A user id on LINE)
- send text to `userId` specified.

## Build project

Change lib and include paths to your environment.

```
% swift build
```

## Run it

After it compiles, run it.

>Your must specify `CHANNEL_SECRET`, `ACCESS_TOKEN` and `USER_ID` to yours. `USER_ID` is your user id.

```
% env CHANNEL_SECRET=XXXXXXXXXXXXXXXXXXXXXXXXXXXXX ACCESS_TOKEN=XXXXXXXXXXXXXXXXXXXXXXXXXXXXX USER_ID=XXXXXXXXXXXXXXXXXXXXXXXXXXXXX .build/debug/linebot
```

You will get a message from bot on LINE if you had setup setting on bot management page.

# Start Server

LINEBotAPI allows you to start server using `Zewo`.

## main.swift

Open `main.swift` and make it look like this:

```swift
import LINEBotAPI
import HTTPServer

let bot = try LINEBotAPI()
let log = LogMiddleware(debug: true)

// Initializer a router.
let router = BasicRouter { (routes) in
    // Waiting for POST request on /callback.
    routes.post("/callback") { (request) in
        // Parsing request and validate signature
        return try bot.parseRequest(request) { (event) in
            if let textMessage = event as? TextMessage, let text = textMessage.text {
                let builder = MessageBuilder()
                builder.addText(text: text)
                if let messages = try builder.build(), let replyToken = textMessage.replyToken {
                    try bot.replyMessage(replyToken: replyToken, messages: messages)
                }
            }
        }
    }
}

// start server
let server = try Server(port: 8080, middleware: [log], responder: router)
try server.start()
```

>This is echo bot.

Then build and run it.

```
% env CHANNEL_SECRET=XXXXXXXXXXXXXXXXXXXXXXXXXXXXX ACCESS_TOKEN=XXXXXXXXXXXXXXXXXXXXXXXXXXXXX USER_ID=XXXXXXXXXXXXXXXXXXXXXXXXXXXXX .build/debug/linebot
```

The server will be started on port 8080.

This server will be waiting a POST request from Bot Server at `/callback`.

# Other examples

>TODO

# Tips

## Can I develop on Xcode?

Yes, sure. You can generate a xcode project file with following command.

```
% swift package generate-xcodeproj
```

## Can I use https server?

Maybe. We are developing it using reverse proxy, but you must be able to support https because Zewo has `HTTPSServer`.

# License

LINEBotAPI is released under the MIT license. See LICENSE for details.

[swift-badge]: https://img.shields.io/badge/Swift-3.0-orange.svg?style=flat
[swift-url]: https://swift.org
[platform-badge]: https://img.shields.io/badge/Platform-Mac%20%26%20Linux-lightgray.svg?style=flat
[platform-url]: https://swift.org
[mit-badge]: https://img.shields.io/badge/License-MIT-blue.svg?style=flat
[mit-url]: https://tldrlegal.com/license/mit-license
[linebot-badge]:https://img.shields.io/badge/Bot-LINE-brightgreen.svg?style=flat
[linebot-url]:https://developers.line.me/bot-api/overview
