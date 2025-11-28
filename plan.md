# Development Plan - Local LLM Chat iOS App

## 📋 Project Overview

### Pitch
Minimalist iOS/macOS app to chat with a local LLM (Llama 3.2 1B) without internet. Inspired by Apple Notes and Fullmoon with a liquid glass design aesthetic. User can customize the system prompt.

### Goal
Build a **V1 Ultra-Minimal** functional prototype with Claude Code, focusing on core features only.

### Tech Stack
- **Language:** Swift 5.9+
- **UI Framework:** SwiftUI
- **Minimum iOS:** 17.0+
- **LLM Framework:** MLX + MLXLLM (Apple)
- **Persistence:** SwiftData
- **Model:** Llama 3.2 1B Instruct 4-bit (~700 MB)
- **Approach:** Test-Driven Development (TDD)

---

## 🎯 V1 Scope - Ultra Minimal

### What's IN V1
- ✅ Single chat thread (no history, no multiple conversations)
- ✅ Model download on first launch
- ✅ Send message + receive streaming response
- ✅ System prompt customization in settings
- ✅ Liquid glass design (minimal)
- ✅ Persistence of messages in current session

### What's OUT V1 (for V2)
- ❌ Multiple conversations / conversation history
- ❌ Sidebar with conversation list
- ❌ Swipe to delete conversations
- ❌ Search in messages
- ❌ Export conversations
- ❌ Multiple models support

---

## 🔮 V2 Roadmap (After V1)

### Feature: Multiple Conversations & History

**Goal:** Allow users to create, manage, and switch between multiple chat conversations.

**Data Model Changes:**
```swift
// Add Thread model
@Model
final class Thread {
    @Attribute(.unique) var id: UUID
    var title: String
    var timestamp: Date
    
    @Relationship var messages: [Message] = []
    
    var sortedMessages: [Message] {
        messages.sorted { $0.timestamp < $1.timestamp }
    }
    
    init(title: String = "New conversation") {
        self.id = UUID()
        self.title = title
        self.timestamp = Date()
    }
}

// Update Message model
@Model
class Message {
    // ... existing properties
    @Relationship(inverse: \Thread.messages) var thread: Thread?
}
```

**UI Changes:**
- **Sidebar/List View:** Display all conversations sorted by date
- **Navigation:** Tap conversation → open chat
- **Actions:** Swipe to delete, pull to refresh
- **New conversation button:** [+] in navigation bar

**Architecture Changes:**
- Update `ChatViewModel` to work with `currentThread: Thread?`
- Add `ConversationsListView` and `ConversationRowView`
- Implement navigation between list and detail
- Add split view for iPad/Mac

**Estimated effort:** 2-3 days

**Key considerations:**
- Title generation: Use first user message or "New conversation"
- Performance: Lazy loading for large conversation lists
- Persistence: All threads saved in SwiftData
- Context management: Pass thread between views efficiently

---

## 🖼️ UI/UX Specs - V1 Minimal

### Screen 1: Onboarding (First launch only)

```
┌─────────────────────────┐
│                         │
│      🌙 (Moon icon)     │
│                         │
│      [App Name]         │
│   Chat with local AI    │
│                         │
│  ┌───────────────────┐  │
│  │   Downloading...  │  │
│  │  ████████░░░░ 65% │  │
│  │   Llama 3.2 1B    │  │
│  └───────────────────┘  │
│                         │
│  Keep screen open and   │
│  wait for installation  │
│                         │
└─────────────────────────┘
```

**Behavior:**
- Check if model is downloaded
- If not: show progress bar (700 MB download)
- Once complete: transition to chat

**Design:**
- Soft gradient background (off-white → light beige)
- Progress card: glassmorphism effect
- Moon icon: subtle animation (optional)

---

### Screen 2: Chat (Main screen)

```
┌─────────────────────────┐
│       Chat          ⚙   │  ← Nav bar with settings button
├─────────────────────────┤
│                         │
│  User: Hello!           │
│  [timestamp]            │
│                         │
│  Assistant: Hi there!   │
│  How can I help?        │
│  [timestamp]            │
│                         │
│  User: Tell me...       │
│  [timestamp]            │
│                         │
│  Assistant: [typing...] │
│                         │
│                         │
├─────────────────────────┤
│ ┌─────────────────────┐ │
│ │  Type message...    │ │  ← Input field
│ └─────────────────────┘ │
│                      [↑]│  ← Send button
└─────────────────────────┘
```

**Behavior:**
- Auto-scroll to bottom when new message
- Send button enabled only if text non-empty
- Streaming: words appear progressively (every 4 tokens)
- ⚙ button: opens Settings sheet

**Design - Liquid glass:**
- User messages: right-aligned, blue-tinted glass bubble
- Assistant messages: left-aligned, white/gray glass bubble
- Bubbles: 18px border-radius, soft shadow
- Input field: glassmorphism, subtle border

**Special states:**
- Empty chat: "Start a conversation..." placeholder
- Generation error: red error message + "Retry" button

---

### Screen 3: Settings

```
┌─────────────────────────┐
│  ← Settings             │
├─────────────────────────┤
│                         │
│  System Prompt          │
│  ┌───────────────────┐  │
│  │ you are a helpful │  │
│  │ assistant         │  │
│  │                   │  │
│  └───────────────────┘  │
│  [Reset to default]     │
│                         │
│ ─────────────────────── │
│                         │
│  Model Info             │
│  Llama 3.2 1B (700 MB)  │
│  Status: Downloaded     │
│                         │
└─────────────────────────┘
```

**Behavior:**
- Multi-line TextEditor for system prompt
- "Reset to default" button
- Changes apply to new messages immediately
- Model info: read-only

**Design:**
- Standard SwiftUI Form
- TextEditor with glass background

---

## 🏗️ Architecture

### File Structure (Simplified for V1)

```
LocalLLMChat/
├── LocalLLMChatApp.swift         # Entry point
├── Models/
│   ├── Message.swift              # SwiftData model
│   ├── LLMEvaluator.swift         # MLX inference logic
│   └── AppManager.swift           # Global state (system prompt, etc.)
├── Views/
│   ├── OnboardingView.swift       # First launch + download
│   ├── ChatView.swift             # Main chat screen
│   ├── MessageBubble.swift        # Message component
│   ├── ChatInputField.swift       # Input component
│   └── SettingsView.swift         # Settings sheet
├── ViewModels/
│   └── ChatViewModel.swift        # Chat logic (observable)
└── Tests/
    ├── MessageTests.swift
    ├── ChatViewModelTests.swift
    └── LLMEvaluatorTests.swift
```

---

### Data Models (SwiftData)

**Message** (V1 - No Thread model needed)
```swift
@Model
class Message {
    @Attribute(.unique) var id: UUID
    var role: Role // .user or .assistant
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
```

**AppManager** (Global settings)
```swift
@Observable
class AppManager {
    @AppStorage("systemPrompt") var systemPrompt = "you are a helpful assistant"
    @AppStorage("isModelDownloaded") var isModelDownloaded = false
    
    var isDownloading = false
    var downloadProgress: Double = 0.0
}
```

---

## 📅 Detailed Development Plan

### PHASE 1: Project Setup & Dependencies
**Estimated time:** 1-2 hours  
**Goal:** Working Xcode project with MLX integrated

#### Step 1.1: Create Xcode Project
**Claude Code should:**
1. Create new iOS App project
2. Target: iOS 17.0+
3. Interface: SwiftUI
4. Language: Swift

**Expected input from you:**
- App name (e.g., "LocalLLMChat")
- Bundle ID (e.g., "com.yourname.localllmchat")

**Checkpoint:**
✅ Project compiles without errors  
✅ Can run on simulator and see "Hello, World!" default view

---

#### Step 1.2: Add MLX Swift Packages
**Claude Code should:**
1. File → Add Package Dependencies
2. Add: `https://github.com/ml-explore/mlx-swift`
3. Add: `https://github.com/ml-explore/mlx-swift-examples` (select MLXLLM, MLXLMCommon, MLXRandom)

**Expected input from you:**
- Confirmation that packages resolve successfully

**Checkpoint:**
✅ `import MLX` and `import MLXLLM` compile without errors  
✅ No package resolution errors

**Common bugs to avoid:**
- ⚠️ If package resolution hangs: File → Packages → Reset Package Caches
- ⚠️ Ensure "Add to target" is checked for main app target

---

#### Step 1.3: Configure SwiftData
**Claude Code should:**
1. Create `Message.swift` with SwiftData @Model
2. Configure `.modelContainer(for: Message.self)` in App struct

**Test to write FIRST (TDD):**
```swift
@Test("Message creation")
func testMessageCreation() {
    let message = Message(role: .user, content: "Test")
    #expect(message.role == .user)
    #expect(message.content == "Test")
    #expect(!message.id.uuidString.isEmpty)
}
```

**Expected input from you:**
- None (should be automatic)

**Checkpoint:**
✅ Test passes  
✅ No SwiftData configuration errors

**Common bugs to avoid:**
- ⚠️ `@Attribute(.unique)` must be on `id` or you'll get duplicate messages
- ⚠️ Don't forget to add `.modelContainer()` in App struct

---

#### Step 1.4: Create AppManager
**Claude Code should:**
1. Create `AppManager.swift` with @Observable
2. Add @AppStorage properties for systemPrompt and isModelDownloaded

**Test to write FIRST:**
```swift
@Test("AppManager defaults")
func testAppManagerDefaults() {
    let manager = AppManager()
    #expect(manager.systemPrompt == "you are a helpful assistant")
    #expect(manager.isModelDownloaded == false)
}
```

**Expected input from you:**
- None

**Checkpoint:**
✅ Test passes  
✅ AppManager compiles

**Common bugs to avoid:**
- ⚠️ @Observable requires `import Observation`
- ⚠️ Don't mix @Observable with ObservableObject (old pattern)

---

### PHASE 2: Onboarding & Model Download
**Estimated time:** 2-3 hours  
**Goal:** Download Llama 3.2 1B on first launch

#### Step 2.1: Create OnboardingView Shell
**Claude Code should:**
1. Create `OnboardingView.swift`
2. Basic layout: moon icon, app name, download card placeholder
3. Show if `isModelDownloaded == false`

**No tests yet** (pure UI)

**Expected input from you:**
- App name to display

**Checkpoint:**
✅ View appears on first launch  
✅ Liquid glass card renders correctly

---

#### Step 2.2: Integrate LLMModelFactory for Download
**Claude Code should:**
1. Create `LLMEvaluator.swift` with `load()` function
2. Use `LLMModelFactory.shared.loadContainer()` with progress callback
3. Update `AppManager.downloadProgress` in callback

**Test to write FIRST:**
```swift
@Test("Download progress updates")
@MainActor
func testDownloadProgress() async {
    let manager = AppManager()
    manager.isDownloading = true
    
    // Simulate progress
    manager.downloadProgress = 0.5
    
    #expect(manager.downloadProgress == 0.5)
}
```

**Expected input from you:**
- None (auto-downloads from Hugging Face)

**Checkpoint:**
✅ Progress bar updates from 0% to 100%  
✅ No network errors  
✅ Model file saved in app's cache directory

**Common bugs to avoid:**
- ⚠️ MLX downloads can fail on slow networks → add retry logic
- ⚠️ Progress callback must run on @MainActor
- ⚠️ Check available disk space BEFORE starting download (~1 GB needed)
- ⚠️ `MLX.GPU.set(cacheLimit:)` must be set before loading model

---

#### Step 2.3: Handle Download Completion
**Claude Code should:**
1. On completion: set `isModelDownloaded = true`
2. Transition from OnboardingView to ChatView
3. Handle errors: show alert with "Retry" button

**Test to write FIRST:**
```swift
@Test("Model loaded state persists")
func testModelLoadedState() {
    let manager = AppManager()
    manager.isModelDownloaded = true
    
    #expect(manager.isModelDownloaded == true)
}
```

**Expected input from you:**
- Wait for full download (~700 MB, 5-10 min on good Wi-Fi)

**Checkpoint:**
✅ After download, app shows ChatView on next launch  
✅ No repeated downloads

**Common bugs to avoid:**
- ⚠️ Verify `isModelDownloaded` persists across app restarts (use @AppStorage correctly)
- ⚠️ Don't transition to ChatView before model is fully loaded in memory

---

### PHASE 3: Core Chat Functionality
**Estimated time:** 3-4 hours  
**Goal:** Send message + receive streaming response

#### Step 3.1: Create ChatView Layout
**Claude Code should:**
1. Create `ChatView.swift` with ScrollView + LazyVStack
2. List messages with ForEach
3. Auto-scroll to bottom when new message

**No tests yet** (pure UI)

**Expected input from you:**
- None

**Checkpoint:**
✅ Empty chat shows "Start a conversation..."  
✅ ScrollView scrolls smoothly

---

#### Step 3.2: Create MessageBubble Component
**Claude Code should:**
1. Create `MessageBubble.swift`
2. Display message content, timestamp, role-based styling
3. Apply liquid glass styling (RoundedRectangle + .ultraThinMaterial)

**Preview to create:**
```swift
#Preview {
    VStack {
        MessageBubble(message: Message(role: .user, content: "Hello!"))
        MessageBubble(message: Message(role: .assistant, content: "Hi!"))
    }
}
```

**Expected input from you:**
- Feedback on glass styling (too much blur? colors?)

**Checkpoint:**
✅ Bubbles render correctly in preview  
✅ User bubbles align right, assistant bubbles align left

**Common bugs to avoid:**
- ⚠️ `.ultraThinMaterial` requires iOS 15+, but you're on 17+ so OK
- ⚠️ Don't set fixed width on bubbles → use `frame(maxWidth: 280)`

---

#### Step 3.3: Create ChatInputField Component
**Claude Code should:**
1. Create `ChatInputField.swift`
2. TextField + Send button (SF Symbol: arrow.up.circle.fill)
3. Disable send button if text is empty

**Test to write FIRST:**
```swift
@Test("Send button disabled when text empty")
func testSendButtonDisabled() {
    let text = ""
    let isEnabled = !text.isEmpty
    #expect(isEnabled == false)
}
```

**Expected input from you:**
- None

**Checkpoint:**
✅ Typing in field enables send button  
✅ Pressing send calls callback

---

#### Step 3.4: Implement ChatViewModel
**Claude Code should:**
1. Create `ChatViewModel.swift` with @Observable
2. `sendMessage()` function:
   - Add user message to SwiftData
   - Call `LLMEvaluator.generate()`
   - Add assistant response to SwiftData
3. Observe `LLMEvaluator.output` for streaming updates

**Test to write FIRST:**
```swift
@Test("Send message adds to model context")
@MainActor
func testSendMessage() async throws {
    let config = ModelConfiguration(inMemory: true)
    let container = try ModelContainer(for: Message.self, configurations: config)
    let viewModel = ChatViewModel(modelContext: container.mainContext)
    
    await viewModel.sendMessage("Test")
    
    let messages = try container.mainContext.fetch(FetchDescriptor<Message>())
    #expect(messages.count == 1)
    #expect(messages.first?.content == "Test")
}
```

**Expected input from you:**
- Test first message: "Hello, who are you?"

**Checkpoint:**
✅ User message appears immediately  
✅ Assistant response streams in word-by-word  
✅ Messages persist after app restart

**Common bugs to avoid:**
- ⚠️ `LLMEvaluator.generate()` MUST be called with `await` on background task
- ⚠️ UI updates (adding messages) MUST be on @MainActor
- ⚠️ Don't forget to save `modelContext` after adding messages
- ⚠️ Streaming: bind to `LLMEvaluator.output` with `.onChange()` modifier

---

#### Step 3.5: Integrate LLMEvaluator Generation
**Claude Code should:**
1. In `LLMEvaluator.swift`, implement `generate()` function
2. Build prompt history: [system prompt, ...messages]
3. Call `MLXLMCommon.generate()` with streaming callback
4. Update `output` property every 4 tokens

**Test to write FIRST:**
```swift
@Test("Generation produces non-empty output")
@MainActor
func testGeneration() async {
    let evaluator = LLMEvaluator()
    // Note: requires loaded model, so skip in unit tests
    // or mock the model container
}
```

**Expected input from you:**
- First test prompt (keep it simple: "Hi")

**Checkpoint:**
✅ Response appears word-by-word  
✅ Generation completes without errors  
✅ Token/s metric is reasonable (>5 tokens/s on M1+)

**Common bugs to avoid:**
- ⚠️ `MLXRandom.seed()` must be called before each generation for variety
- ⚠️ `displayEveryNTokens = 4` → if too low, UI updates lag
- ⚠️ `maxTokens` limit must be set (2048 is reasonable for V1)
- ⚠️ CRITICAL: `context.tokenizer.decode()` can crash if tokens array is empty → check `tokens.count > 0`
- ⚠️ Progress callback MUST use `Task { @MainActor in ... }` to update UI

---

### PHASE 4: Settings & System Prompt
**Estimated time:** 1-2 hours  
**Goal:** User can customize system prompt

#### Step 4.1: Create SettingsView
**Claude Code should:**
1. Create `SettingsView.swift`
2. Form with TextEditor bound to `@AppStorage("systemPrompt")`
3. "Reset to default" button
4. Display model info (name, size, status)

**Test to write FIRST:**
```swift
@Test("System prompt updates persist")
func testSystemPromptUpdate() {
    let manager = AppManager()
    manager.systemPrompt = "Custom prompt"
    #expect(manager.systemPrompt == "Custom prompt")
}
```

**Expected input from you:**
- Test custom prompt: "You are a pirate assistant. Speak like a pirate."

**Checkpoint:**
✅ Changes to prompt persist across app restarts  
✅ Reset button works  
✅ New messages use updated prompt

**Common bugs to avoid:**
- ⚠️ @AppStorage doesn't support complex types → keep it as String
- ⚠️ Don't apply prompt retroactively to old messages → only new ones

---

#### Step 4.2: Apply System Prompt to Generation
**Claude Code should:**
1. In `LLMEvaluator.generate()`, prepend system prompt to history
2. Format: `[{"role": "system", "content": systemPrompt}, ...]`

**Test to write FIRST:**
```swift
@Test("System prompt included in history")
func testSystemPromptInHistory() {
    let systemPrompt = "You are helpful"
    let history = [["role": "system", "content": systemPrompt]]
    #expect(history.first?["role"] == "system")
}
```

**Expected input from you:**
- Test with pirate prompt and verify response tone

**Checkpoint:**
✅ Assistant responds according to custom prompt  
✅ Changing prompt mid-conversation works

---

### PHASE 5: Polish & Testing
**Estimated time:** 2-3 hours  
**Goal:** Stable, bug-free V1

#### Step 5.1: Add Error Handling
**Claude Code should:**
1. Wrap `generate()` in do-catch
2. Display error message in chat if generation fails
3. Add "Retry" button

**Test to write FIRST:**
```swift
@Test("Error state handled gracefully")
@MainActor
func testErrorHandling() {
    let viewModel = ChatViewModel(modelContext: mockContext)
    viewModel.error = "Test error"
    #expect(viewModel.error != nil)
}
```

**Expected input from you:**
- Simulate error (e.g., airplane mode during generation)

**Checkpoint:**
✅ Error message appears in red  
✅ Retry button works

**Common bugs to avoid:**
- ⚠️ Errors must be shown to user (not just logged)
- ⚠️ Clear error state after retry

---

#### Step 5.2: Memory & Performance
**Claude Code should:**
1. Add low memory warning handler → clear model from memory
2. Optimize ScrollView with LazyVStack
3. Test on real device (not just simulator)

**Expected input from you:**
- Test on physical iPhone/iPad

**Checkpoint:**
✅ No memory crashes  
✅ Smooth scrolling even with 50+ messages  
✅ Generation starts within 1 second

**Common bugs to avoid:**
- ⚠️ Model takes ~1-2 GB RAM → test on devices with <4 GB RAM
- ⚠️ LazyVStack MUST be used for message list (not VStack)
- ⚠️ `modelContainer = nil` on low memory, reload on next use

---

#### Step 5.3: Final Polish
**Claude Code should:**
1. Add haptic feedback on send button tap
2. Improve empty state messaging
3. Add loading spinner during model load
4. Test dark mode

**No tests** (pure polish)

**Expected input from you:**
- Visual feedback on polish items

**Checkpoint:**
✅ App feels responsive  
✅ Dark mode looks good  
✅ No visual glitches

---

## ✅ V1 Definition of Done

### Functional
- [ ] Model downloads successfully on first launch
- [ ] Can send message and receive streaming response
- [ ] Messages persist across app restarts
- [ ] System prompt can be customized
- [ ] Errors are handled gracefully

### Technical
- [ ] All unit tests pass
- [ ] No memory leaks (test with Instruments)
- [ ] No crashes on 10 test sessions
- [ ] Builds for iOS, iPadOS, macOS

### UX
- [ ] Liquid glass design applied consistently
- [ ] Animations are smooth (60 fps)
- [ ] Text is readable in light + dark mode

---

## 🚨 Common Pitfalls to Avoid

### Swift/MLX Specific
1. **@MainActor violations:** All UI updates MUST be on main thread
2. **SwiftData context:** Only one context per view, pass from parent
3. **MLX model loading:** Can take 10-30s first time → show progress
4. **Token decoding:** Can fail with empty array → always check `tokens.count > 0`
5. **Memory pressure:** 700 MB model + system = ~1.5 GB total

### Architecture
1. **Retain cycles:** Use `[weak self]` in Task closures
2. **State duplication:** Don't store same data in ViewModel AND SwiftData
3. **Premature optimization:** Get it working first, optimize later

---

## 📱 Testing Strategy

### After Each Step
1. Run tests: ⌘U in Xcode
2. Check console for warnings
3. Test on simulator + real device
4. Verify in light + dark mode

### Before Calling Step "Done"
1. All tests pass
2. No compiler warnings
3. Feature works as expected
4. Code is commented (in French for Romain, variable names in English)

---

## 🎯 Success Metrics for V1

- **Setup time:** < 30 min to working build
- **Download time:** < 10 min on good Wi-Fi
- **First response:** < 5 seconds after sending message
- **Token rate:** > 5 tokens/second on M1+
- **Stability:** 0 crashes in 10 test sessions

---

Good luck with your vibe coding! 🚀
