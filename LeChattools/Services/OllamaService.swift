import Foundation

class OllamaService: ObservableObject {
    private var baseURL: String
    private var session: URLSession
    
    init(baseURL: String = "http://127.0.0.1:11434") {
        self.baseURL = baseURL
        self.session = URLSession.shared
    }
    
    func setBaseURL(_ url: String) {
        self.baseURL = url.replacingOccurrences(of: "localhost", with: "127.0.0.1")
    }
    
    func checkConnection() async throws -> Bool {
        let url = URL(string: "\(baseURL)/api/tags")!
        var request = URLRequest(url: url)
        request.timeoutInterval = 5
        
        do {
            let (_, response) = try await URLSession.shared.data(for: request)
            if let httpResponse = response as? HTTPURLResponse {
                return httpResponse.statusCode == 200
            }
            return false
        } catch {
            print("连接检测错误: \(error.localizedDescription)")
            return false
        }
    }
    
    func generateResponse(prompt: String, model: String = "llama2") async throws -> String {
        let endpoint = "\(baseURL)/api/generate"
        
        let requestBody: [String: Any] = [
            "model": model,
            "prompt": prompt,
            "stream": false
        ]
        
        guard let url = URL(string: endpoint) else {
            throw NSError(domain: "OllamaService", code: -1, userInfo: [NSLocalizedDescriptionKey: "无效的 URL"])
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try JSONSerialization.data(withJSONObject: requestBody)
        request.timeoutInterval = 30.0
        
        let (data, response) = try await session.data(for: request)
        
        if let httpResponse = response as? HTTPURLResponse {
            if httpResponse.statusCode == 404 {
                throw NSError(domain: "OllamaService", code: -3, userInfo: [NSLocalizedDescriptionKey: "模型不存在"])
            }
        }
        
        let ollamaResponse = try JSONDecoder().decode(OllamaResponse.self, from: data)
        return ollamaResponse.response
    }
    
    func listModels() async throws -> [String] {
        let url = URL(string: "\(baseURL)/api/tags")!
        let (data, _) = try await URLSession.shared.data(from: url)
        let response = try JSONDecoder().decode(ModelsResponse.self, from: data)
        return response.models.map { $0.name }
    }
}

struct OllamaResponse: Codable {
    let response: String
}

struct ModelsResponse: Codable {
    let models: [ModelInfo]
}

struct ModelInfo: Codable {
    let name: String
}

struct OllamaModel: Codable {
    let name: String
    let modified_at: String
    let size: Int
} 