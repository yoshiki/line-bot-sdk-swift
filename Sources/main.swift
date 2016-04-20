import Environment

let env = Environment()
do {
    if let to = env.getVar("TO_MID") {
        let bot = try LINEBotAPI()
        // try bot.sendText(to: to, text: "こんにちは！こんにちは！")
        let a = bot.addText(text: "メッセージですよ")
            <+> bot.addLocation(text: "ここ、ここ", address: "Convention center", latitude: "35.61823286112982", longitude: "139.72824096679688")
            <+> bot.addText(text: "ここまでお願いします！")
        try bot.send(to: to, contentsProcessor: a)
    } else {
        print("set env TO_MID")
    }
} catch let e {
    print(e)
}
