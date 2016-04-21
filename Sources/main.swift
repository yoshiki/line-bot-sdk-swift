import HTTPServer
import Router
import JSON

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
            var body: JSON? = nil
            if case .buffer(let data) = request.body {
                body = try JSONParser().parse(data: data)
            }
            
            // validate signature
            guard let signature = request.headers["X-LINE-ChannelSignature"].first else {
                return Response(status: Status.forbidden)
            }
            
            let isValid = bot.validateSignature(
                json: body!.toString(),
                channelSecret: bot.channelSecret,
                signature: signature
            )
            
            if !isValid {
                return Response(status: Status.forbidden)
            }
            
            // handle contents
            if let result = body!.get(path: "result") {
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
