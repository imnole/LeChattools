# LeChat Tools

LeChat Tools 是一个基于 SwiftUI 开发的 macOS 原生聊天工具，专门设计用于与 Ollama 本地大语言模型进行交互。它提供了一个优雅、直观的用户界面，让您可以轻松地与各种 AI 模型进行对话。

![LeChat Tools Screenshot]

LeChat Tools 视图展示
<img width="943" alt="image" src="https://github.com/user-attachments/assets/49a75411-ffdc-43f6-b5a3-ddb4fcde1271" />
<img width="943" alt="image" src="https://github.com/user-attachments/assets/e66725cc-ada3-4bf3-87ba-5af1d33a98e5" />
<img width="943" alt="image" src="https://github.com/user-attachments/assets/d1fb5237-848c-4c8d-be9c-39dab9c10356" />
<img width="943" alt="image" src="https://github.com/user-attachments/assets/ab23d69e-0b61-4d8e-984d-19161da7c8b9" />
<img width="943" alt="image" src="https://github.com/user-attachments/assets/526b0073-98a3-464d-91d2-37d7cec7224d" />



## ✨ 主要特性

### 🤖 智能对话
- 支持多种 Ollama 模型
- 实时对话响应
- 支持多模态模型（图片分析）
- 文件分析功能

### 💡 智能界面
- 优雅的 macOS 原生界面
- 自动滚动和动画效果
- 清晰的对话历史记录
- 实时连接状态显示

### 🛠 系统工具
- 实时系统资源监控（CPU、内存使用率）
- 自动保存对话历史
- 可自定义 Ollama 服务器地址
- 快捷键支持

## 🔧 技术栈

- **开发语言**: Swift 5.9
- **UI 框架**: SwiftUI
- **目标平台**: macOS 14.0+
- **架构模式**: MVVM
- **状态管理**: @StateObject, @Published, @EnvironmentObject
- **网络层**: URLSession, async/await
- **数据持久化**: UserDefaults
- **其他技术**:
  - Combine 框架
  - Swift Concurrency
  - FileManager
  - Codable 协议

## 📦 系统要求

- macOS 14.0 或更高版本
- [Ollama](https://ollama.ai) 已安装并运行

## 🚀 快速开始

1. **安装 Ollama**
   ```bash
   curl -fsSL https://ollama.ai/install.sh | sh
   ```

2. **下载并运行 LeChat Tools**
   - 从 Releases 页面下载最新版本
   - 解压并将应用拖入应用程序文件夹
   - 启动应用

3. **首次使用设置**
   - 确保 Ollama 服务正在运行
   - 启动 LeChat Tools
   - 选择要使用的 AI 模型
   - 开始对话！

## 💬 基本使用

1. **新建对话**
   - 点击工具栏的 "+" 按钮
   - 或使用快捷键 ⌘N

2. **选择模型**
   - 点击工具栏的模型选择菜单
   - 从可用模型列表中选择

3. **发送消息**
   - 在输入框中输入消息
   - 按回车键发送
   - 使用 Shift + 回车换行

4. **文件分析**
   - 点击文件图标上传文件
   - 支持文本和 PDF 文件

5. **图片分析**
   - 点击图片图标上传图片
   - 仅支持多模态模型（如 llava）

## ⌨️ 快捷键

- `⌘N`: 新建对话
- `⌘,`: 打开设置
- `⌘W`: 关闭窗口
- `⌘Q`: 退出应用

## 🔄 自动化功能

- 自动保存对话历史
- 自动检测 Ollama 服务连接状态
- 自动滚动到最新消息
- 实时系统资源监控

## 🛡 隐私说明

- 所有对话数据仅保存在本地
- 不收集任何用户信息
- 所有 AI 处理均在本地完成

## 🤝 贡献

欢迎提交 Issue 和 Pull Request！

## 📄 许可证

MIT License

## 👨‍💻 作者

- 作者：杨乐乐
- 网站：www.leleit.cc
- 邮箱：noleit@icloud.com

## 🙏 致谢

- [Ollama](https://ollama.ai) - 提供本地 AI 模型支持
- [SwiftUI](https://developer.apple.com/xcode/swiftui/) - 提供现代化的 UI 框架 
