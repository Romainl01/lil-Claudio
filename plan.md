# lil Claudio - V0 Implementation Plan 📟

## 🎯 Project Overview

**Goal:** Build a minimal iOS chat app (iOS 26.0+) with local LLM (Llama 3.2 1B) using SwiftUI, MLX, and TDD methodology.

**Flow:** Splash Screen (1-2s) → Model Download (with progress) → Chat Screen

**Key Features:**
- Send message and get streaming response from local LLM
- Stop generation mid-stream (break button)
- No chat persistence (messages cleared on app restart)
- Default system prompt: "you are a helpful assistant"

---

## 🎨 Design Tokens (From Figma)

### Colors
```swift
// Background Colors
static let surfaceLight = Color(hex: "f9fafb")      // Main background
static let backgroundWhite = Color.white             // Splash background

// Text Colors
static let textPrimary = Color.black                 // Main text (#000000)
static let textSecondary = Color(hex: "6a7282")      // Placeholder text
static let textNeutralDark = Color(hex: "262629")    // Header text

// UI Element Colors
static let accentPrimary = Color(hex: "f28c59")      // Progress bar (orange/coral)
static let neutralGray200 = Color(hex: "d9dbe1")     // Input background, progress track
static let accentBlue = Color(hex: "0088ff")         // Buttons (if needed)
```

### Typography
```swift
// Splash Screen
static let splashTitle = Font.custom("Crimson Pro", size: 44)  // "lil claudio"

// Chat Screen
static let headerTitle = Font.custom("Inter", size: 16).weight(.medium)  // "chat"
static let inputText = Font.custom("Inter", size: 16).weight(.medium)    // Input placeholder
static let bodyText = Font.system(size: 16, weight: .regular)
```

### SF Symbols (Icons)
```swift
// Buttons
static let sendArrow = "arrow.up"           // Send message button
static let stopSquare = "stop.fill"         // Break/stop generation
static let menuIcon = "line.3.horizontal"   // Left header button
static let helpIcon = "questionmark.circle" // Right header button

// Logo
static let pagerEmoji = "📟"                // App icon/logo
```

### Spacing & Dimensions
```swift
static let cornerRadiusLarge: CGFloat = 26   // Input field
static let cornerRadiusSmall: CGFloat = 100  // Buttons (circular)
static let buttonSize: CGFloat = 40          // Icon buttons
static let headerButtonSize: CGFloat = 48    // Header buttons
static let inputHeight: CGFloat = 52         // Input field height
static let progressHeight: CGFloat = 6       // Progress bar height
static let paddingStandard: CGFloat = 16     // Standard padding
```

---

## 📋 Implementation Steps

### 🧑‍🏫 Xcode Basics (For Beginners)

Before we start, here are some Xcode shortcuts you'll use frequently:

**Building & Running:**
- `⌘B` - Build project (compile code)
- `⌘R` - Run app in simulator
- `⌘.` - Stop running app
- `⌘U` - Run tests

**Simulator:**
- After pressing `⌘R`, Xcode will open an iPhone simulator
- The simulator appears as a separate window showing an iPhone screen
- To change which iPhone to simulate: Xcode menu bar > Product > Destination > Choose iPhone model

**Common Issues:**
- If simulator is slow: Use iPhone 15 (not Pro Max) for better performance
- If build fails: Clean build folder with `⌘⇧K`, then rebuild with `⌘B`
- If tests fail: Make sure you're in the right target (app vs tests)

---

### **Phase 1: Foundation (Steps 1-2)**

---

#### **✅ Step 1: Project Setup & Dependencies** ✅ COMPLETED
**Time:** 30-45 minutes
**Goal:** Create Xcode project + add MLX packages

**🤔 Why are we doing this?**

**Why MLX packages?**
- **Local AI = Privacy + Speed + Free**: MLX lets the AI run entirely on your iPhone's chip (no internet needed after download)
- **No API costs**: Unlike ChatGPT API ($$$), this is completely free
- **Offline-first**: Works on airplane mode, no data usage
- **Privacy**: Your messages never leave your device
- **MLX** = Low-level GPU framework (the "engine")
- **MLXLLM** = High-level LLM tools (loads Llama models)
- **MLXLMCommon** = Text generation logic (streaming responses)

**Why folder structure (App, Features, Core)?**
- **App**: Entry point (main file that starts the app)
- **Features**: Each screen/feature in its own folder (easy to find, easy to delete)
  - `Splash/`: Splash screen code lives here
  - `Download/`: Model download screen code
  - `Chat/`: Chat screen code
- **Core**: Shared code used everywhere (LLM engine, design system)
  - `LLM/`: The "brain" (model loading, text generation)
  - `Design/`: Colors, fonts, spacing (so design is consistent)

**Benefits:**
- ✅ Easy to navigate (no hunting for files in a giant mess)
- ✅ Scalable (adding new features = add new folder)
- ✅ Team-friendly (multiple people can work on different features)
- ✅ Testable (each feature can have its own tests)

**📚 What you'll learn:**
- How to create an iOS project targeting iOS 26.0+
- How to add Swift Package Manager dependencies
- Project folder structure organization
- How to verify packages installed correctly

**🎯 Tasks:**

**1.1 Create New Xcode Project**

1. Open Xcode
2. Click "Create New Project" (or File > New > Project)
3. Choose template:
   - Platform: **iOS**
   - Template: **App**
   - Click **Next**
4. Fill in details:
   - Product Name: **lil Claudio**
   - Team: Your Apple ID (or leave as "None")
   - Organization Identifier: **com.yourname** (replace with your name)
   - Interface: **SwiftUI** ⚠️ IMPORTANT
   - Language: **Swift**
   - Storage: **None** (we'll use SwiftData later)
   - Include Tests: **✓ Checked**
   - Click **Next**
5. Save location: Choose `/Users/romainlagrange/Desktop/VibeCoding/lil Claudio/`
6. Click **Create**

**1.2 Add MLX Swift Packages**

1. In Xcode menu: **File > Add Package Dependencies...**
2. In the search bar (top right), paste: `https://github.com/ml-explore/mlx-swift`
3. Click **Add Package** (bottom right)
4. Wait for package to resolve (takes 30-60 seconds)
5. When prompted, select: **MLX** library, click **Add Package**
6. Repeat steps 1-2 for: `https://github.com/ml-explore/mlx-swift-examples`
7. When prompted, select these libraries (hold ⌘ to select multiple):
   - **MLXLLM**
   - **MLXLMCommon**
   - **MLXRandom**
8. Click **Add Package**

**1.3 Create Folder Structure**

1. In Xcode's left sidebar (Navigator), right-click on "lil Claudio" folder
2. Select **New Group**
3. Name it **App**
4. Repeat to create these folders:
   ```
   lil Claudio/
   ├── App/           (for main app file)
   ├── Features/      (for screens)
   │   ├── Splash/
   │   ├── Download/
   │   └── Chat/
   ├── Core/          (for shared code)
   │   ├── LLM/
   │   └── Design/
   └── Tests/         (already created)
   ```
5. Drag `lilClaudioApp.swift` into the **App** folder

**✅ Validation Checkpoints:**

Test your setup:
1. Press `⌘B` to build → should succeed with "Build Succeeded" ✅
2. Press `⌘R` to run → simulator should open showing "Hello, World!" ✅
3. In code, add this line at the top of any file:
   ```swift
   import MLX
   import MLXLLM
   ```
   - If no red errors appear, packages are installed! ✅

**🐛 Troubleshooting:**
- **"Package resolution failed"**:
  - Go to File > Packages > Reset Package Caches
  - Try adding packages again
- **"Build failed - no such module MLX"**:
  - Check that you added packages to the correct target
  - Go to Project settings > Targets > lil Claudio > General > Frameworks
  - MLX, MLXLLM should be listed there

**💾 Commit:** `feat: initial project setup with MLX dependencies`

**🎓 Beginner Tip:** After this step, your Xcode should look like a file tree on the left, code editor in the middle, and various panels on the right. This is your main workspace!

---

#### **Step 2: Design Tokens & System**
**Time:** 20-30 minutes
**Goal:** Create reusable design constants from Figma

**🤔 Why are we doing this?**

**Why Design Tokens?**
Design tokens are like a "design dictionary" - instead of hardcoding colors and sizes everywhere, you define them once and reuse them.

**Without tokens (❌ Bad):**
```swift
Text("Hello").foregroundColor(Color(red: 0.95, green: 0.95, blue: 0.95))
Button(...).background(Color(red: 0.95, green: 0.95, blue: 0.95))
// What if designer changes this color? You have to find and replace EVERYWHERE! 😱
```

**With tokens (✅ Good):**
```swift
Text("Hello").foregroundStyle(.surfaceLight)
Button(...).background(.surfaceLight)
// Change color once in DesignTokens.swift, updates everywhere! 🎉
```

**Benefits:**
- ✅ **Consistency**: All buttons/text use the same exact colors
- ✅ **Easy updates**: Change a color once, whole app updates
- ✅ **Designer-friendly**: Tokens match Figma exactly (less confusion)
- ✅ **Dark mode ready**: Later you can swap token values for dark mode
- ✅ **Less bugs**: No typos like `Color.bleu` instead of `Color.blue`

**📚 What you'll learn:**
- How to organize design tokens in SwiftUI
- Creating color extensions with hex values
- Font system in SwiftUI
- Reusable constants for consistency

**🎯 Tasks:**

**2.1 Create DesignTokens.swift**

1. Right-click on **Core/Design** folder
2. Select **New File...**
3. Choose **Swift File**
4. Name it **DesignTokens.swift**
5. Click **Create**

**2.2 Add Color Extensions**

Copy this code into **DesignTokens.swift**:

```swift
import SwiftUI

// MARK: - Color Extension with Hex Support
extension Color {
    /// Initialize a Color from a hex string (e.g., "f9fafb")
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }

    // MARK: - Background Colors
    static let surfaceLight = Color(hex: "f9fafb")
    static let backgroundWhite = Color.white

    // MARK: - Text Colors
    static let textPrimary = Color.black
    static let textSecondary = Color(hex: "6a7282")
    static let textNeutralDark = Color(hex: "262629")

    // MARK: - UI Colors
    static let accentPrimary = Color(hex: "f28c59")
    static let neutralGray200 = Color(hex: "d9dbe1")
    static let accentBlue = Color(hex: "0088ff")
}

// MARK: - Typography
extension Font {
    static let splashTitle = Font.custom("Crimson Pro", size: 44)
    static let headerTitle = Font.custom("Inter", size: 16).weight(.medium)
    static let inputText = Font.custom("Inter", size: 16).weight(.medium)
    static let bodyText = Font.system(size: 16, weight: .regular)
}

// MARK: - SF Symbols
enum SFSymbols {
    static let sendArrow = "arrow.up"
    static let stopSquare = "stop.fill"
    static let menuIcon = "line.3.horizontal"
    static let helpIcon = "questionmark.circle"
    static let pagerEmoji = "📟"
}

// MARK: - Spacing
enum Spacing {
    static let xs: CGFloat = 4
    static let sm: CGFloat = 8
    static let md: CGFloat = 16
    static let lg: CGFloat = 24
    static let xl: CGFloat = 32
}

// MARK: - Dimensions
enum Dimensions {
    static let cornerRadiusLarge: CGFloat = 26
    static let cornerRadiusSmall: CGFloat = 100
    static let buttonSize: CGFloat = 40
    static let headerButtonSize: CGFloat = 48
    static let inputHeight: CGFloat = 52
    static let progressHeight: CGFloat = 6
}
```

**2.3 Create Preview to Test**

Add this at the bottom of **DesignTokens.swift**:

```swift
// MARK: - Preview
#Preview("Design Tokens") {
    VStack(spacing: 20) {
        // Colors
        HStack(spacing: 10) {
            Circle().fill(.accentPrimary).frame(width: 50, height: 50)
            Circle().fill(.neutralGray200).frame(width: 50, height: 50)
            Circle().fill(.textSecondary).frame(width: 50, height: 50)
        }

        // Fonts
        Text("lil claudio")
            .font(.splashTitle)

        Text("chat")
            .font(.headerTitle)

        Text("message")
            .font(.inputText)
            .foregroundStyle(.textSecondary)

        // Icons
        HStack(spacing: 20) {
            Image(systemName: SFSymbols.sendArrow)
                .font(.system(size: 24))
            Image(systemName: SFSymbols.stopSquare)
                .font(.system(size: 24))
            Image(systemName: SFSymbols.menuIcon)
                .font(.system(size: 24))
        }

        Text(SFSymbols.pagerEmoji)
            .font(.system(size: 72))
    }
    .padding()
}
```

**✅ Validation Checkpoints:**

1. Press `⌘B` to build → should succeed ✅
2. Open **DesignTokens.swift** in editor
3. Click the **"Play" button** next to `#Preview("Design Tokens")` (or press `⌥⌘↵`)
4. Preview panel should appear on the right showing:
   - 3 colored circles (blue, gray, gray)
   - Text in different fonts
   - Icons
   - 📟 emoji ✅

**How to see the preview:**
1. Make sure you're viewing **DesignTokens.swift**
2. Look at the right panel (if hidden: Editor > Canvas in menu bar)
3. Click **"Resume"** if preview is paused

**💾 Commit:** `feat: add design tokens from Figma specs`

**🎓 Beginner Tip:** SwiftUI Previews let you see your UI instantly without running the whole app. It's super useful for designing components!

---

### **Phase 2: Core Models & Logic (TDD) (Steps 3-5)**

---

#### **Step 3: Message Model + Tests**
**Time:** 30-40 minutes
**Goal:** Create the data model for chat messages using Test-Driven Development

**📚 What you'll learn:**
- SwiftData basics (@Model macro)
- Writing tests with Swift Testing framework
- Test-Driven Development (RED → GREEN → REFACTOR)
- CloudKit-compatible SwiftData models

**🎯 What is TDD?**

TDD means: **Test First, Code Second**

1. **RED**: Write a test that fails (because code doesn't exist yet)
2. **GREEN**: Write minimal code to make test pass
3. **REFACTOR**: Improve code without breaking test

**Why?** It ensures your code actually works and prevents bugs!

**🎯 Tasks:**

**3A. RED - Write Failing Tests**

1. In Xcode's left sidebar, find the **Tests** folder
2. Right-click > **New File...**
3. Choose **Unit Test Case Class**
4. Name it **MessageTests.swift**
5. **Delete** all the template code
6. Replace with this:

```swift
import Testing
import SwiftData
@testable import lil_Claudio

@Suite("Message Model Tests")
struct MessageTests {

    @Test("Message created with correct properties")
    func testMessageCreation() {
        let message = Message(role: .user, content: "Hello")

        #expect(message.content == "Hello")
        #expect(message.role == .user)
        #expect(message.timestamp <= Date())
    }

    @Test("Message roles are distinct")
    func testMessageRoles() {
        let userMsg = Message(role: .user, content: "Hi")
        let assistantMsg = Message(role: .assistant, content: "Hello")

        #expect(userMsg.role == .user)
        #expect(assistantMsg.role == .assistant)
        #expect(userMsg.role != assistantMsg.role)
    }
}
```

7. Press `⌘B` to build → **IT WILL FAIL** ❌ (this is expected!)
   - Error: "Cannot find 'Message' in scope"
   - **This is good!** We wrote the test first.

**How to run tests:**
1. Press `⌘U` (runs all tests)
2. Or click the ◇ diamond icon next to `@Suite` to run just these tests
3. Tests will fail with red X ❌

**3B. GREEN - Minimal Implementation**

Now let's make the tests pass:

1. Right-click on **Features/Chat** folder
2. **New Group** named **Models**
3. Right-click on **Models** folder > **New File...**
4. Choose **Swift File**
5. Name it **Message.swift**
6. Replace code with:

```swift
import SwiftData
import Foundation

/// Représente un message dans le chat (utilisateur ou assistant)
@Model
class Message {
    var id: UUID = UUID()
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

/// Rôle de l'expéditeur du message
enum Role: String, Codable {
    case user       // L'utilisateur
    case assistant  // Le modèle LLM
}
```

7. Press `⌘B` to build → should succeed ✅
8. Press `⌘U` to run tests → **TESTS PASS** ✅✅

You'll see green checkmarks ✓ next to each test!

**🎓 Understanding SwiftData:**

```swift
@Model  // ← This tells Swift: "This is a database model"
class Message {
    var id: UUID = UUID()  // ← Must have default value (no .unique for CloudKit)
    // ...
}
```

**Why no `@Attribute(.unique)`?**
- It breaks CloudKit sync
- Instead, use default values (`= UUID()`)

**3C. REFACTOR - Improve (Optional)**

Code is already clean! No refactoring needed.

**✅ Validation Checkpoints:**

1. Press `⌘U` → all tests pass ✅
2. No build warnings ✅
3. Message model compiles ✅

**💾 Commits:**
1. `test: add Message model tests (RED)`
2. `feat: implement Message model with SwiftData (GREEN)`

**🎓 Beginner Tip:** The diamond icons (◇) next to tests let you run individual tests. Click them to see pass/fail status!

---

#### **Step 4: LLMEvaluator + Tests**
**Time:** 45-60 minutes
**Goal:** Handle model loading and text generation with MLX

**📚 What you'll learn:**
- MLX Swift integration
- Async/await for background operations
- @Observable for state management (modern SwiftUI)
- Streaming text generation
- Memory management for ML models

**🎯 What is LLMEvaluator?**

It's the "brain" of the app - the class that:
- Downloads the Llama model (~700 MB)
- Loads it into memory
- Generates text responses
- Streams responses word-by-word

**🎯 Tasks:**

**4A. RED - Write Failing Tests**

1. In **Tests** folder, create **LLMEvaluatorTests.swift**
2. Add this code:

```swift
import Testing
@testable import lil_Claudio

@Suite("LLMEvaluator Tests")
struct LLMEvaluatorTests {

    @Test("Initial state is correct")
    @MainActor
    func testInitialState() {
        let evaluator = LLMEvaluator()

        #expect(evaluator.progress == 0.0)
        #expect(evaluator.running == false)
        #expect(evaluator.output.isEmpty)
    }

    @Test("Running state toggles correctly")
    @MainActor
    func testRunningStateToggle() {
        let evaluator = LLMEvaluator()

        evaluator.running = true
        #expect(evaluator.running == true)

        evaluator.cancel()
        #expect(evaluator.running == false)
    }
}
```

3. Press `⌘U` → **FAIL** ❌ (expected - no LLMEvaluator yet!)

**4B. GREEN - Implementation**

1. Create **Core/LLM/LLMEvaluator.swift**
2. Add this code:

```swift
import MLX
import MLXLLM
import MLXLMCommon
import MLXRandom
import Observation

/// Gère le chargement et l'inférence du modèle LLM (Llama 3.2 1B)
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
    let displayEveryNTokens = 4  // Rafraîchir l'affichage tous les 4 tokens

    /// Charge le modèle Llama 3.2 1B depuis Hugging Face
    func load() async throws {
        guard modelContainer == nil else { return }

        // CRITIQUE: Définir la limite du cache GPU AVANT de charger le modèle
        MLX.GPU.set(cacheLimit: 20 * 1024 * 1024)

        let config = ModelConfiguration(
            id: "mlx-community/Llama-3.2-1B-Instruct-4bit"
        )

        modelContainer = try await LLMModelFactory.shared.loadContainer(
            configuration: config
        ) { [weak self] progress in
            Task { @MainActor in
                self?.progress = progress.fractionCompleted
            }
        }
    }

    /// Génère une réponse en streaming
    func generate(messages: [Message], systemPrompt: String) async -> String {
        guard !running, let container = modelContainer else {
            return ""
        }

        running = true
        output = ""
        error = nil

        // Construire l'historique des messages
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
            // Graine aléatoire pour varier les réponses
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
                    // CRITIQUE: Vérifier que tokens n'est pas vide avant de décoder!
                    guard tokens.count > 0 else { return .more }

                    // Streaming: mise à jour tous les N tokens
                    if tokens.count % displayEveryNTokens == 0 {
                        let text = context.tokenizer.decode(tokens: tokens)
                        Task { @MainActor in
                            self.output = text
                        }
                    }

                    // Condition d'arrêt
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

    /// Annule la génération en cours
    func cancel() {
        running = false
    }
}
```

3. Press `⌘B` to build → should succeed ✅
4. Press `⌘U` to run tests → **PASS** ✅

**🎓 Understanding @Observable:**

```swift
@Observable  // ← Modern way to track state changes (iOS 17+)
@MainActor   // ← All code runs on main thread (safe for UI updates)
class LLMEvaluator {
    var running = false  // ← When this changes, SwiftUI auto-updates UI!
}
```

**Old way (don't use):**
```swift
class LLMEvaluator: ObservableObject {  // ❌ Deprecated!
    @Published var running = false       // ❌ Old API
}
```

**How streaming works:**
1. Model generates tokens (pieces of words)
2. Every 4 tokens, we decode them into text
3. Update `output` property
4. SwiftUI sees change and re-renders UI
5. User sees text appear word-by-word!

**✅ Validation Checkpoints:**

1. Tests pass (⌘U) ✅
2. No build errors ✅
3. No SwiftLint warnings ✅

**💾 Commits:**
1. `test: add LLMEvaluator tests (RED)`
2. `feat: implement LLMEvaluator with streaming (GREEN)`

**🎓 Beginner Tip:** The `@MainActor` annotation is super important! It prevents crashes when updating UI from background threads.

---

#### **Step 5: ChatViewModel + Tests**
**Time:** 45-60 minutes
**Goal:** Orchestrate chat logic (messages + LLM)

**📚 What you'll learn:**
- ViewModel pattern in SwiftUI
- Combining SwiftData with @Observable
- @AppStorage for simple persistence
- Async state management

**🎯 What is ChatViewModel?**

It's the "conductor" of the chat screen - it:
- Manages the list of messages
- Handles sending new messages
- Calls LLMEvaluator to generate responses
- Saves messages to SwiftData

Think of it as the "bridge" between the UI and the model.

**🎯 Tasks:**

**5A. RED - Write Tests**

1. Create **Tests/ChatViewModelTests.swift**
2. Add this code:

```swift
import Testing
import SwiftData
@testable import lil_Claudio

@Suite("ChatViewModel Tests")
struct ChatViewModelTests {

    @Test("Send message adds user message")
    @MainActor
    func testSendMessage() async throws {
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try ModelContainer(
            for: Message.self,
            configurations: config
        )

        let viewModel = ChatViewModel(modelContext: container.mainContext)
        viewModel.inputText = "Hello"

        await viewModel.sendMessage()

        #expect(viewModel.messages.count >= 1)
        #expect(viewModel.messages.first?.content == "Hello")
        #expect(viewModel.inputText.isEmpty)
    }

    @Test("Empty message not sent")
    @MainActor
    func testEmptyMessagePrevention() async throws {
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try ModelContainer(for: Message.self, configurations: config)

        let viewModel = ChatViewModel(modelContext: container.mainContext)
        viewModel.inputText = ""

        await viewModel.sendMessage()

        #expect(viewModel.messages.isEmpty)
    }

    @Test("Clear chat removes all messages")
    @MainActor
    func testClearChat() async throws {
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try ModelContainer(for: Message.self, configurations: config)

        let viewModel = ChatViewModel(modelContext: container.mainContext)

        // Ajouter un message de test
        let msg1 = Message(role: .user, content: "Test 1")
        container.mainContext.insert(msg1)
        try container.mainContext.save()

        viewModel.loadMessages()
        #expect(viewModel.messages.count == 1)

        viewModel.clearChat()
        #expect(viewModel.messages.isEmpty)
    }
}
```

3. Press `⌘U` → **FAIL** ❌ (no ChatViewModel yet)

**5B. GREEN - Implementation**

1. Create **Features/Chat/ViewModels/ChatViewModel.swift**
2. Add this code:

```swift
import SwiftUI
import SwiftData
import Observation

/// Gère la logique du chat (messages, envoi, réception)
@Observable
@MainActor
class ChatViewModel {
    var inputText = ""
    var isGenerating = false
    var messages: [Message] = []

    private let llmEvaluator = LLMEvaluator()
    private var modelContext: ModelContext

    @AppStorage("systemPrompt")
    private var systemPrompt = "you are a helpful assistant"

    init(modelContext: ModelContext) {
        self.modelContext = modelContext
        loadMessages()
    }

    /// Charge les messages depuis SwiftData
    func loadMessages() {
        let descriptor = FetchDescriptor<Message>(
            sortBy: [SortDescriptor(\.timestamp)]
        )
        messages = (try? modelContext.fetch(descriptor)) ?? []
    }

    /// Envoie un message et génère une réponse
    func sendMessage(_ text: String? = nil) async {
        let messageText = text ?? inputText
        guard !messageText.isEmpty else { return }

        // Ajouter le message utilisateur
        let userMessage = Message(role: .user, content: messageText)
        modelContext.insert(userMessage)
        try? modelContext.save()

        inputText = ""
        loadMessages()
        isGenerating = true

        // Générer la réponse
        let response = await llmEvaluator.generate(
            messages: messages,
            systemPrompt: systemPrompt
        )

        // Ajouter le message de l'assistant
        let assistantMessage = Message(role: .assistant, content: response)
        modelContext.insert(assistantMessage)
        try? modelContext.save()

        loadMessages()
        isGenerating = false
    }

    /// Annule la génération en cours et garde la réponse partielle
    func cancelGeneration() {
        llmEvaluator.cancel()

        // Garder la réponse partielle si elle existe
        if !llmEvaluator.output.isEmpty {
            let partialMessage = Message(
                role: .assistant,
                content: llmEvaluator.output
            )
            modelContext.insert(partialMessage)
            try? modelContext.save()
            loadMessages()
        }

        isGenerating = false
    }

    /// Supprime tous les messages
    func clearChat() {
        for message in messages {
            modelContext.delete(message)
        }
        try? modelContext.save()
        loadMessages()
    }
}
```

3. Press `⌘B` to build → should succeed ✅
4. Press `⌘U` to run tests → **PASS** ✅

**🎓 Understanding the Flow:**

```
User types "Hello" and presses send
    ↓
ChatViewModel.sendMessage() called
    ↓
1. Create Message(role: .user, content: "Hello")
2. Save to SwiftData
3. Clear input field
4. Call LLMEvaluator.generate()
    ↓
LLMEvaluator generates response
    ↓
5. Create Message(role: .assistant, content: "Hi there!")
6. Save to SwiftData
7. Reload messages
    ↓
UI updates automatically (thanks to @Observable!)
```

**✅ Validation Checkpoints:**

1. All tests pass (⌘U) ✅
2. No build errors ✅
3. SwiftLint clean ✅

**💾 Commits:**
1. `test: add ChatViewModel tests (RED)`
2. `feat: implement ChatViewModel (GREEN)`

**🎓 Beginner Tip:** The `isStoredInMemoryOnly: true` in tests means the data disappears after the test. This keeps tests isolated!

---

### **Phase 3: UI Screens (Steps 6-8)**

_(Continued in next message due to length...)_

**Current Status:** We've completed the foundation! ✅
- ✅ Models (Message, LLMEvaluator, ChatViewModel)
- ✅ Tests (all passing!)
- ⏳ Next: Build the actual screens users will see

**🎓 Take a Break!**
You've done the hardest part (the "brain" of the app). The UI will be more visual and fun! When ready, we'll tackle:
- Step 6: Splash screen
- Step 7: Download screen
- Step 8: Chat screen

---

## 📚 Additional Resources

- [CLAUDE.md](./CLAUDE.md) - Detailed technical guidelines
- [MLX Swift Examples](https://github.com/ml-explore/mlx-swift-examples)
- [SwiftData Docs](https://developer.apple.com/documentation/swiftdata)
- [Swift Testing](https://developer.apple.com/documentation/testing)

---

**Let's build this step by step! 🚀**
