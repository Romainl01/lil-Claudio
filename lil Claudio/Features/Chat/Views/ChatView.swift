import SwiftUI
import SwiftData

/// Écran principal du chat avec streaming LLM
struct ChatView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var viewModel: ChatViewModel?
    @State private var scrollProxy: ScrollViewProxy?
    @FocusState private var isInputFocused: Bool
    @State private var isVisible = false  // Pour fade-in au chargement

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
        .opacity(isVisible ? 1 : 0)
        .animation(.easeInOut(duration: 0.3), value: isVisible)
        .onAppear {
            if viewModel == nil {
                viewModel = ChatViewModel(modelContext: modelContext)
            }

            Task {
                // Attendre 400ms pour que les glass effects se chargent
                try? await Task.sleep(for: .milliseconds(400))
                isVisible = true

                // Auto-focus input après le fade-in (300ms d'animation + 100ms)
                try? await Task.sleep(for: .milliseconds(400))
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
        .contentShape(Rectangle())
        .onTapGesture {
            isInputFocused = false  // Dismiss keyboard when tapping header
        }
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
                .contentShape(Rectangle())
                .onTapGesture {
                    isInputFocused = false  // Dismiss keyboard when tapping empty area
                }
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
                        // Parse markdown en temps réel avec sélection native
                        if let attributedString = try? AttributedString(markdown: output, options: AttributedString.MarkdownParsingOptions(interpretedSyntax: .inlineOnlyPreservingWhitespace)) {
                            SelectableText(
                                attributedText: attributedString,
                                font: .systemFont(ofSize: 16),
                                textColor: UIColor(Color.textNeutralDark)
                            )
                        } else {
                            SelectableText(
                                text: output,
                                font: .systemFont(ofSize: 16),
                                textColor: UIColor(Color.textNeutralDark)
                            )
                        }
                    } else {
                        Text("")
                    }
                }
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
            // TextField avec placeholder gris + bouton INSIDE (comme iMessage!)
            TextField(
                "",
                text: Binding(
                    get: { viewModel?.inputText ?? "" },
                    set: { viewModel?.inputText = $0 }
                ),
                prompt: Text("message").foregroundStyle(Color.gray.opacity(0.4)),
                axis: .vertical
            )
            .textFieldStyle(.plain)
            .font(.inputText)
            .foregroundStyle(Color.textPrimary)
            .tint(Color.accentPrimary)
            .lineLimit(1...5)
            .fixedSize(horizontal: false, vertical: true)
            .focused($isInputFocused)
            .onSubmit {
                sendMessage()
            }

            // Send/Stop button INSIDE le champ de texte
            if let vm = viewModel {
                if vm.isGenerating {
                    // Stop button
                    Button(action: { vm.cancelGeneration() }) {
                        Image(systemName: SFSymbols.stopSquare)
                            .font(.system(size: 20, weight: .semibold))
                            .foregroundStyle(Color.textButtonIcon)
                            .frame(width: 32, height: 32)
                    }
                    .transition(.scale.combined(with: .opacity))
                } else {
                    // Send button
                    Button(action: sendMessage) {
                        Image(systemName: SFSymbols.sendArrow)
                            .font(.system(size: 20, weight: .semibold))
                            .foregroundStyle(vm.inputText.isEmpty ? Color.textSecondary.opacity(0.5) : Color.accentPrimary)
                            .frame(width: 32, height: 32)
                    }
                    .disabled(vm.inputText.isEmpty)
                    .transition(.scale.combined(with: .opacity))
                }
            }
        }
        .padding(.horizontal, Spacing.md)
        .padding(.vertical, 12)
        .background {
            // Liquid Glass Effect (surface légère pour que le glass fonctionne)
            RoundedRectangle(cornerRadius: Dimensions.cornerRadiusLarge, style: .continuous)
                .fill(Color.white.opacity(0.01))
                .glassEffect(.regular.interactive())
        }
        .clipShape(RoundedRectangle(cornerRadius: Dimensions.cornerRadiusLarge, style: .continuous))
        .overlay {
            // Bordure subtile (radius constant: Dimensions.cornerRadiusLarge)
            RoundedRectangle(cornerRadius: Dimensions.cornerRadiusLarge, style: .continuous)
                .strokeBorder(
                    Color.white.opacity(0.3),
                    lineWidth: 1
                )
        }
        .shadow(color: Color.black.opacity(0.08), radius: 10, x: 0, y: 4)
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
