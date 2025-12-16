# Instructions for Claude Code - Local LLM Chat iOS App

## 🎯 How to Use This File

### For Claude Code
**You are Claude Code, an AI assistant helping Romain build an iOS app.**

**CRITICAL: Read this entire file before starting any work.**

**🆕 Updated with [SwiftAgents](https://github.com/twostraws/SwiftAgents) best practices:**
- iOS 26+ target (modern liquid glass APIs)
- Modern SwiftUI APIs (foregroundStyle, clipShape, Button with systemImage, etc.)
- SwiftData CloudKit compatibility (no @Attribute(.unique))
- Minimal UI testing approach (focus on unit tests)
- SwiftLint integration for code quality
- Project organization by features

This file contains:
1. TDD methodology (mandatory)
2. Modern SwiftUI patterns (iOS 26+, Swift 6.2+)
3. SwiftAgents best practices (modern APIs)
4. MLX integration guide
5. Design system specifications
6. Common bugs to avoid
7. Testing examples

**📚 Related Documentation:**
- **`documentation.md`** - Complete project documentation (architecture, setup, troubleshooting)
- **`plan.md`** - Implementation roadmap with step-by-step guides
- **⚠️ Keep `documentation.md` updated** when adding features, changing architecture, or fixing critical bugs

**At the start of each session:**
1. Read `plan.md` to understand the current phase
2. Read this file to understand best practices
3. Ask Romain which step you're working on
4. Write tests FIRST (TDD), then implement

**🚨 CRITICAL RULE: File Creation**
**NEVER use Write/Edit tools to create Swift files directly!**
- ❌ **DON'T:** Use `Write` tool to create .swift files (they won't be added to Xcode targets)
- ✅ **DO:** Tell Romain to create files through **Xcode UI** (Right-click > New File), then provide code to paste
- **Why:** Files created outside Xcode aren't automatically added to build targets, causing "Cannot find X in scope" errors

**🚨 MANDATORY: Import Checklist for Swift Files**
**EVERY TIME you provide Swift code, verify these imports are included:**

```swift
// ✅ ALWAYS check if these are needed:
import Foundation    // Required if using: Date, UUID, TimeInterval, URL, Data, etc.
import SwiftUI       // Required for: View, State, Binding, Color, Font, etc.
import SwiftData     // Required for: @Model, ModelContext, Query, etc.
import Observation   // Required for: @Observable (iOS 17+)

// Example - If code uses Date or UUID → MUST import Foundation!
```

**Quick reference:**
- Uses `Date`, `UUID`, `TimeInterval`? → `import Foundation`
- Uses `@Model`, `ModelContext`? → `import SwiftData`
- Uses `@Observable`? → `import Observation`
- Uses `Color`, `Text`, `View`? → `import SwiftUI`

**For Romain:**
When starting Claude Code, your first prompt should be:
```
Read plan.md and claude.md before we start.
We're working on Phase X, Step Y. Follow TDD approach.
```

---

## 🚨 CRITICAL WORKFLOW RULES

### 1. NEVER Build in Terminal ❌

**❌ NEVER use these commands:**
- `xcodebuild` (command-line builds)
- `swift test` (command-line tests)
- Any Bash commands to build or run the app

**✅ ALWAYS tell Romain:**
- "Please build the project in Xcode (⌘B) and verify it succeeds"
- "Please run tests in Xcode (⌘U) and confirm they all pass"
- "Please check for any compiler warnings"

**Why?**
- Command-line builds can have different results than Xcode builds
- Xcode provides better error messages and diagnostics
- Romain can see exactly what's happening in their environment
- Avoids false positives/negatives from terminal builds

---

### 2. Wait for Build Confirmation Before Committing ⏸️

**Workflow for EVERY code change:**

```
1. Claude provides code changes
   ↓
2. Romain creates files in Xcode (if needed)
   ↓
3. Romain pastes code
   ↓
4. Romain builds in Xcode (⌘B)
   ↓
5. Romain runs tests (⌘U) if applicable
   ↓
6. Romain confirms: "Build passes ✅" or "Tests pass ✅"
   ↓
7. ONLY THEN: Claude commits changes
```

**❌ DON'T commit immediately after providing code**
**✅ DO wait for Romain's explicit confirmation**

**Example:**
```
Claude: "Here's the code for DownloadView. Please:
1. Create the file in Xcode (Features/Download/DownloadView.swift)
2. Paste the code
3. Build with ⌘B
4. Let me know if it builds successfully ✅"

Romain: "Build passes ✅"

Claude: "Great! Now let me commit this..."
[Runs git commands]
```

**Why this is better:**
- ✅ Ensures code actually works in Romain's environment
- ✅ Catches issues before they're committed (cleaner git history)
- ✅ Gives Romain control over when commits happen
- ✅ Avoids reverting broken commits
- ✅ Better learning experience (Romain sees immediate feedback)

---

### 3. Build & Test Checklist (For Romain)

**After Claude provides code, always do:**

1. **Build** (`⌘B`):
   - Check for red errors ❌
   - Check for yellow warnings ⚠️
   - Wait for "Build Succeeded" ✅

2. **Run Tests** (`⌘U`) if applicable:
   - Check test results panel
   - All tests should show green ✓
   - No red failures ✗

3. **Check Preview** (if it's a SwiftUI view):
   - Open Canvas (`⌥⌘↵`)
   - Verify UI looks correct
   - Check for preview errors

4. **Confirm to Claude:**
   - "Build passes ✅"
   - "Tests pass ✅"
   - Or: "Build failed with error X" → Claude fixes it

---

## 📋 Project Context

Building an iOS/macOS chat app with local LLM (Llama 3.2 1B) using SwiftUI, MLX, and SwiftData. Approach is **Test-Driven Development (TDD)** with minimal liquid glass design.

**Target Platform:**
- **iOS 26.0+** (for modern liquid glass APIs)
- **Swift 6.2+** (strict concurrency)
- **No third-party frameworks** (except MLX for LLM inference)

**V1 Scope (Ultra-Minimal):**
- Single chat thread (no conversation history)
- Model download on first launch
- Send message + streaming response
- System prompt customization
- Liquid glass design

---

## 🎓 Step-by-Step Guide for Beginners

**Think of building an app like building a house:**

### Phase 1: Foundation (Steps 1-2)
- **Step 1: Project Setup** → Laying the foundation (creating the Xcode project, adding tools)
- **Step 2: Design Tokens** → Choosing paint colors & materials before building (colors, fonts, spacing)

### Phase 2: Core Logic / "The Brain" (Steps 3-5)
- **Step 3: Message Model** → Creating the "envelope" that holds messages
  - **What it does:** Defines what a message IS (who sent it, what text, when)
  - **Why it matters:** Without this, the app has nowhere to store chat messages
  - **You'll learn:** How to create database models with SwiftData

- **Step 4: LLMEvaluator** → The AI "engine" that generates responses
  - **What it does:** Downloads the AI model, loads it into memory, generates text
  - **Why it matters:** This is what makes the app "smart" - it's the local AI brain
  - **You'll learn:** How to integrate MLX (Apple's AI framework), streaming responses

- **Step 5: ChatViewModel** → The "conductor" that coordinates everything
  - **What it does:** Connects the UI to the AI (sends messages, gets responses, saves to database)
  - **Why it matters:** This is the glue between what user sees and what AI does
  - **You'll learn:** ViewModel pattern, async/await, state management

### Phase 3: User Interface / "What You See" (Steps 6-8)
- **Step 6: Splash Screen** → The welcome screen when app starts
- **Step 7: Download Screen** → Shows progress while AI model downloads (1-2 minutes first time)
- **Step 8: Chat Screen** → The main screen where you type and see responses

**Key principle:** We build from **inside-out** (brain first, UI last) because the UI needs the brain to work!

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
    var id: UUID = UUID()  // Default value (CloudKit-compatible)
    var role: Role = .user
    var content: String = ""
    var timestamp: Date = Date()

    init(role: Role, content: String) {
        self.id = UUID()
        self.role = role
        self.content = content
        self.timestamp = Date()
    }
}
```

**Types of Tests (by priority):**

1. **Unit tests** (MOST IMPORTANT): Business logic (ViewModels, models, utilities)
2. **Integration tests**: Component interactions (ChatViewModel + LLMEvaluator)
3. **UI tests** (MINIMAL): Only for critical happy path ("can send message and get response")

**Why minimal UI tests?**
- UI tests are slow and fragile
- They break easily with design changes
- Unit tests provide better coverage with less maintenance
- Focus testing effort where it matters most

**Testing Framework:** Swift Testing (iOS 26+, more modern than XCTest)

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

### 2. Modern SwiftUI Architecture (iOS 26+)

**Use these patterns (based on SwiftAgents best practices):**

#### @Observable (instead of ObservableObject)

```swift
// ✅ CORRECT (iOS 26+, Swift 6.2)
import Observation

@Observable
@MainActor  // ALWAYS mark @Observable classes with @MainActor
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

// ❌ NEVER use ObservableObject - it's deprecated
// Use @Observable instead
```

#### SwiftData (instead of CoreData)

```swift
// ✅ CORRECT - SwiftData models (CloudKit-compatible)
import SwiftData

@Model
class Message {
    var id: UUID = UUID()  // Default value (no .unique for CloudKit compatibility)
    var role: Role = .user
    var content: String = ""
    var timestamp: Date = Date()

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

// 🔑 SwiftData Rules (for CloudKit compatibility):
// - NEVER use @Attribute(.unique)
// - ALL properties need default values OR be optional
// - ALL relationships must be optional

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

#### Modern SwiftUI APIs (SwiftAgents Best Practices)

**Styling & Visual:**
```swift
// ✅ CORRECT - Modern APIs
.foregroundStyle(.blue)  // Not .foregroundColor()
.clipShape(.rect(cornerRadius: 12))  // Not .cornerRadius()
.bold()  // Not .fontWeight(.bold)

// ❌ AVOID - Deprecated/old APIs
.foregroundColor(.blue)
.cornerRadius(12)
.fontWeight(.bold)
```

**Navigation:**
```swift
// ✅ CORRECT - NavigationStack (iOS 16+)
NavigationStack {
    List {
        NavigationLink("Settings", value: Route.settings)
    }
    .navigationDestination(for: Route.self) { route in
        // Handle navigation
    }
}

// ❌ NEVER use NavigationView (deprecated)
```

**Buttons & Interactions:**
```swift
// ✅ CORRECT - Use Button with text + image
Button("Add Item", systemImage: "plus") {
    addItem()
}

// ✅ CORRECT - Button for interactions
Button("Tap Me") {
    handleTap()
}

// ❌ AVOID - onTapGesture (unless you need location/count)
Text("Tap Me")
    .onTapGesture { handleTap() }  // Use Button instead!
```

**Layout:**
```swift
// ✅ CORRECT - Modern layout
.containerRelativeFrame(.horizontal) { length, _ in
    length * 0.8
}

// ✅ CORRECT - ScrollView indicators
ScrollView {
    // content
}
.scrollIndicators(.hidden)

// ❌ AVOID - GeometryReader (unless absolutely necessary)
// ❌ AVOID - showsIndicators: false (old API)
```

**String Manipulation:**
```swift
// ✅ CORRECT - Modern string methods
let replaced = text.replacing("hello", with: "world")
let filtered = items.filter { item in
    item.localizedStandardContains(searchText)  // User input filtering
}

// ❌ AVOID - Old methods
let replaced = text.replacingOccurrences(of: "hello", with: "world")
let filtered = items.filter { $0.contains(searchText) }
```

**Number Formatting:**
```swift
// ✅ CORRECT - SwiftUI format API
Text(value, format: .number.precision(.fractionLength(2)))

// ❌ AVOID - C-style formatting
Text(String(format: "%.2f", value))
```

**Concurrency:**
```swift
// ✅ CORRECT - Modern concurrency
Task {
    try await Task.sleep(for: .seconds(1))
    await updateData()
}

// ❌ NEVER use DispatchQueue.main.async
// ❌ NEVER use Task.sleep(nanoseconds:)
```

**URL & Files:**
```swift
// ✅ CORRECT - Modern URL APIs
let docURL = URL.documentsDirectory
let fileURL = docURL.appending(path: "data.json")

// ❌ AVOID - FileManager.default.urls(for:in:)
```

**onChange Modifier:**
```swift
// ✅ CORRECT - Two-parameter or zero-parameter
.onChange(of: value) { oldValue, newValue in
    // Handle change
}

.onChange(of: value) {
    // Handle change (no params)
}

// ❌ NEVER use single-parameter variant (deprecated)
.onChange(of: value) { newValue in  // WRONG!
    // ...
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
            .foregroundStyle(.white)  // Modern API (not .foregroundColor)
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
                    .foregroundStyle(.secondary)  // Modern API
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

            // Modern Button API: text + systemImage
            Button("Send", systemImage: "arrow.up.circle.fill") {
                onSend()
            }
            .labelStyle(.iconOnly)  // Show only icon
            .font(.system(size: 32))
            .foregroundStyle(text.isEmpty || isGenerating ? .gray : .blue)
            .disabled(text.isEmpty || isGenerating)
        }
        .padding(Spacing.md)
        .background(.ultraThinMaterial)
    }
}
```

---

## 🛠️ iOS Best Practices

### 1. Project Organization

**File Structure:**
- Organize by **features**, not by type
- One type per file (no massive files with multiple classes)
- Consistent naming conventions

**Example structure:**
```
LocalLLMChat/
├── App/
│   └── LocalLLMChatApp.swift
├── Features/
│   ├── Chat/
│   │   ├── Views/
│   │   │   ├── ChatView.swift
│   │   │   └── MessageBubble.swift
│   │   ├── ViewModels/
│   │   │   └── ChatViewModel.swift
│   │   └── Models/
│   │       └── Message.swift
│   └── Settings/
│       └── SettingsView.swift
├── Core/
│   ├── LLM/
│   │   └── LLMEvaluator.swift
│   └── Design/
│       └── DesignSystem.swift
└── Tests/
    ├── ChatViewModelTests.swift
    └── MessageTests.swift
```

**Code Style:**
- Use descriptive names (types, properties, methods, models)
- Document code with comments where clarity is needed (in French for Romain)
- NEVER commit secrets (API keys, tokens) to the repository

### 2. Memory Management

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

### 3. Concurrency (async/await)

```swift
// ✅ CORRECT - All UI updates on @MainActor
@MainActor
class ChatViewModel {
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

### 4. Error Handling

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

### 5. Performance

```swift
// ✅ CORRECT - Lazy loading for heavy views
struct ChatView: View {
    @Query var messages: [Message]

    var body: some View {
        ScrollView {
            LazyVStack { // Lazy for performance (NOT VStack for 100+ items!)
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

// ❌ AVOID - AnyView (type erasure hurts performance)
// Only use when absolutely necessary
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

## 🛠️ Common Xcode Issues for Beginners

### Issue 1: "Cannot find [ClassName] in scope" in Tests

**Problem:** Tests can't find your classes even though they exist.

**Cause:** The file wasn't added to the Xcode project target properly.

**Fix:**
1. Find the file in Project Navigator (left sidebar)
2. Click on the file
3. Open File Inspector (right panel - click folder icon if hidden)
4. Look for "Target Membership" section
5. ✅ Check the **app target** (e.g., "lil Claudio")
6. ❌ Uncheck the **test target** (e.g., "lil ClaudioTests")
7. Rebuild with ⌘B

**Why this happens:** When you create files outside Xcode (via terminal/scripts/AI tools), they aren't automatically added to targets.

**🎯 BEST PRACTICE - Always Create Files Through Xcode UI:**

To avoid this issue entirely:

1. **Right-click** on the folder where you want the file (e.g., `Features/Chat/`)
2. Select **"New File..."** (or press ⌘N)
3. Choose **Swift File** template
4. Name the file
5. ✅ **IMPORTANT:** Verify "Targets" shows your app target checked
6. Click **Create**

This ensures files are automatically registered with Xcode.

**Alternative fix if file already exists:** Right-click folder → "Add Files to..." → Select file → Check correct target → Add

---

### Issue 2: "Module compiled with Swift X cannot be imported by Swift Y"

**Problem:** Dependency version mismatch.

**Fix:**
1. File → Packages → Reset Package Caches
2. Clean build folder (⌘⇧K)
3. Rebuild (⌘B)

---

### Issue 3: Preview doesn't work / shows errors

**Problem:** SwiftUI Preview crashes or won't load.

**Fix:**
1. Press ⌥⌘P to refresh preview
2. If that fails: Editor → Canvas → Restart Canvas
3. If still broken: Clean build (⌘⇧K) → Rebuild (⌘B)

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

1. **NEVER use @Attribute(.unique) for CloudKit compatibility**
   ```swift
   // ✅ CORRECT
   var id: UUID = UUID()  // Default value, no .unique

   // ❌ WRONG
   @Attribute(.unique) var id: UUID
   ```

2. **ALL properties need default values OR be optional**
   ```swift
   // ✅ CORRECT
   var content: String = ""
   var timestamp: Date = Date()
   var optionalField: String?

   // ❌ WRONG
   var content: String  // No default!
   ```

3. **Save after inserts/deletes**
   ```swift
   modelContext.insert(message)
   try? modelContext.save() // Don't forget!
   ```

4. **One ModelContext per view hierarchy**
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

## 🔍 Code Quality - SwiftLint

**What is SwiftLint?**
A tool that automatically checks your Swift code for style issues, common bugs, and anti-patterns.

**Why use it?**
- ✅ Catches silly mistakes before runtime
- ✅ Enforces consistent code style across the project
- ✅ Prevents common bugs (unused variables, force unwraps, etc.)
- ✅ 2-minute setup, saves hours of debugging

**Setup (Quick):**

1. **Install SwiftLint:**
   ```bash
   brew install swiftlint
   ```

2. **Create `.swiftlint.yml` in project root:**
   ```yaml
   disabled_rules:
     - trailing_whitespace  # Allow trailing spaces
   opt_in_rules:
     - force_unwrapping  # Warn on force unwraps (!)
   excluded:
     - Pods
     - .build
   line_length: 120
   ```

3. **Add Build Phase in Xcode:**
   - Target > Build Phases > + > New Run Script Phase
   - Add script:
     ```bash
     if which swiftlint >/dev/null; then
       swiftlint
     else
       echo "warning: SwiftLint not installed, run: brew install swiftlint"
     fi
     ```

4. **Run before commits:**
   ```bash
   swiftlint --strict  # Fails if ANY warnings
   ```

**Goal:** Zero warnings, zero errors before committing.

---

## 📚 Useful Resources

- [SwiftAgents](https://github.com/twostraws/SwiftAgents) - Modern Swift/SwiftUI best practices for LLMs
- [MLX Swift Examples](https://github.com/ml-explore/mlx-swift-examples) - Official MLX repo
- [Fullmoon source](https://github.com/mainframecomputer/fullmoon-ios) - Architecture reference
- [SwiftData docs](https://developer.apple.com/documentation/swiftdata) - Apple docs
- [Swift Testing](https://developer.apple.com/documentation/testing) - Testing framework
- [SwiftLint](https://github.com/realm/SwiftLint) - Code quality tool

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

**🚨 CRITICAL: Romain performs these checks, NOT Claude!**

**Before Claude commits ANY code, Romain must verify:**

- [ ] **Build succeeds** (⌘B in Xcode) - Romain confirms "Build passes ✅"
- [ ] **All tests pass** (⌘U in Xcode) - Romain confirms "Tests pass ✅"
- [ ] **No compiler warnings** - Check Issues Navigator in Xcode
- [ ] **SwiftUI Previews work** (if applicable) - Verify UI looks correct
- [ ] **Code follows Swift conventions** - Clean, readable, well-commented

**Additional checks (less frequent):**
- [ ] SwiftLint passes with zero warnings (`swiftlint --strict`) - optional for now
- [ ] Code compiles on iPhone + iPad simulators - if UI changes
- [ ] Feature works as expected on real device - before final release
- [ ] **Documentation updated** (if adding features, changing architecture, fixing critical bugs)

**Workflow:**
1. Claude provides code
2. **Romain builds & tests in Xcode**
3. **Romain confirms "Build passes ✅"**
4. **ONLY THEN Claude commits**

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
