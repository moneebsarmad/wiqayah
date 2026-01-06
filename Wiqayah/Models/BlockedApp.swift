import Foundation

/// Represents a social media app that can be blocked
struct BlockedApp: Identifiable, Codable, Hashable {
    let id: String // Bundle identifier
    let name: String
    let iconName: String
    var isBlocked: Bool
    var totalMinutesUsed: Int

    // MARK: - Initialization
    init(
        id: String,
        name: String,
        iconName: String,
        isBlocked: Bool = false,
        totalMinutesUsed: Int = 0
    ) {
        self.id = id
        self.name = name
        self.iconName = iconName
        self.isBlocked = isBlocked
        self.totalMinutesUsed = totalMinutesUsed
    }

    // MARK: - JSON Decoding Helper
    enum CodingKeys: String, CodingKey {
        case id
        case name
        case iconName = "icon"
        case isBlocked
        case totalMinutesUsed
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(String.self, forKey: .id)
        name = try container.decode(String.self, forKey: .name)
        iconName = try container.decode(String.self, forKey: .iconName)
        isBlocked = try container.decodeIfPresent(Bool.self, forKey: .isBlocked) ?? false
        totalMinutesUsed = try container.decodeIfPresent(Int.self, forKey: .totalMinutesUsed) ?? 0
    }

    // MARK: - Static Data
    static let supportedApps: [BlockedApp] = [
        BlockedApp(id: "com.zhiliaoapp.musically", name: "TikTok", iconName: "tiktok"),
        BlockedApp(id: "com.burbn.instagram", name: "Instagram", iconName: "instagram"),
        BlockedApp(id: "com.google.ios.youtube", name: "YouTube", iconName: "youtube"),
        BlockedApp(id: "com.facebook.Facebook", name: "Facebook", iconName: "facebook"),
        BlockedApp(id: "com.toyopagroup.picaboo", name: "Snapchat", iconName: "snapchat"),
        BlockedApp(id: "com.atebits.Tweetie2", name: "Twitter", iconName: "twitter")
    ]
}
