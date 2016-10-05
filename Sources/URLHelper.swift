public struct URLHelper {
    public static let BotAPIBaseURL = "https://api.line.me/v2/bot"
    
    public static func getContentURL(messageId: String) -> String {
        return "\(BotAPIBaseURL)/message/\(messageId)/content"
    }
    
    public static func getProfileURL(userId: String) -> String {
        return "\(BotAPIBaseURL)/profile/\(userId)"
    }
    
    public static func leaveRoomURL(roomId: String) -> String {
        return "\(BotAPIBaseURL)/room/\(roomId)/leave"
    }

    public static func leaveGroupURL(groupId: String) -> String {
        return "\(BotAPIBaseURL)/group/\(groupId)/leave"
    }

    public static func replyMessageURL() -> String {
        return "\(BotAPIBaseURL)/message/reply"
    }
    
    public static func pushMessageURL() -> String {
        return "\(BotAPIBaseURL)/message/push"
    }
}
