//
//  LeChattoolsApp.swift
//  LeChattools
//
//  Created by Le  on 2025/4/22.
//

import SwiftUI

@main
struct LeChattoolsApp: App {
    @StateObject private var chatViewModel = ChatViewModel()
    @StateObject private var systemMonitor = SystemMonitor()
    @StateObject private var errorHandler = ErrorHandler()
    @Environment(\.scenePhase) private var scenePhase
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(chatViewModel)
                .environmentObject(systemMonitor)
                .environmentObject(errorHandler)
                .alert("错误", isPresented: $errorHandler.showError) {
                    Button("确定") {
                        errorHandler.dismiss()
                    }
                } message: {
                    if let error = errorHandler.currentError {
                        Text(error.errorDescription ?? "未知错误")
                    }
                }
        }
        .windowStyle(.hiddenTitleBar)
        .windowToolbarStyle(.unified)
        .commands {
            CommandGroup(replacing: .newItem) {
                Button("新建对话") {
                    chatViewModel.clearChat()
                }
                .keyboardShortcut("n", modifiers: .command)
            }
            
            // CommandGroup(after: .appSettings) {
            //     Button("设置") {
            //         NSApp.sendAction(Selector(("showSettingsWindow:")), to: nil, from: nil)
            //     }
            //     .keyboardShortcut(",", modifiers: .command)
            // }
            
            CommandGroup(replacing: .appInfo) {
                Button("关于 LeChat Tools") {
                    NSApplication.shared.orderFrontStandardAboutPanel(
                        options: [
                            NSApplication.AboutPanelOptionKey.credits: NSAttributedString(
                                string: "作者：杨乐乐\n官网：www.leleit.cc\n邮箱：noleit@icloud.com",
                                attributes: [
                                    .font: NSFont.systemFont(ofSize: 11),
                                    .foregroundColor: NSColor.labelColor
                                ]
                            ),
                            NSApplication.AboutPanelOptionKey.version: "1.0"
                        ]
                    )
                }
            }
        }
        .onChange(of: scenePhase) { phase in
            switch phase {
            case .active:
                // 应用程序变为活动状态时重新连接
                Task {
                    await chatViewModel.checkConnection()
                }
            case .background:
                // 应用程序进入后台时清理资源
                systemMonitor.stopMonitoring()
            case .inactive:
                break
            @unknown default:
                break
            }
        }
        
        Settings {
            SettingsView()
                .environmentObject(chatViewModel)
                .environmentObject(errorHandler)
        }
    }
}
