import HTTPServer
import Router
import JSON

do {
    let bot = try LINEBotAPI()
    let router = Router { (route) in
        route.post("/linebot/callback") { request -> Response in
            var receivedJson: JSON? = nil
            switch request.body {
            case .buffer(let data):
                receivedJson = try JSONParser().parse(data: data)
            default:
                break
            }
            
            if let json = receivedJson,
                message = try bot.parseMessage(json: json),
                signature = request.headers["X-LINE-ChannelSignature"].first {
                let isValid = bot.validateSignature(json: "\(json)", channelSecret: bot.channelSecret, signature: signature)
                if isValid {
                    if let to = message.fromMid {
                        try bot.sendText(to: to, text: "こんにちは！こんにちは！")
                    }
                    return Response(status: Status.ok, headers: [:], body: Data("aaaa"))
                }
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
//        try bot.sendText(to: to, text: "こんにちは！こんにちは！")
//        // try bot.sendMultipleMessage()
//        //     .addText(text: "メッセージですよ")
//        //     .addLocation(text: "ここ、ここ", address: "Convention center", latitude: "35.61823286112982", longitude: "139.72824096679688")
//        //     .addText(text: "ここまでお願いします！")
//        //     .send(to: to)
//    } else {
//        print("set env TO_MID")
//    }
//} catch let e {
//    print(e)
//}
