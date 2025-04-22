import SwiftUI

struct MessageView: View {
    let message: ChatMessage
    @State private var isHovered = false
    
    var body: some View {
        HStack {
            if message.isUser {
                Spacer()
            }
            
            VStack(alignment: message.isUser ? .trailing : .leading, spacing: 4) {
                HStack(alignment: .top, spacing: 8) {
                    if !message.isUser {
                        if message.isThinking {
                            Image(systemName: "brain.head.profile")
                                .foregroundColor(.purple)
                                .font(.system(size: 16))
                                .rotationEffect(.degrees(isHovered ? 360 : 0))
                                .animation(
                                    Animation.linear(duration: 2)
                                        .repeatForever(autoreverses: false),
                                    value: isHovered
                                )
                        } else {
                            Image(systemName: "brain")
                                .foregroundColor(.purple)
                                .font(.system(size: 16))
                        }
                    }
                    
                    if message.isThinking {
                        ThinkingBubbleView()
                    } else {
                        Text(message.content)
                            .padding()
                            .background(
                                message.isUser ? 
                                    Color.blue.opacity(0.2) : 
                                    Color.gray.opacity(0.2)
                            )
                            .cornerRadius(10)
                            .shadow(
                                color: Color.black.opacity(0.1),
                                radius: isHovered ? 4 : 0,
                                x: 0,
                                y: isHovered ? 2 : 0
                            )
                    }
                    
                    if message.isUser {
                        Image(systemName: "person.circle.fill")
                            .foregroundColor(.blue)
                            .font(.system(size: 16))
                    }
                }
                
                Text(message.timestamp, style: .time)
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
            
            if !message.isUser {
                Spacer()
            }
        }
        .padding(.horizontal)
        .contentShape(Rectangle())
        .onHover { hovering in
            withAnimation(.easeInOut(duration: 0.2)) {
                isHovered = hovering
            }
        }
        .onAppear {
            if message.isThinking {
                isHovered = true
            }
        }
    }
}

struct ThinkingBubbleView: View {
    @State private var isAnimating = false
    
    var body: some View {
        HStack(spacing: 12) {
            ThinkingView()
            
            HStack(spacing: 4) {
                ForEach(0..<3) { index in
                    Circle()
                        .fill(Color.secondary)
                        .frame(width: 6, height: 6)
                        .scaleEffect(isAnimating ? 1.2 : 0.8)
                        .animation(
                            Animation.easeInOut(duration: 0.6)
                                .repeatForever()
                                .delay(0.2 * Double(index)),
                            value: isAnimating
                        )
                }
            }
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 12)
        .background(Color.gray.opacity(0.1))
        .cornerRadius(16)
        .onAppear {
            isAnimating = true
        }
    }
} 