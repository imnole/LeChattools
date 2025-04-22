import SwiftUI

struct ContentView: View {
    @EnvironmentObject private var chatViewModel: ChatViewModel
    @EnvironmentObject private var systemMonitor: SystemMonitor
    
    var body: some View {
        NavigationSplitView {
            SidebarView()
                .frame(minWidth: 250)
        } detail: {
            ChatView()
                .frame(minWidth: 600, minHeight: 400)
        }
        .toolbar {
            ToolbarItemGroup(placement: .navigation) {
                Button(action: {
                    chatViewModel.clearChat()
                }) {
                    Label("新建对话", systemImage: "plus.circle.fill")
                        .labelStyle(.titleAndIcon)
                }
                .help("创建新对话")
            }
            
            ToolbarItemGroup(placement: .primaryAction) {
                Menu {
                    if chatViewModel.availableModels.isEmpty {
                        Text("无可用模型")
                            .foregroundColor(.secondary)
                    } else {
                        ForEach(chatViewModel.availableModels, id: \.self) { model in
                            Button(action: {
                                chatViewModel.updateModel(model)
                            }) {
                                HStack {
                                    Text(model)
                                    if model == chatViewModel.selectedModel {
                                        Image(systemName: "checkmark")
                                            .foregroundColor(.accentColor)
                                    }
                                }
                            }
                        }
                    }
                } label: {
                    Label(chatViewModel.selectedModel ?? "选择模型", systemImage: "brain.head.profile")
                        .labelStyle(.titleAndIcon)
                }
                .disabled(chatViewModel.connectionStatus != .connected)
                .help(chatViewModel.connectionStatus == .connected ? "选择对话模型" : "请先连接到服务器")
            }
            
            ToolbarItemGroup(placement: .automatic) {
                Spacer()
                SystemStatusView()
                    .help("系统状态")
            }
        }
        .navigationTitle("LeChat Tools")
    }
}

struct SystemStatusView: View {
    @EnvironmentObject private var chatViewModel: ChatViewModel
    @EnvironmentObject private var systemMonitor: SystemMonitor
    
    var body: some View {
        HStack(spacing: 16) {
            ConnectionStatusView()
                .help(connectionStatusHelp)
            
            Divider()
                .frame(height: 16)
            
            SystemMonitorView()
                .help("系统资源监控")
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 6)
        .background(Color(NSColor.controlBackgroundColor))
        .cornerRadius(8)
    }
    
    private var connectionStatusHelp: String {
        switch chatViewModel.connectionStatus {
        case .connected:
            return "已连接到 Ollama 服务器"
        case .connecting:
            return "正在连接到 Ollama 服务器..."
        case .disconnected:
            return "未连接到 Ollama 服务器"
        }
    }
}

struct ConnectionStatusView: View {
    @EnvironmentObject private var chatViewModel: ChatViewModel
    
    var body: some View {
        HStack(spacing: 6) {
            Circle()
                .fill(statusColor)
                .frame(width: 8, height: 8)
            Text(statusText)
                .font(.caption)
                .foregroundColor(.secondary)
        }
    }
    
    private var statusColor: Color {
        switch chatViewModel.connectionStatus {
        case .connected:
            return .green
        case .connecting:
            return .yellow
        case .disconnected:
            return .red
        }
    }
    
    private var statusText: String {
        switch chatViewModel.connectionStatus {
        case .connected:
            return "已连接"
        case .connecting:
            return "连接中..."
        case .disconnected:
            return "未连接"
        }
    }
}

struct SidebarView: View {
    @EnvironmentObject private var chatViewModel: ChatViewModel
    @Environment(\.colorScheme) private var colorScheme
    
    var body: some View {
        List {
            Section {
                ForEach(chatViewModel.conversations) { conversation in
                    ConversationRow(conversation: conversation)
                }
            } header: {
                Text("对话历史")
                    .font(.headline)
                    .foregroundColor(.primary)
                    .padding(.bottom, 8)
            }
        }
        .listStyle(.sidebar)
        .background(Color(NSColor.controlBackgroundColor))
    }
}

struct ConversationRow: View {
    let conversation: Conversation
    @EnvironmentObject private var chatViewModel: ChatViewModel
    @State private var isHovered = false
    
    var body: some View {
        Button(action: {
            chatViewModel.currentConversationId = conversation.id
            chatViewModel.messages = conversation.messages
        }) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(conversation.messages.first?.content ?? "新对话")
                        .lineLimit(1)
                        .foregroundColor(.primary)
                    
                    Text(formattedDate)
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                if chatViewModel.currentConversationId == conversation.id {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.accentColor)
                }
            }
            .padding(.vertical, 4)
        }
        .buttonStyle(.plain)
        .padding(.horizontal, 8)
        .background(
            RoundedRectangle(cornerRadius: 6)
                .fill(isHovered ? Color.accentColor.opacity(0.1) : Color.clear)
        )
        .onHover { hovering in
            withAnimation(.easeInOut(duration: 0.2)) {
                isHovered = hovering
            }
        }
    }
    
    private var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        return formatter.string(from: conversation.createdAt)
    }
}

struct ChatView: View {
    @EnvironmentObject private var chatViewModel: ChatViewModel
    @FocusState private var isInputFocused: Bool
    @State private var isShowingFilePicker = false
    @State private var isShowingImagePicker = false
    
    var body: some View {
        VStack(spacing: 0) {
            if chatViewModel.connectionStatus != .connected {
                ConnectionPromptView()
            } else if chatViewModel.selectedModel == nil {
                ModelSelectionPromptView()
            } else {
                ScrollView {
                    ScrollViewReader { proxy in
                        LazyVStack(alignment: .leading, spacing: 16) {
                            ForEach(chatViewModel.messages) { message in
                                MessageView(message: message)
                                    .id(message.id)
                            }
                        }
                        .padding()
                        .onChange(of: chatViewModel.messages) { _ in
                            withAnimation {
                                if let lastMessage = chatViewModel.messages.last {
                                    proxy.scrollTo(lastMessage.id, anchor: .bottom)
                                }
                            }
                        }
                    }
                }
                
                Divider()
                
                VStack(spacing: 12) {
                    HStack(spacing: 12) {
                        TextField("输入消息...", text: $chatViewModel.inputText, axis: .vertical)
                            .textFieldStyle(.plain)
                            .padding(12)
                            .background(Color(NSColor.controlBackgroundColor))
                            .cornerRadius(8)
                            .focused($isInputFocused)
                            .frame(minHeight: 44)
                            .onSubmit {
                                Task {
                                    await chatViewModel.sendMessage()
                                }
                            }
                            .disabled(chatViewModel.isThinking)
                        
                        Button(action: {
                            isShowingFilePicker = true
                        }) {
                            Image(systemName: "doc.fill")
                                .font(.system(size: 20))
                                .foregroundColor(.accentColor)
                        }
                        .buttonStyle(.plain)
                        .disabled(!chatViewModel.currentModelSupportsFiles)
                        .help(chatViewModel.currentModelSupportsFiles ? "上传文件进行分析" : "当前模型不支持文件分析")
                        
                        Button(action: {
                            isShowingImagePicker = true
                        }) {
                            Image(systemName: "photo.fill")
                                .font(.system(size: 20))
                                .foregroundColor(.accentColor)
                        }
                        .buttonStyle(.plain)
                        .disabled(!chatViewModel.currentModelSupportsVision)
                        .help(chatViewModel.currentModelSupportsVision ? "上传图片进行分析" : "当前模型非多模态模型")
                        
                        Button(action: {
                            Task {
                                await chatViewModel.sendMessage()
                            }
                        }) {
                            Image(systemName: "arrow.up.circle.fill")
                                .font(.system(size: 24))
                                .foregroundColor(.accentColor)
                        }
                        .buttonStyle(.plain)
                        .disabled(chatViewModel.inputText.isEmpty || chatViewModel.isThinking)
                    }
                    
                    Text("按回车键发送，Shift + 回车换行")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .padding()
                .fileImporter(
                    isPresented: $isShowingFilePicker,
                    allowedContentTypes: [.text, .pdf, .data],
                    allowsMultipleSelection: false
                ) { result in
                    switch result {
                    case .success(let urls):
                        if let url = urls.first {
                            Task {
                                await chatViewModel.handleFileUpload(url)
                            }
                        }
                    case .failure(let error):
                        chatViewModel.errorMessage = "文件上传失败：\(error.localizedDescription)"
                    }
                }
                .fileImporter(
                    isPresented: $isShowingImagePicker,
                    allowedContentTypes: [.image],
                    allowsMultipleSelection: false
                ) { result in
                    switch result {
                    case .success(let urls):
                        if let url = urls.first,
                           let image = NSImage(contentsOf: url) {
                            Task {
                                await chatViewModel.handleImageUpload(image)
                            }
                        }
                    case .failure(let error):
                        chatViewModel.errorMessage = "图片上传失败：\(error.localizedDescription)"
                    }
                }
            }
        }
        .alert("提示", isPresented: .constant(chatViewModel.errorMessage != nil)) {
            Button("确定") {
                chatViewModel.errorMessage = nil
            }
        } message: {
            if let errorMessage = chatViewModel.errorMessage {
                Text(errorMessage)
            }
        }
    }
}

struct SystemMonitorView: View {
    @EnvironmentObject private var systemMonitor: SystemMonitor
    
    var body: some View {
        HStack(spacing: 16) {
            MonitorItemView(
                icon: "cpu",
                title: "CPU",
                value: String(format: "%.1f%%", systemMonitor.cpuUsage),
                color: .blue
            )
            
            MonitorItemView(
                icon: "memorychip",
                title: "内存",
                value: String(format: "%.1f%%", systemMonitor.memoryUsage),
                color: .green
            )
        }
    }
}

struct MonitorItemView: View {
    let icon: String
    let title: String
    let value: String
    let color: Color
    
    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: icon)
                .foregroundColor(color)
                .font(.caption)
            
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
            Text(value)
                .font(.system(.caption, design: .monospaced))
                .foregroundColor(color)
        }
    }
}

struct ConnectionPromptView: View {
    @EnvironmentObject private var chatViewModel: ChatViewModel
    
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "network.badge.shield.half.filled")
                .font(.system(size: 48))
                .foregroundColor(.secondary)
            Text("请先连接到 Ollama 服务器")
                .font(.headline)
            Button("重试连接") {
                Task {
                    await chatViewModel.checkConnection()
                }
            }
            .buttonStyle(.borderedProminent)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

struct ModelSelectionPromptView: View {
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "brain")
                .font(.system(size: 48))
                .foregroundColor(.secondary)
            Text("请选择一个模型")
                .font(.headline)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
} 