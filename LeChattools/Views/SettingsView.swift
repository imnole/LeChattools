import SwiftUI

struct SettingsView: View {
    @EnvironmentObject private var chatViewModel: ChatViewModel
    @Environment(\.dismiss) private var dismiss
    
    @State private var ollamaURL: String = ""
    @State private var selectedTheme: AppTheme = .system
    
    var body: some View {
        TabView {
            GeneralSettingsView(
                ollamaURL: $ollamaURL,
                selectedTheme: $selectedTheme
            )
            .tabItem {
                Label("通用", systemImage: "gear")
            }
            
            ModelSettingsView()
                .tabItem {
                    Label("模型", systemImage: "brain")
                }
        }
        .frame(width: 500, height: 300)
        .onAppear {
            ollamaURL = StorageService.shared.getOllamaURL()
            selectedTheme = StorageService.shared.getTheme()
        }
        .onChange(of: ollamaURL) { newValue in
            chatViewModel.updateOllamaURL(newValue)
        }
        .onChange(of: selectedTheme) { newValue in
            StorageService.shared.saveTheme(newValue)
        }
    }
}

struct GeneralSettingsView: View {
    @Binding var ollamaURL: String
    @Binding var selectedTheme: AppTheme
    
    var body: some View {
        Form {
            Section("Ollama 服务器") {
                TextField("服务器地址", text: $ollamaURL)
                    .textFieldStyle(.roundedBorder)
            }
            
            Section("外观") {
                Picker("主题", selection: $selectedTheme) {
                    Text("浅色").tag(AppTheme.light)
                    Text("深色").tag(AppTheme.dark)
                    Text("系统").tag(AppTheme.system)
                }
                .pickerStyle(.segmented)
            }
        }
        .padding()
    }
}

struct ModelSettingsView: View {
    @EnvironmentObject private var chatViewModel: ChatViewModel
    
    var body: some View {
        Form {
            Section("可用模型") {
                List(chatViewModel.availableModels, id: \.self) { model in
                    HStack {
                        Text(model)
                        Spacer()
                        if model == chatViewModel.selectedModel {
                            Image(systemName: "checkmark")
                                .foregroundColor(.blue)
                        }
                    }
                    .contentShape(Rectangle())
                    .onTapGesture {
                        chatViewModel.updateModel(model)
                    }
                }
            }
        }
        .padding()
        .task {
            await chatViewModel.fetchAvailableModels()
        }
    }
} 