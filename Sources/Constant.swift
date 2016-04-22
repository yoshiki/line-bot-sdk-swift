public enum EventType: String {
    case ReceivingMessage = "138311609000106303"
    case ReceivingOperation = "138311609100106403"
    case SendingMessage = "138311608800106203"
    case SendingMultipleMessage = "140177271400161403"
}

public enum ToType: Int {
    case ToUser = 1
}

public let BotAPIReceivingChannelId = "1341301815"
public let BotAPIReceivingChannelMid = "u206d25c2ea6bd87c17655609a1c37cb8"
public let BotAPISendingChannelId = "1383378250"
