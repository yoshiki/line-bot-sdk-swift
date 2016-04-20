import Environment

let env = Environment()
do {
    if let to = env.getVar("TO_MID") {
        let bot = try LINEBotAPI()
        try bot.sendText(to: to, text: "こんにちは！こんにちは！")
    } else {
        print("set env TO_MID")
    }
} catch let e {
    print(e)
}
