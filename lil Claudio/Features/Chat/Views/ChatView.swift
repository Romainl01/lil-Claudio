import SwiftUI
import SwiftData

/// Écran principal du chat avec streaming LLM
struct ChatView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var viewModel: ChatViewModel?
    @State private var scrollProxy: ScrollViewProxy?
    @FocusState private var isInputFocused: Bool

    var body: some View {
        ZStack {
            // Fond
            Color.surfaceLight
                .ignoresSafeArea()

            VStack(spacing: 0) {
                // Header
                header

                // Message List
                messageList

                // Input Area
                inputArea
                    .padding(.bottom, Spacing.md)
            }
        }
        .onAppear {
            if viewModel == nil {
                viewModel = ChatViewModel(modelContext: modelContext)
            }

            // Auto-focus input avec délai de 300ms
            Task {
                try? await Task.sleep(for: .milliseconds(300))
                isInputFocused = true
            }
        }
    }

    // MARK: - Header
    private var header: some View {
        HStack {
            // Menu button
            GlassButton(icon: SFSymbols.menuIcon) {
                // TODO: Add menu action later
            }

            Spacer()

            // Title
            Text("chat")
                .font(.headerTitle)
                .foregroundStyle(Color.textNeutralDark)

            Spacer()

            // Help button
            GlassButton(icon: SFSymbols.helpIcon) {
                // TODO: Add help action later
            }
        }
        .padding(.horizontal, Spacing.md)
        .padding(.vertical, Spacing.sm)
    }

    // MARK: - Message List
    private var messageList: some View {
        Group {
            if let vm = viewModel, vm.messages.isEmpty && !vm.isGenerating {
                // Empty state: icône centrée (sans ScrollView)
                VStack {
                    Spacer()

                    Image(systemName: "wand.and.sparkles")
                        .font(.system(size: 48))
                        .foregroundStyle(Color.textSecondary.opacity(0.3))
                        .frame(maxWidth: .infinity)

                    Spacer()
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                // Messages: ScrollView avec ancrage en bas
                ScrollViewReader { proxy in
                    ScrollView {
                        LazyVStack(spacing: Spacing.md) {
                            if let vm = viewModel {
                                ForEach(vm.messages) { message in
                                    MessageBubble(message: message)
                                        .id(message.id)
                                }

                                // Streaming response bubble (pendant la génération)
                                if vm.isGenerating && !vm.streamingOutput.isEmpty {
                                    streamingBubble
                                        .id("streaming")
                                        .transition(.opacity.combined(with: .scale(scale: 0.95)))
                                }
                            }
                        }
                        .padding(.top, Spacing.md)
                        .animation(.easeInOut(duration: 0.2), value: viewModel?.streamingOutput)
                    }
                    .defaultScrollAnchor(.bottom)
                    .onAppear {
                        scrollProxy = proxy
                    }
                }
            }
        }
    }

    // MARK: - Streaming Bubble
    private var streamingBubble: some View {
        HStack(alignment: .bottom, spacing: Spacing.sm) {
            VStack(alignment: .leading, spacing: 4) {
                // Parse markdown en temps réel pendant le streaming avec animation
                Group {
                    if let output = viewModel?.streamingOutput {
                        // Test SANS preprocessing - voir si markdown gère les \n nativement
                        if let attributedString = try? AttributedString(markdown: output, options: AttributedString.MarkdownParsingOptions(interpretedSyntax: .inlineOnlyPreservingWhitespace)) {
                            Text(attributedString)
                        } else {
                            Text(output)
                        }
                    } else {
                        Text("")
                    }
                }
                .font(.bodyText)
                .foregroundStyle(Color.textNeutralDark)
                .animation(.easeInOut(duration: 0.15), value: viewModel?.streamingOutput)
                .padding(.horizontal, Spacing.md)
                .padding(.vertical, 12)
                .background(
                    RoundedRectangle(cornerRadius: 18)
                        .fill(Color.white.opacity(0.8))
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 18)
                        .stroke(Color.white.opacity(0.3), lineWidth: 1)
                )

                // Indicateur de frappe
                Text("typing...")
                    .font(.caption2)
                    .foregroundStyle(Color.textSecondary)
                    .padding(.horizontal, 4)
            }

            Spacer(minLength: 60)
        }
        .padding(.horizontal, Spacing.md)
        .padding(.vertical, 4)
    }

    // MARK: - Input Area
    private var inputArea: some View {
        HStack(spacing: Spacing.sm) {
            // Text field avec liquid glass
            TextField("message", text: Binding(
                get: { viewModel?.inputText ?? "" },
                set: { viewModel?.inputText = $0 }
            ), axis: .vertical)
            .textFieldStyle(.plain)
            .font(.inputText)
            .foregroundStyle(Color.textPrimary)
            .tint(Color.textSecondary) // Couleur du placeholder
            .padding(.horizontal, Spacing.md)
            .padding(.vertical, 14)
            .lineLimit(1...6)
            .glassEffect(.regular.interactive())
            .clipShape(RoundedRectangle(cornerRadius: Dimensions.cornerRadiusLarge))
            .focused($isInputFocused)
            .onSubmit {
                sendMessage()
            }

            // Send or Stop button
            if let vm = viewModel {
                if vm.isGenerating {
                    // Stop button
                    GlassButton(icon: SFSymbols.stopSquare, size: Dimensions.buttonSize) {
                        vm.cancelGeneration()
                    }
                    .transition(.scale.combined(with: .opacity))
                } else {
                    // Send button
                    GlassButton(
                        icon: SFSymbols.sendArrow,
                        size: Dimensions.buttonSize,
                        isEnabled: !(vm.inputText.isEmpty)
                    ) {
                        sendMessage()
                    }
                    .transition(.scale.combined(with: .opacity))
                }
            }
        }
        .padding(.horizontal, Spacing.md)
        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: viewModel?.isGenerating)
    }

    // MARK: - Actions
    private func sendMessage() {
        guard let vm = viewModel, !vm.inputText.isEmpty else { return }

        Task {
            await vm.sendMessage()

            // Scroll to bottom after sending
            withAnimation {
                if let lastMessage = vm.messages.last {
                    scrollProxy?.scrollTo(lastMessage.id, anchor: .bottom)
                } else if vm.isGenerating {
                    scrollProxy?.scrollTo("streaming", anchor: .bottom)
                }
            }
        }

        // Dismiss keyboard
        isInputFocused = false
    }
}

// MARK: - Glass Button Component
struct GlassButton: View {
    let icon: String
    var size: CGFloat = Dimensions.headerButtonSize
    var isEnabled: Bool = true
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Image(systemName: icon)
                .font(.system(size: size * 0.45, weight: .semibold))
                .foregroundStyle(isEnabled ? Color.textButtonIcon : Color.textSecondary.opacity(0.5))
                .frame(width: size, height: size)
        }
        .glassEffect(.regular.interactive())
        .disabled(!isEnabled)
    }
}

// Preview
#Preview("ChatView - Empty") {
    ChatView()
        .modelContainer(for: Message.self, inMemory: true)
}

#Preview("ChatView - With Messages") {
    let container = try! ModelContainer(for: Message.self, configurations: .init(isStoredInMemoryOnly: true))

    // Add sample messages
    let msg1 = Message(role: .user, content: "Hello!")
    let msg2 = Message(role: .assistant, content: "Hi there! How can I help you today?")
    container.mainContext.insert(msg1)
    container.mainContext.insert(msg2)

    return ChatView()
        .modelContainer(container)
}
