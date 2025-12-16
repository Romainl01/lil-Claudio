import SwiftUI

/// Bulle de message pour le chat (utilisateur ou assistant)
struct MessageBubble: View {
    let message: Message

    var body: some View {
        HStack(alignment: .bottom, spacing: Spacing.sm) {
            if message.role == .user {
                Spacer(minLength: 60) // Limite la largeur pour les messages utilisateur
            }

            VStack(alignment: message.role == .user ? .trailing : .leading, spacing: 4) {
                // Contenu du message
                Text(message.content)
                    .font(.bodyText)
                    .foregroundStyle(message.role == .user ? Color.textPrimary : Color.textNeutralDark)
                    .padding(.horizontal, Spacing.md)
                    .padding(.vertical, 12)
                    .background(
                        RoundedRectangle(cornerRadius: 18)
                            .fill(message.role == .user ?
                                  Color.neutralGray200.opacity(0.6) :
                                  Color.white.opacity(0.8))
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 18)
                            .stroke(Color.white.opacity(0.3), lineWidth: 1)
                    )

                // Timestamp
                Text(message.timestamp, format: .dateTime.hour().minute())
                    .font(.caption2)
                    .foregroundStyle(Color.textSecondary)
                    .padding(.horizontal, 4)
            }

            if message.role == .assistant {
                Spacer(minLength: 60) // Limite la largeur pour les messages assistant
            }
        }
        .padding(.horizontal, Spacing.md)
        .padding(.vertical, 4)
    }
}

// Preview pour tester le design
#Preview("Message Bubbles") {
    VStack(spacing: 16) {
        MessageBubble(message: Message(role: .user, content: "Hello! How are you?"))
        MessageBubble(message: Message(role: .assistant, content: "I'm doing well, thank you! How can I help you today?"))
        MessageBubble(message: Message(role: .user, content: "Can you explain quantum computing in simple terms?"))
    }
    .padding()
    .background(Color.surfaceLight)
}
