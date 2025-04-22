import Foundation
import SwiftUI

@MainActor
class ChatViewModel: ObservableObject {
    @Published var messages: [ChatMessage] = []
    @Published var inputText: String = ""
    @Published var isLoading: Bool = false
    @Published var selectedModel: String?
    @Published var availableModels: [String] = []
    @Published var connectionStatus: ConnectionStatus = .disconnected
    @Published var isCheckingConnection: Bool = false
    @Published var conversations: [Conversation] = []
    @Published var currentConversationId: UUID?
    @Published var errorMessage: String?
    @Published var isThinking: Bool = false
    @Published var currentModelSupportsFiles: Bool = false
    @Published var currentModelSupportsVision: Bool = false
    
    private let ollamaService: OllamaService
    private let storageService: StorageService
    private let errorHandler: ErrorHandler
    
    private let multiModalModels = ["llava", "bakllava", "llava-chinese"]
    private let fileModels = ["llava", "bakllava", "llava-chinese", "claude-3"]
    
    init(ollamaService: OllamaService = OllamaService(),
         storageService: StorageService = .shared,
         errorHandler: ErrorHandler = ErrorHandler()) {
        self.ollamaService = ollamaService
        self.storageService = storageService
        self.errorHandler = errorHandler
        
        loadSavedConfig()
        loadConversations()
        
        Task {
            await checkConnection()
        }
    }
    
    private func loadSavedConfig() {
        selectedModel = storageService.getSelectedModel()
        ollamaService.setBaseURL(storageService.getOllamaURL())
    }
    
    private func loadConversations() {
        conversations = storageService.getConversations()
        if let lastConversation = conversations.last {
            currentConversationId = lastConversation.id
            messages = lastConversation.messages.map { message in
                var updatedMessage = message
                updatedMessage.isFromHistory = true
                return updatedMessage
            }
        }
    }
    
    func checkConnection() async {
        guard !isCheckingConnection else { return }
        isCheckingConnection = true
        connectionStatus = .connecting
        
        do {
            let isConnected = try await ollamaService.checkConnection()
            connectionStatus = isConnected ? .connected : .disconnected
            if isConnected {
                await fetchAvailableModels()
            } else {
                errorHandler.handle(.networkError("无法连接到 Ollama 服务器"))
            }
        } catch {
            connectionStatus = .disconnected
            errorHandler.handle(.networkError("无法连接到 Ollama 服务器"))
        }
        
        isCheckingConnection = false
    }
    
    func fetchAvailableModels() async {
        guard connectionStatus == .connected else { return }
        
        do {
            let models = try await ollamaService.listModels()
            availableModels = models
            
            if let currentModel = selectedModel, !models.contains(currentModel) {
                selectedModel = nil
                storageService.saveSelectedModel(nil)
                errorHandler.handle(.modelError("之前选择的模型不可用"))
            }
        } catch {
            errorHandler.handle(.networkError("获取模型列表失败"))
        }
    }
    
    func sendMessage() async {
        guard !inputText.isEmpty else { return }
        guard connectionStatus == .connected else {
            errorHandler.handle(.networkError("请先连接到 Ollama 服务器"))
            return
        }
        guard let model = selectedModel else {
            errorHandler.handle(.modelError("请先选择一个模型"))
            return
        }
        
        let userMessage = ChatMessage(content: inputText, isUser: true, isFromHistory: false)
        messages.append(userMessage)
        inputText = ""
        
        // 添加思考中的消息
        let thinkingMessage = ChatMessage(content: "思考中...", isUser: false, isThinking: true)
        messages.append(thinkingMessage)
        isThinking = true
        
        do {
            let response = try await ollamaService.generateResponse(
                prompt: userMessage.content,
                model: model
            )
            
            // 移除思考中的消息
            messages.removeLast()
            
            // 添加 AI 回复
            let assistantMessage = ChatMessage(content: response, isUser: false, isFromHistory: false)
            messages.append(assistantMessage)
            
            saveCurrentConversation()
        } catch {
            // 移除思考中的消息
            messages.removeLast()
            errorHandler.handle(.networkError("生成回复失败"))
        }
        
        isThinking = false
    }
    
    func clearChat() {
        // 检查当前是否已经是最新对话
        if let currentId = currentConversationId,
           currentId == conversations.last?.id,
           messages.isEmpty {
            errorMessage = "当前已是最新对话"
            return
        }
        
        if !messages.isEmpty {
            // 保存当前对话
            saveCurrentConversation()
        }
        
        // 创建新对话
        let newConversation = Conversation(messages: [])
        conversations.append(newConversation)
        currentConversationId = newConversation.id
        messages = []
        
        // 保存所有对话
        storageService.saveConversations(conversations)
    }
    
    private func saveCurrentConversation() {
        if let index = conversations.firstIndex(where: { $0.id == currentConversationId }) {
            conversations[index].messages = messages
        } else {
            let newConversation = Conversation(messages: messages)
            conversations.append(newConversation)
            currentConversationId = newConversation.id
        }
        storageService.saveConversations(conversations)
    }
    
    func updateModel(_ model: String) {
        selectedModel = model
        currentModelSupportsVision = multiModalModels.contains(model.lowercased())
        currentModelSupportsFiles = fileModels.contains(model.lowercased())
        storageService.saveSelectedModel(model)
    }
    
    func updateOllamaURL(_ url: String) {
        ollamaService.setBaseURL(url)
        storageService.saveOllamaURL(url)
        Task {
            await checkConnection()
        }
    }
    
    func handleKeyPress(_ key: String) {
        if key == "\r" && !inputText.isEmpty && !isLoading {
            Task {
                await sendMessage()
            }
        }
    }
    
    func handleFileUpload(_ url: URL) async {
        guard let selectedModel = selectedModel,
              currentModelSupportsFiles else {
            errorMessage = "当前模型不支持文件分析"
            return
        }
        
        do {
            let fileData = try Data(contentsOf: url)
            let fileContent = String(data: fileData, encoding: .utf8) ?? "无法读取文件内容"
            
            let message = ChatMessage(
                content: "请分析以下文件内容：\n\n\(fileContent)",
                isUser: true
            )
            
            messages.append(message)
            
            // 添加思考中的消息
            let thinkingMessage = ChatMessage(content: "思考中...", isUser: false, isThinking: true)
            messages.append(thinkingMessage)
            isThinking = true
            
            do {
                let response = try await ollamaService.generateResponse(
                    prompt: message.content,
                    model: selectedModel
                )
                
                // 移除思考中的消息
                messages.removeLast()
                
                // 添加 AI 回复
                let assistantMessage = ChatMessage(content: response, isUser: false)
                messages.append(assistantMessage)
                
                saveCurrentConversation()
            } catch {
                // 移除思考中的消息
                messages.removeLast()
                errorHandler.handle(.networkError("生成回复失败"))
            }
            
            isThinking = false
            
        } catch {
            errorMessage = "文件读取失败：\(error.localizedDescription)"
        }
    }
    
    func handleImageUpload(_ image: NSImage) async {
        guard let selectedModel = selectedModel,
              currentModelSupportsVision else {
            errorMessage = "当前模型不支持图片分析"
            return
        }
        
        // 将NSImage转换为Base64字符串
        guard let tiffData = image.tiffRepresentation,
              let bitmapImage = NSBitmapImageRep(data: tiffData),
              let jpegData = bitmapImage.representation(using: .jpeg, properties: [:]) else {
            errorMessage = "图片处理失败"
            return
        }
        
        let base64String = jpegData.base64EncodedString()
        
        let message = ChatMessage(
            content: "请分析这张图片：\n[图片数据：\(base64String)]",
            isUser: true
        )
        
        messages.append(message)
        
        // 添加思考中的消息
        let thinkingMessage = ChatMessage(content: "思考中...", isUser: false, isThinking: true)
        messages.append(thinkingMessage)
        isThinking = true
        
        do {
            let response = try await ollamaService.generateResponse(
                prompt: message.content,
                model: selectedModel
            )
            
            // 移除思考中的消息
            messages.removeLast()
            
            // 添加 AI 回复
            let assistantMessage = ChatMessage(content: response, isUser: false)
            messages.append(assistantMessage)
            
            saveCurrentConversation()
        } catch {
            // 移除思考中的消息
            messages.removeLast()
            errorHandler.handle(.networkError("生成回复失败"))
        }
        
        isThinking = false
    }
}

struct Conversation: Identifiable, Codable {
    let id: UUID
    var messages: [ChatMessage]
    let createdAt: Date
    
    init(messages: [ChatMessage]) {
        self.id = UUID()
        self.messages = messages
        self.createdAt = Date()
    }
}

enum ConnectionStatus {
    case connected
    case disconnected
    case connecting
} 