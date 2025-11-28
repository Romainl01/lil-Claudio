# Instructions for Claude Code - Local LLM Chat iOS App

## 🎯 How to Use This File

### For Claude Code
**You are Claude Code, an AI assistant helping Romain build an iOS app.**

**CRITICAL: Read this entire file before starting any work.**

This file contains:
1. TDD methodology (mandatory)
2. Modern SwiftUI patterns (iOS 17+)
3. MLX integration guide
4. Design system specifications
5. Common bugs to avoid
6. Testing examples

**At the start of each session:**
1. Read `plan.md` to understand the current phase
2. Read this file to understand best practices
3. Ask Romain which step you're working on
4. Write tests FIRST (TDD), then implement

**For Romain:**
When starting Claude Code, your first prompt should be:
```
Read plan.md and claude.md before we start. 
We're working on Phase X, Step Y. Follow TDD approach.
```

---

## 📋 Project Context

Building an iOS/macOS chat app with local LLM (Llama 3.2 1B) using SwiftUI, MLX, and SwiftData. Approach is **Test-Driven Development (TDD)** with minimal liquid glass design.

**V1 Scope (Ultra-Minimal):**
- Single chat thread (no conversation history)
- Model download on first launch
- Send message + streaming response
- System prompt customization
- Liquid glass design

---

## 🎯 Core Development Principles

### 1. Test-Driven Development (TDD) - MANDATORY

**STRICT PROCESS for EVERY feature:**

1. **RED**: Write the test first (it must fail)
2. **GREEN**: Write minimal code to pass the test
3. **REFACTOR**: Improve code without breaking tests

**TDD Cycle Example:**

```swift
// 1. RED - Write failing test
@Test
func testCreateMessage() throws {
    let message = Message(role: .user, content: "Test")
    #expect(message.content == "Test")
    #expect(message.role == .user)
}

// 2. GREEN - Minimal implementation
@Model
class Message {
    var role: Role
    var content: String
    
    init(role: Role, content: String) {
        self.role = role
        self.content = content
    }
}

// 3. REFACTOR - Add features without breaking test
@Model
class Message {
    @Attribute(.unique) var id: UUID
    var role: Role
    var content: String
    var timestamp: Date
    
    init(role: Role, content: String) {
        self.id = UUID()
        self.role = role
        self.content = content
        self.timestamp = Date()
    }
}
```

**Types of Tests:**

- **Unit tests**: Business logic (ViewModels, models)
- **Integration tests**: Component interactions (ChatViewModel + LLMEvaluator)
- **UI tests**: Critical user flows (create conversation, send message)

**Testing Framework:** Swift Testing (iOS 17+, more modern than XCTest)

**Example ChatViewModel Test:**

```swift
import Testing
@testable import LocalLLMChat

@Suite("ChatViewModel Tests")
struct ChatViewModelTests {
    
    @Test("Send message adds to messages array")
    @MainActor
    func testSendMessage() async throws {
        let config = ModelConfiguration(inMemory: true)
        let container = try ModelContainer(for: Message.self, configurations: config)
        let viewModel = ChatViewModel(modelContext: container.mainContext)
        
        await viewModel.sendMessage("Hello")
        
        let messages = try container.mainContext.fetch(FetchDescriptor<Message>())
        #expect(messages.count == 1)
        #expect(messages.first?.content == "Hello")
        #expect(messages.first?.role == .user)
    }
    
    @Test("Empty message is not sent")
    @MainActor
    func testEmptyMessagePrevention() async {
        let viewModel = ChatViewModel(modelContext: mockContext)
        
        await viewModel.sendMessage("")
        
        #expect(viewModel.messages.isEmpty)
    }
}
```

---

### 2. Modern SwiftUI Architecture (iOS 17+)

**Use these patterns:**

#### @Observable (instead of ObservableObject)

```swift
// ✅ CORRECT (iOS 17+)
import Observation

@Observable
@MainActor
class ChatViewModel {
    var messages: [Message] = []
    var isGenerating = false
    var currentInput = ""
    
    func sendMessage(_ text: String) async {
        // Implementation
    }
}

// In View
struct ChatView: View {
    @State private var viewModel = ChatViewModel()
    
    var body: some View {
        // viewModel updates automatically
    }
}
```

#### SwiftData (instead of CoreData)

```swift
// ✅ CORRECT - SwiftData models
import SwiftData

@Model
class Message {
    @Attribute(.unique) var id: UUID
    var role: Role
    var content: String
    var timestamp: Date
    
    init(role: Role, content: String) {
        self.id = UUID()
        self.role = role
        self.content = content
        self.timestamp = Date()
    }
}

enum Role: String, Codable {
    case user
    case assistant
}

// In App
@main
struct LocalLLMChatApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(for: Message.self)
    }
}

// In View
struct ChatView: View {
    @Query(sort: \Message.timestamp) var messages: [Message]
    @Environment(\.modelContext) private var modelContext
    
    var body: some View {
        // Use messages and modelContext
    }
}
```

#### @AppStorage for Preferences

```swift
// ✅ CORRECT - Simple persistence
@AppStorage("systemPrompt") var systemPrompt = "you are a helpful assistant"
@AppStorage("isModelDownloaded") var isModelDownloaded = false

// In View
struct SettingsView: View {
    @AppStorage("systemPrompt") private var systemPrompt = "you are a helpful assistant"
    
    var body: some View {
        TextEditor(text: $systemPrompt)
    }
}
```

---

### 3. MLX Integration - Step by Step

#### Step 1: Add Packages

In Xcode:
1. File > Add Package Dependencies
2. Add:
   - `https://github.com/ml-explore/mlx-swift` (MLX)
   - `https://github.com/ml-explore/mlx-swift-examples` (select MLXLLM, MLXLMCommon, MLXRandom)

#### Step 2: Model Configuration

```swift
import MLXLMCommon

extension ModelConfiguration {
    static let llama_3_2_1b_4bit = ModelConfiguration(
        id: "mlx-community/Llama-3.2-1B-Instruct-4bit"
    )
    
    static var defaultModel: ModelConfiguration {
        llama_3_2_1b_4bit
    }
    
    var modelSize: Decimal {
        0.7 // GB
    }
}
```

#### Step 3: LLMEvaluator (Main Inference Class)

```swift
import MLX
import MLXLLM
import MLXLMCommon
import MLXRandom

@Observable
@MainActor
class LLMEvaluator {
    var running = false
    var output = ""
    var progress = 0.0
    var error: String?
    
    private var modelContainer: ModelContainer?
    
    let maxTokens = 2048
    let generateParameters = GenerateParameters(temperature: 0.7)
    let displayEveryNTokens = 4 // Streaming refresh rate
    
    // Load model (once)
    func load() async throws {
        guard modelContainer == nil else { return }
        
        // Set GPU cache limit BEFORE loading
        MLX.GPU.set(cacheLimit: 20 * 1024 * 1024)
        
        let config = ModelConfiguration.defaultModel
        
        modelContainer = try await LLMModelFactory.shared.loadContainer(
            configuration: config
        ) { [weak self] progress in
            Task { @MainActor in
                self?.progress = progress.fractionCompleted
            }
        }
    }
    
    // Generate response
    func generate(messages: [Message], systemPrompt: String) async -> String {
        guard !running, let container = modelContainer else { 
            return ""
        }
        
        running = true
        output = ""
        error = nil
        
        // Build prompt history
        var promptHistory: [[String: String]] = [
            ["role": "system", "content": systemPrompt]
        ]
        
        for message in messages {
            promptHistory.append([
                "role": message.role.rawValue,
                "content": message.content
            ])
        }
        
        do {
            // Random seed for variety
            MLXRandom.seed(UInt64(Date.timeIntervalSinceReferenceDate * 1000))
            
            let result = try await container.perform { context in
                let input = try await context.processor.prepare(
                    input: .init(messages: promptHistory)
                )
                
                return try MLXLMCommon.generate(
                    input: input,
                    parameters: generateParameters,
                    context: context
                ) { tokens in
                    // CRITICAL: Check tokens.count > 0 before decoding
                    guard tokens.count > 0 else { return .more }
                    
                    // Streaming: update every N tokens
                    if tokens.count % displayEveryNTokens == 0 {
                        let text = context.tokenizer.decode(tokens: tokens)
                        Task { @MainActor in
                            self.output = text
                        }
                    }
                    
                    // Stop condition
                    if tokens.count >= maxTokens {
                        return .stop
                    } else {
                        return .more
                    }
                }
            }
            
            output = result.output
            
        } catch {
            self.error = error.localizedDescription
            output = "Error: \(error.localizedDescription)"
        }
        
        running = false
        return output
    }
    
    // Cancel ongoing generation
    func cancel() {
        running = false
    }
}
```

#### Step 4: ChatViewModel (Orchestration)

```swift
@Observable
@MainActor
class ChatViewModel {
    var inputText = ""
    var isGenerating = false
    var messages: [Message] = []
    
    private let llmEvaluator = LLMEvaluator()
    private let modelContext: ModelContext
    
    @AppStorage("systemPrompt") private var systemPrompt = "you are a helpful assistant"
    
    init(modelContext: ModelContext) {
        self.modelContext = modelContext
        loadMessages()
    }
    
    func loadMessages() {
        let descriptor = FetchDescriptor<Message>(sortBy: [SortDescriptor(\.timestamp)])
        messages = (try? modelContext.fetch(descriptor)) ?? []
    }
    
    func sendMessage(_ text: String? = nil) async {
        let messageText = text ?? inputText
        guard !messageText.isEmpty else { return }
        
        // Add user message
        let userMessage = Message(role: .user, content: messageText)
        modelContext.insert(userMessage)
        try? modelContext.save()
        
        inputText = ""
        loadMessages()
        isGenerating = true
        
        // Generate response
        let response = await llmEvaluator.generate(
            messages: messages,
            systemPrompt: systemPrompt
        )
        
        // Add assistant message
        let assistantMessage = Message(role: .assistant, content: response)
        modelContext.insert(assistantMessage)
        try? modelContext.save()
        
        loadMessages()
        isGenerating = false
    }
    
    func clearChat() {
        for message in messages {
            modelContext.delete(message)
        }
        try? modelContext.save()
        loadMessages()
    }
}
```

---

## 🎨 Design System - Liquid Glass

### Design Principles

1. **Glassmorphism**: Semi-transparent backgrounds with blur
2. **Depth**: Soft shadows, layered components
3. **Minimalism**: No unnecessary decorations
4. **Consistency**: Same visual language throughout

### DesignSystem.swift

```swift
import SwiftUI

// MARK: - Colors
extension Color {
    static let glassBackground = Color.white.opacity(0.1)
    static let glassBorder = Color.white.opacity(0.2)
    static let primaryText = Color.primary
    static let secondaryText = Color.secondary
    static let accentBlue = Color.blue.opacity(0.8)
}

// MARK: - View Modifiers
struct GlassCardModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(.ultraThinMaterial)
                    .shadow(color: .black.opacity(0.05), radius: 10, x: 0, y: 5)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(Color.glassBorder, lineWidth: 1)
            )
    }
}

struct LiquidButtonModifier: ViewModifier {
    var isEnabled: Bool
    
    func body(content: Content) -> some View {
        content
            .padding(.horizontal, 20)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(isEnabled ? Color.accentBlue : Color.gray.opacity(0.3))
            )
            .foregroundStyle(.white)
            .animation(.easeInOut(duration: 0.2), value: isEnabled)
    }
}

extension View {
    func glassCard() -> some View {
        modifier(GlassCardModifier())
    }
    
    func liquidButton(enabled: Bool = true) -> some View {
        modifier(LiquidButtonModifier(isEnabled: enabled))
    }
}

// MARK: - Typography
extension Font {
    static let chatMessage = Font.system(size: 16, weight: .regular, design: .default)
    static let chatTimestamp = Font.system(size: 12, weight: .regular, design: .default)
}

// MARK: - Spacing
enum Spacing {
    static let xs: CGFloat = 4
    static let sm: CGFloat = 8
    static let md: CGFloat = 16
    static let lg: CGFloat = 24
    static let xl: CGFloat = 32
}
```

### Core Components

#### MessageBubble

```swift
struct MessageBubble: View {
    let message: Message
    
    var body: some View {
        HStack {
            if message.role == .user {
                Spacer()
            }
            
            VStack(alignment: message.role == .user ? .trailing : .leading, spacing: 4) {
                Text(message.content)
                    .font(.chatMessage)
                    .padding(Spacing.md)
                    .background(
                        RoundedRectangle(cornerRadius: 18)
                            .fill(message.role == .user ? 
                                  Color.accentBlue.opacity(0.15) : 
                                  Color(.systemGray6))
                    )
                
                Text(message.timestamp, format: .dateTime.hour().minute())
                    .font(.chatTimestamp)
                    .foregroundStyle(.secondary)
                    .padding(.horizontal, Spacing.sm)
            }
            .frame(maxWidth: 280, alignment: message.role == .user ? .trailing : .leading)
            
            if message.role == .assistant {
                Spacer()
            }
        }
        .padding(.horizontal, Spacing.md)
    }
}

#Preview {
    VStack(spacing: 16) {
        MessageBubble(message: Message(role: .user, content: "Hello!"))
        MessageBubble(message: Message(role: .assistant, content: "Hi there!"))
    }
}
```

#### ChatInputField

```swift
struct ChatInputField: View {
    @Binding var text: String
    var onSend: () -> Void
    var isGenerating: Bool
    
    var body: some View {
        HStack(spacing: Spacing.sm) {
            TextField("Type a message...", text: $text, axis: .vertical)
                .textFieldStyle(.plain)
                .padding(Spacing.md)
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .fill(.ultraThinMaterial)
                )
                .lineLimit(1...5)
                .onSubmit(onSend)
            
            Button(action: onSend) {
                Image(systemName: "arrow.up.circle.fill")
                    .font(.system(size: 32))
                    .foregroundStyle(text.isEmpty || isGenerating ? .gray : .blue)
            }
            .disabled(text.isEmpty || isGenerating)
        }
        .padding(Spacing.md)
        .background(.ultraThinMaterial)
    }
}
```

---

## 🛠️ iOS Best Practices

### 1. Memory Management

```swift
// ✅ CORRECT - Use [weak self] in closures
Task { [weak self] in
    guard let self else { return }
    await self.loadModel()
}

// ✅ CORRECT - Release model on low memory
func applicationDidReceiveMemoryWarning() {
    modelContainer = nil
    // Model will reload on next use
}
```

### 2. Concurrency (async/await)

```swift
// ✅ CORRECT - All UI updates on @MainActor
@MainActor
class ChatViewModel: ObservableObject {
    func sendMessage() async {
        // Code runs on main thread
    }
}

// ✅ CORRECT - Heavy operations on background
func loadModel() async {
    await Task.detached {
        // Heavy operation on background thread
    }.value
}
```

### 3. Error Handling

```swift
// ✅ CORRECT - Handle errors with do-catch
func generate() async {
    do {
        let result = try await container.perform { context in
            // ...
        }
    } catch {
        // Log error
        print("Generation error: \(error)")
        
        // Show to user
        self.error = error.localizedDescription
        
        // Optional: Send to crash reporting
        // Analytics.logError(error)
    }
}
```

### 4. Performance

```swift
// ✅ CORRECT - Lazy loading for heavy views
struct ChatView: View {
    @Query var messages: [Message]
    
    var body: some View {
        ScrollView {
            LazyVStack { // Lazy for performance
                ForEach(messages) { message in
                    MessageBubble(message: message)
                }
            }
        }
    }
}

// ✅ CORRECT - Limit updates with .onChange
struct ChatView: View {
    @State private var viewModel = ChatViewModel()
    
    var body: some View {
        ScrollView {
            LazyVStack {
                ForEach(messages) { message in
                    MessageBubble(message: message)
                }
            }
        }
        .onChange(of: viewModel.messages.count) { _, _ in
            // Only scroll when message count changes
            scrollToBottom()
        }
    }
}
```

---

## 🧪 Testing - Complete Examples

### Test 1: Message Creation

```swift
@Suite("Message Model Tests")
struct MessageTests {
    
    @Test("Message created with correct properties")
    func testMessageCreation() {
        let message = Message(role: .user, content: "Test message")
        
        #expect(message.role == .user)
        #expect(message.content == "Test message")
        #expect(!message.id.uuidString.isEmpty)
        #expect(message.timestamp <= Date())
    }
}
```

### Test 2: ChatViewModel

```swift
@Suite("ChatViewModel Tests")
struct ChatViewModelTests {
    
    @Test("Send message adds user message")
    @MainActor
    func testSendMessage() async throws {
        let config = ModelConfiguration(inMemory: true)
        let container = try ModelContainer(for: Message.self, configurations: config)
        
        let viewModel = ChatViewModel(modelContext: container.mainContext)
        viewModel.inputText = "Hello world"
        
        await viewModel.sendMessage()
        
        #expect(viewModel.messages.count >= 1)
        #expect(viewModel.messages.first?.content == "Hello world")
        #expect(viewModel.messages.first?.role == .user)
        #expect(viewModel.inputText.isEmpty) // Input cleared after send
    }
    
    @Test("Empty message not sent")
    @MainActor
    func testEmptyMessagePrevention() async throws {
        let config = ModelConfiguration(inMemory: true)
        let container = try ModelContainer(for: Message.self, configurations: config)
        
        let viewModel = ChatViewModel(modelContext: container.mainContext)
        viewModel.inputText = ""
        
        await viewModel.sendMessage()
        
        #expect(viewModel.messages.isEmpty)
    }
    
    @Test("Clear chat removes all messages")
    @MainActor
    func testClearChat() async throws {
        let config = ModelConfiguration(inMemory: true)
        let container = try ModelContainer(for: Message.self, configurations: config)
        
        let viewModel = ChatViewModel(modelContext: container.mainContext)
        
        // Add test messages
        let msg1 = Message(role: .user, content: "Test 1")
        let msg2 = Message(role: .assistant, content: "Test 2")
        container.mainContext.insert(msg1)
        container.mainContext.insert(msg2)
        try container.mainContext.save()
        
        viewModel.loadMessages()
        #expect(viewModel.messages.count == 2)
        
        viewModel.clearChat()
        #expect(viewModel.messages.isEmpty)
    }
}
```

### Test 3: LLMEvaluator (with mock)

```swift
@Suite("LLMEvaluator Tests")
struct LLMEvaluatorTests {
    
    @Test("Progress updates during loading")
    @MainActor
    func testLoadingProgress() async {
        let evaluator = LLMEvaluator()
        
        #expect(evaluator.progress == 0.0)
        
        // Note: Real test would require mock of LLMModelFactory
        // to avoid downloading actual model
    }
    
    @Test("Running state toggles correctly")
    @MainActor
    func testRunningState() {
        let evaluator = LLMEvaluator()
        
        #expect(evaluator.running == false)
        
        evaluator.running = true
        #expect(evaluator.running == true)
        
        evaluator.cancel()
        #expect(evaluator.running == false)
    }
}
```

---

## 🚨 Common Errors to Avoid

### ❌ DON'T DO

```swift
// ❌ Call UI from background thread
Task {
    let result = await heavyOperation()
    self.result = result // CRASH if not @MainActor
}

// ❌ Strong retain self in long closures
Task {
    await self.longOperation() // Memory leak if self never released
}

// ❌ Forget to save SwiftData context
modelContext.insert(message)
// Forgot: try? modelContext.save()

// ❌ Create multiple ModelContainers
// Use the one injected by .modelContainer(for:)

// ❌ Decode tokens without checking count
let text = context.tokenizer.decode(tokens: tokens) // CRASH if tokens.isEmpty
```

### ✅ DO

```swift
// ✅ Always use @MainActor for UI
@MainActor
func updateUI() {
    self.result = newValue
}

// ✅ Weak self in closures
Task { [weak self] in
    guard let self else { return }
    await self.longOperation()
}

// ✅ Save after important modifications
modelContext.insert(message)
try? modelContext.save()

// ✅ One ModelContainer per app
// Defined in YourApp.swift with .modelContainer(for:)

// ✅ Check before decoding
guard tokens.count > 0 else { return .more }
let text = context.tokenizer.decode(tokens: tokens)
```

---

## 🐛 Critical Bugs to Watch For

### MLX Specific

1. **GPU cache must be set BEFORE loading model**
   ```swift
   MLX.GPU.set(cacheLimit: 20 * 1024 * 1024) // BEFORE loadContainer
   ```

2. **Progress callback must use @MainActor**
   ```swift
   Task { @MainActor in
       self.progress = progress.fractionCompleted
   }
   ```

3. **Token decoding can crash with empty array**
   ```swift
   guard tokens.count > 0 else { return .more }
   let text = context.tokenizer.decode(tokens: tokens)
   ```

4. **Model takes ~1-2 GB RAM**
   - Test on devices with <4 GB RAM
   - Handle low memory warnings
   - Release model: `modelContainer = nil`

### SwiftData Specific

1. **@Attribute(.unique) required on id**
   ```swift
   @Attribute(.unique) var id: UUID // Prevents duplicates
   ```

2. **Save after inserts/deletes**
   ```swift
   modelContext.insert(message)
   try? modelContext.save() // Don't forget!
   ```

3. **One ModelContext per view hierarchy**
   - Pass from parent via `@Environment(\.modelContext)`
   - Don't create new contexts unnecessarily

### SwiftUI Specific

1. **@Observable requires Observation import**
   ```swift
   import Observation // Don't forget!
   ```

2. **Don't mix @Observable with ObservableObject**
   - Use one pattern, not both

3. **LazyVStack for long lists**
   ```swift
   LazyVStack { ... } // Not VStack for 100+ items
   ```

---

## 📚 Useful Resources

- [MLX Swift Examples](https://github.com/ml-explore/mlx-swift-examples) - Official repo
- [Fullmoon source](https://github.com/mainframecomputer/fullmoon-ios) - Architecture reference
- [SwiftData docs](https://developer.apple.com/documentation/swiftdata) - Apple docs
- [Swift Testing](https://developer.apple.com/documentation/testing) - Testing framework

---

## 💡 Tips for Claude Code

- **Always write tests BEFORE code** (strict TDD)
- **Comment code in French** for Romain (but variable names in English)
- **Propose alternatives** if approach seems complex
- **Use SwiftUI Previews** to validate components visually
- **Log important steps** for debugging (`print()` or `os_log`)
- **Follow Swift conventions**: CamelCase, descriptive names
- **Favor simplicity**: MVP first, optimization later
- **Ask clarifying questions** when requirements are ambiguous

---

## ✅ Pre-Commit Checklist

Before considering any step "done":

- [ ] All tests pass (⌘U in Xcode)
- [ ] No warnings in console
- [ ] Code compiles on iPhone + iPad simulators
- [ ] SwiftUI Previews work
- [ ] Code follows Swift conventions
- [ ] Comments are up to date
- [ ] No dead code (commented or unused)
- [ ] Feature works as expected on real device

---

## 🎬 Starting a Session

**Template prompt for Romain:**

```
Read plan.md and claude.md.

We're working on Phase X, Step Y: [brief description]

Follow TDD approach:
1. Write failing test first
2. Implement minimal code to pass
3. Refactor if needed

Let's start with the test.
```

---

Good luck building! 🚀
