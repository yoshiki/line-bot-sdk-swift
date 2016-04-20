import Environment

let env = Environment()
do {
    if let to = env.getVar("TO_MID") {
        let bot = try LINEBotAPI()
        // try bot.sendText(to: to, text: "こんにちは！こんにちは！")
        try bot.sendMultipleMessage()
            .addText(text: "メッセージですよ")
            .addLocation(text: "ここ、ここ", address: "Convention center", latitude: "35.61823286112982", longitude: "139.72824096679688")
            .addText(text: "ここまでお願いします！")
            .send(to: to)
    } else {
        print("set env TO_MID")
    }
} catch let e {
    print(e)
}
