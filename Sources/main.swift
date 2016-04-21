import HTTPServer
import Router
import JSON
import String

func handle(bot: LINEBotAPI, content: JSON) throws {
    if let message = try bot.parseMessage(json: content) {
        if let to = message.fromMid {
            try bot.sendText(to: to, text: "こんにちは！こんにちは！")
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
                return Response(status: Status.ok, headers: [:], body: Data("aaaa"))
            }
            return Response(status: Status.forbidden)
        }
    }
    
    try Server(router).start()
} catch let e {
    print(e)
}

//do {
//    if let to = getVar(name: "TO_MID") {
//        let bot = try LINEBotAPI()
////        try bot.sendText(to: to, text: "こんにちは！こんにちは！")
//        try bot.sendMultipleMessage(to: to) { builder in
//            builder.addText(text: "メッセージですよ")
//            builder.addLocation(text: "ここ、ここ", address: "Convention center", latitude: "35.61823286112982", longitude: "139.72824096679688")
//            builder.addText(text: "ここまでお願いします！")
//        }
//    } else {
//        print("set env TO_MID")
//    }
//} catch let e {
//    print(e)
//}
