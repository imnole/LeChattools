import Foundation

class StorageService {
    static let shared = StorageService()
    private let userDefaults = UserDefaults.standard
    
    private init() {}
    
    // MARK: - Ollama 配置
    func saveOllamaURL(_ url: String) {
        userDefaults.set(url, forKey: "ollama_url")
    }
    
    func getOllamaURL() -> String {
        return userDefaults.string(forKey: "ollama_url") ?? "http://127.0.0.1:11434"
    }
    
    func saveSelectedModel(_ model: String?) {
        if let model = model {
            userDefaults.set(model, forKey: "selected_model")
        } else {
            userDefaults.removeObject(forKey: "selected_model")
        }
    }
    
    func getSelectedModel() -> String? {
        return userDefaults.string(forKey: "selected_model")
    }
    
    // MARK: - 对话管理
    func saveConversations(_ conversations: [Conversation]) {
        if let encoded = try? JSONEncoder().encode(conversations) {
            userDefaults.set(encoded, forKey: "conversations")
        }
    }
    
    func getConversations() -> [Conversation] {
        guard let data = userDefaults.data(forKey: "conversations"),
              let conversations = try? JSONDecoder().decode([Conversation].self, from: data) else {
            return []
        }
        return conversations
    }
    
    // MARK: - 聊天历史
    func saveChatHistory(_ history: [ChatMessage]) {
        if let encoded = try? JSONEncoder().encode(history) {
            userDefaults.set(encoded, forKey: "chat_history")
        }
    }
    
    func getChatHistory() -> [ChatMessage] {
        guard let data = userDefaults.data(forKey: "chat_history"),
              let history = try? JSONDecoder().decode([ChatMessage].self, from: data) else {
            return []
        }
        return history
    }
    
    // MARK: - 主题设置
    func saveTheme(_ theme: AppTheme) {
        userDefaults.set(theme.rawValue, forKey: "app_theme")
    }
    
    func getTheme() -> AppTheme {
        let rawValue = userDefaults.string(forKey: "app_theme") ?? AppTheme.system.rawValue
        return AppTheme(rawValue: rawValue) ?? .system
    }
}

enum AppTheme: String {
    case light
    case dark
    case system
} 