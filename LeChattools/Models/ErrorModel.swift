import Foundation
import SwiftUI

enum AppError: LocalizedError {
    case networkError(String)
    case modelError(String)
    case systemError(String)
    
    var errorDescription: String? {
        switch self {
        case .networkError(let message):
            return "网络错误: \(message)"
        case .modelError(let message):
            return "模型错误: \(message)"
        case .systemError(let message):
            return "系统错误: \(message)"
        }
    }
}

class ErrorHandler: ObservableObject {
    @Published var currentError: AppError?
    @Published var showError: Bool = false
    
    func handle(_ error: AppError) {
        currentError = error
        showError = true
    }
    
    func dismiss() {
        showError = false
        currentError = nil
    }
} 