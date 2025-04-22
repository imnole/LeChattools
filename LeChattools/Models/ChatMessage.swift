import Foundation

struct ChatMessage: Identifiable, Codable, Equatable {
    var id: UUID
    let content: String
    let isUser: Bool
    let timestamp: Date
    var isThinking: Bool
    var isFromHistory: Bool
    
    enum CodingKeys: String, CodingKey {
        case id
        case content
        case isUser
        case timestamp
        case isThinking
        case isFromHistory
    }
    
    init(content: String, isUser: Bool, isThinking: Bool = false, isFromHistory: Bool = false) {
        self.id = UUID()
        self.content = content
        self.isUser = isUser
        self.timestamp = Date()
        self.isThinking = isThinking
        self.isFromHistory = isFromHistory
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        content = try container.decode(String.self, forKey: .content)
        isUser = try container.decode(Bool.self, forKey: .isUser)
        timestamp = try container.decode(Date.self, forKey: .timestamp)
        isThinking = try container.decode(Bool.self, forKey: .isThinking)
        isFromHistory = try container.decodeIfPresent(Bool.self, forKey: .isFromHistory) ?? false
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(content, forKey: .content)
        try container.encode(isUser, forKey: .isUser)
        try container.encode(timestamp, forKey: .timestamp)
        try container.encode(isThinking, forKey: .isThinking)
        try container.encode(isFromHistory, forKey: .isFromHistory)
    }
} 