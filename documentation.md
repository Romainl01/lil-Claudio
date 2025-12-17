# lil Claudio - Documentation

> Local AI chat app for iOS with streaming responses and offline capabilities

**Version:** 0.1.0 (V1 - MVP)
**Target:** iOS 26.0+
**Language:** Swift 6.2+
**Architecture:** MVVM + TDD

---

## 📋 Table of Contents

- [Overview](#overview)
- [Tech Stack](#tech-stack)
- [Architecture](#architecture)
- [Project Structure](#project-structure)
- [Core Components](#core-components)
- [Development Workflow](#development-workflow)
- [Getting Started](#getting-started)
- [Testing](#testing)
- [Common Issues](#common-issues)
- [Contributing](#contributing)

---

## 🎯 Overview

**lil Claudio** is a minimal iOS chat application that runs a local LLM (Llama 3.2 1B) entirely on-device using Apple's MLX framework. No internet required after initial model download.

### Key Features (V1)
- ✅ Single chat thread
- ✅ Streaming AI responses (word-by-word)
- ✅ Stop generation mid-stream
- ✅ Model download on first launch (~700 MB)
- ✅ Customizable system prompt
- ✅ Offline-first (privacy + no API costs)

### Non-Features (V1)
- ❌ No conversation history/persistence
- ❌ No multiple chats
- ❌ No message editing
- ❌ No model switching

---

## 🛠 Tech Stack

| Component | Technology | Why? |
|-----------|-----------|------|
| **UI Framework** | SwiftUI | Modern, declarative UI |
| **State Management** | @Observable | iOS 17+ modern approach |
| **Database** | SwiftData | Simple, CloudKit-compatible |
| **AI Framework** | MLX Swift | Apple Silicon optimized LLM inference |
| **LLM Model** | Llama 3.2 1B (4-bit quantized) | Small, fast, runs on iPhone |
| **Testing** | Swift Testing | Modern testing framework (iOS 18+) |
| **Code Quality** | SwiftLint | Consistent style, catch bugs early |

---

## 🏗 Architecture

### MVVM Pattern

```
┌─────────────────────────────────────────────┐
│                   Views                     │
│  (SplashView, DownloadView, ChatView)      │
└──────────────────┬──────────────────────────┘
                   │ Observes
                   ▼
┌─────────────────────────────────────────────┐
│               ViewModels                    │
│         (ChatViewModel)                     │
│  - Manages state                            │
│  - Coordinates logic                        │
└──────────────────┬──────────────────────────┘
                   │ Uses
                   ▼
┌─────────────────────────────────────────────┐
│          Models + Services                  │
│  - Message (data model)                     │
│  - LLMEvaluator (AI engine)                 │
│  - SwiftData (persistence)                  │
└─────────────────────────────────────────────┘
```

### Data Flow

```
User types message
    ↓
ChatView updates inputText
    ↓
User taps Send
    ↓
ChatViewModel.sendMessage()
    ↓
1. Save user message (SwiftData)
2. Call LLMEvaluator.generate()
    ↓
LLMEvaluator streams tokens
    ↓
ChatViewModel updates UI (via @Observable)
    ↓
3. Save AI response (SwiftData)
    ↓
UI auto-refreshes with new messages
```

---

## 📁 Project Structure

```
lil Claudio/
├── lil Claudio/                  # Main app target
│   ├── App/                      # App entry point
│   │   └── lil_ClaudioApp.swift  # @main app struct
│   │
│   ├── Features/                 # Feature modules
│   │   ├── Splash/               # Splash screen (logo) ✅
│   │   │   └── SplashView.swift  # Entry point with smart navigation
│   │   ├── Download/             # Model download screen ⏳
│   │   └── Chat/                 # Chat feature ✅
│   │       ├── ViewModels/       # ChatViewModel
│   │       │   └── ChatViewModel.swift
│   │       └── Message.swift     # Message model (SwiftData)
│   │
│   ├── Core/                     # Shared code
│   │   ├── LLM/                  # AI inference
│   │   │   └── LLMEvaluator.swift
│   │   └── Design/               # Design system
│   │       └── DesignTokens.swift
│   │
│   └── Resources/                # Assets, fonts
│
├── lil ClaudioTests/             # Test target
│   ├── MessageTests.swift
│   ├── LLMEvaluatorTests.swift
│   └── ChatViewModelTests.swift
│
├── claude.md                     # AI assistant instructions
├── plan.md                       # Implementation roadmap
├── documentation.md              # This file
└── README.md                     # Project overview
```

### Folder Organization Principles
- **By feature, not by type** (easier to navigate)
- **One type per file** (no giant multi-class files)
- **Tests mirror source structure** (easy to find corresponding tests)

---

## 🧩 Core Components

### 1. SplashView (Entry Point)

**Location:** `Features/Splash/SplashView.swift`

```swift
struct SplashView: View {
    @State private var showNextScreen = false
    @AppStorage("isModelDownloaded") private var isModelDownloaded = false
}
```

**Purpose:** App's entry screen with smart navigation.

**Key Points:**
- Shows 📟 logo and "lil claudio" title for 1.5 seconds
- Uses `Task.sleep(for: .seconds(1.5))` for timer
- Smart navigation:
  - If model downloaded → Navigate to ChatView
  - If not downloaded → Navigate to DownloadView
- Uses `@AppStorage` to persist model download state

**Flow:**
```
App launches → SplashView appears
    ↓
Wait 1.5 seconds
    ↓
Check isModelDownloaded
    ↓
├─ YES → ChatView
└─ NO  → DownloadView
```

---

### 2. Message (SwiftData Model)

**Location:** `Features/Chat/Models/Message.swift`

```swift
@Model
class Message {
    var id: UUID
    var role: Role      // .user or .assistant
    var content: String
    var timestamp: Date
}
```

**Purpose:** Represents a single chat message (user or AI).

**Key Points:**
- SwiftData model (CloudKit-compatible)
- No `@Attribute(.unique)` (breaks CloudKit)
- Properties set in `init()` (not as default values)

---

### 3. LLMEvaluator (AI Engine)

**Location:** `Core/LLM/LLMEvaluator.swift`

```swift
@Observable
@MainActor
class LLMEvaluator {
    var running: Bool
    var output: String
    var progress: Double

    func load() async throws
    func generate(messages: [Message], systemPrompt: String) async -> String
    func cancel()
}
```

**Purpose:** Handles model loading and text generation.

**Key Points:**
- Downloads Llama 3.2 1B from Hugging Face (~700 MB)
- Streams responses token-by-token
- Runs on Apple Silicon GPU (MLX framework)
- Must call `GPU.set(cacheLimit:)` BEFORE loading model

**Critical Bugs to Avoid:**
- ✅ Check `tokens.count > 0` before decoding
- ✅ Set GPU cache limit before loading
- ✅ Use `@MainActor` for UI updates

---

### 4. ChatViewModel (Conductor)

**Location:** `Features/Chat/ViewModels/ChatViewModel.swift`

```swift
@Observable
@MainActor
class ChatViewModel {
    var inputText: String
    var isGenerating: Bool
    var messages: [Message]

    func sendMessage(_ text: String? = nil) async
    func cancelGeneration()
    func clearChat()
}
```

**Purpose:** Orchestrates chat logic (messages + AI + database).

**Key Points:**
- Uses `@Observable` (not `ObservableObject`)
- Uses `@ObservationIgnored` with `@AppStorage` (property wrapper conflict fix)
- Coordinates LLMEvaluator + SwiftData
- All async operations on `@MainActor`

**Data Flow:**
1. User message → Save to SwiftData
2. Call LLMEvaluator.generate()
3. AI response → Save to SwiftData
4. UI auto-updates (via @Observable)

---

## 🔄 Development Workflow

### Test-Driven Development (TDD)

**MANDATORY** for all features:

```
1. RED    → Write failing test
2. GREEN  → Write minimal code to pass
3. REFACTOR → Improve without breaking tests
```

**Example:**
```swift
// 1. RED - Write test first (fails)
@Test("Send message adds user message")
func testSendMessage() async {
    await viewModel.sendMessage("Hello")
    #expect(viewModel.messages.count == 1)
}

// 2. GREEN - Implement minimal code
func sendMessage(_ text: String) async {
    let msg = Message(role: .user, content: text)
    modelContext.insert(msg)
    try? modelContext.save()
    loadMessages()
}

// 3. REFACTOR - Add features, tests still pass
```

### Git Workflow

```bash
# Feature branch workflow
git checkout -b feature/step-6-splash-screen

# Make changes, test
git add .
git commit -m "feat: implement splash screen (Step 6)"

# Push and create PR
git push origin feature/step-6-splash-screen

# Merge to main after review
```

### Pre-Commit Checklist

- [ ] All tests pass (`⌘U` in Xcode)
- [ ] SwiftLint passes (`swiftlint --strict`)
- [ ] No compiler warnings
- [ ] Code compiles on iPhone + iPad simulators
- [ ] SwiftUI Previews work
- [ ] Documentation updated (if applicable)

---

## 🚀 Getting Started

### Prerequisites

- **macOS 15+** (Sequoia or later)
- **Xcode 16+** with iOS 26 SDK
- **Apple Silicon Mac** (M1/M2/M3) recommended for MLX
- **2 GB free disk space** (for model download)
- **Homebrew** (for SwiftLint)

### Installation

1. **Clone the repository:**
   ```bash
   git clone https://github.com/yourusername/lil-claudio.git
   cd lil-claudio
   ```

2. **Open in Xcode:**
   ```bash
   open "lil Claudio/lil Claudio.xcodeproj"
   ```

3. **Install SwiftLint (optional but recommended):**
   ```bash
   brew install swiftlint
   ```

4. **Build & Run:**
   - Press `⌘R` or click ▶️ in Xcode
   - Choose iPhone 16 Pro simulator (or any iOS 26+ device)
   - First launch: model downloads (~2 minutes on fast connection)

### Running Tests

```bash
# In Xcode
⌘U  # Run all tests

# Or from terminal
cd "lil Claudio/lil Claudio"
xcodebuild test -scheme "lil Claudio" -destination 'platform=iOS Simulator,name=iPhone 16 Pro'
```

---

## 🧪 Testing

### Testing Strategy

**Priorities:**
1. **Unit tests** (80%) - Business logic (ViewModels, models)
2. **Integration tests** (15%) - Component interactions
3. **UI tests** (5%) - Critical happy paths only

**Why minimal UI tests?**
- Slow and fragile
- Break easily with design changes
- Unit tests provide better coverage

### Test Structure

```swift
@Suite("Feature Tests")
struct FeatureTests {

    @Test("Description of what's being tested")
    @MainActor  // If needed for UI/state
    func testSomething() async throws {
        // Arrange - Set up test data
        let viewModel = ChatViewModel(modelContext: testContext)

        // Act - Perform action
        await viewModel.sendMessage("Hello")

        // Assert - Verify result
        #expect(viewModel.messages.count == 1)
    }
}
```

### Test Coverage (Current)

| Component | Tests | Coverage |
|-----------|-------|----------|
| Message | 2 tests | 100% |
| LLMEvaluator | 2 tests | ~40% (basic state) |
| ChatViewModel | 3 tests | ~70% (core flows) |

**Goal:** 80%+ coverage for business logic.

---

## 🐛 Common Issues

### 1. "Cannot find 'X' in scope" in tests

**Cause:** File not added to app target.

**Fix:**
1. Click file in Project Navigator
2. File Inspector (right panel) → Target Membership
3. ✅ Check app target, ❌ uncheck test target
4. Rebuild (`⌘B`)

---

### 2. "Invalid redeclaration of synthesized property"

**Cause:** `@Observable` + `@AppStorage` conflict.

**Fix:** Add `@ObservationIgnored`:
```swift
@ObservationIgnored
@AppStorage("key") var value = "default"
```

---

### 3. Model fails to load / crashes

**Cause:** GPU cache not set before loading.

**Fix:** Call this BEFORE `loadContainer()`:
```swift
MLX.GPU.set(cacheLimit: 20 * 1024 * 1024)
```

---

### 4. Tests timeout when calling LLMEvaluator

**Cause:** Tests are downloading real model.

**Fix (future):** Mock LLMEvaluator for tests:
```swift
protocol LLMEvaluating {
    func generate(messages: [Message], systemPrompt: String) async -> String
}

class MockLLMEvaluator: LLMEvaluating {
    func generate(messages: [Message], systemPrompt: String) async -> String {
        return "Mock response"
    }
}
```

---

### 5. SwiftUI Preview not working

**Fix:**
1. Press `⌥⌘P` to refresh
2. Editor → Canvas → Restart Canvas
3. Clean build (`⌘⇧K`) + rebuild (`⌘B`)

---

## 🤝 Contributing

### Code Style

- **SwiftLint** enforces style (run `swiftlint --strict`)
- **Modern Swift** (iOS 26+, Swift 6.2+)
  - Use `@Observable` (not `ObservableObject`)
  - Use `.foregroundStyle()` (not `.foregroundColor()`)
  - Use `async/await` (not callbacks)
- **Comments in French** for Romain's benefit
- **Variable names in English** (standard practice)

### Pull Request Process

1. Create feature branch (`git checkout -b feature/my-feature`)
2. Follow TDD (tests first!)
3. Run pre-commit checklist
4. Push and create PR
5. Wait for review
6. Merge after approval

### Documentation Updates

**⚠️ IMPORTANT:** Update this documentation when:
- Adding new features/components
- Changing architecture
- Adding dependencies
- Fixing critical bugs
- Updating workflows

**See:** `claude.md` and `plan.md` for AI assistant instructions to keep docs in sync.

---

## 📖 Additional Resources

- **[claude.md](./claude.md)** - Detailed technical guidelines for AI assistant
- **[plan.md](./plan.md)** - Step-by-step implementation roadmap
- **[SwiftAgents](https://github.com/twostraws/SwiftAgents)** - Modern Swift best practices
- **[MLX Swift](https://github.com/ml-explore/mlx-swift)** - MLX framework docs
- **[SwiftData Docs](https://developer.apple.com/documentation/swiftdata)** - Apple's SwiftData guide

---

## 📝 License

[Add your license here - e.g., MIT, Apache 2.0, etc.]

---

## 👤 Author

Romain Lagrange

---

**Last Updated:** December 17, 2025
**Current Version:** 0.1.0 (Phase 3, Step 8 in progress - Chat screen UX improvements)

**Recent Updates:**
- ✅ **UX Fix (Dec 17, 2025):** Fixed liquid glass effect rendering glitch in ChatView
  - Added smooth fade-in animation (400ms delay + 300ms transition)
  - Glass effects now fully loaded before view becomes visible
  - Eliminated initial dark/solid appearance of glass buttons and input field
  - Improved perceived app quality and polish
- ✅ **Step 7 (Dec 16, 2025):** DownloadView with progress tracking implemented
  - Progress bar connected to LLMEvaluator
  - Real-time percentage display (0% → 100%)
  - Auto-navigation to ChatView when download completes
  - Model download state persisted with @AppStorage
  - Fixed custom color syntax (Color.textSecondary, etc.)
- ✅ **Step 6 (Dec 16, 2025):** SplashView with smart navigation implemented
  - 📟 Logo and "lil claudio" title display
  - 1.5 second timer with Task.sleep
  - Smart navigation based on model download state
  - Entry point configured in lil_ClaudioApp.swift
