# 📟 Local LLM Chat

iOS chat app with **Llama 3.2 1B running locally** (no internet).

## ✨ Features

- Single chat thread
- Streaming responses
- Customizable system prompt
- Model auto-download (~700 MB)

## 🛠️ Stack

- **UI:** SwiftUI (iOS 17+)
- **LLM:** MLX + Llama 3.2 1B (4-bit quantized)
- **Data:** SwiftData
- **Testing:** Swift Testing (TDD approach)

## 📐 Architecture

```
Message (SwiftData) ──> ChatViewModel ──> ChatView
                              ↓
                       LLMEvaluator (MLX)
```

---

Inspired by [Fullmoon](https://github.com/mainframecomputer/fullmoon-ios)
