import Environment

let env = Environment()
if let channelId = env.getVar("LINE_CHANNEL_ID"),
    channelSecret = env.getVar("LINE_CHANNEL_SECRET"),
    channelMid = env.getVar("LINE_BOT_MID"),
    to = env.getVar("TO") {
    let bot = LINEBotAPI(channelId: channelId, channelSecret: channelSecret, channelMid: channelMid)
    do {
        try bot.sendText(to: to, text: "こんにちは")
    } catch let e {
        print(e)
    }
} else {
    print("Need to specify env")
}
