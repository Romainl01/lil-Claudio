import Testing
import SwiftData
@testable import lil_Claudio

  @Suite("ChatViewModel Tests")
  struct ChatViewModelTests {

      @Test("Send message adds user message")
      @MainActor
      func testSendMessage() async throws {
          let config = ModelConfiguration(isStoredInMemoryOnly:
  true)
          let container = try ModelContainer(
              for: Message.self,
              configurations: config
          )

          let viewModel = ChatViewModel(modelContext:
  container.mainContext)
          viewModel.inputText = "Hello"

          await viewModel.sendMessage()

          #expect(viewModel.messages.count >= 1)
          #expect(viewModel.messages.first?.content == "Hello")
          #expect(viewModel.inputText.isEmpty)
      }

      @Test("Empty message not sent")
      @MainActor
      func testEmptyMessagePrevention() async throws {
          let config = ModelConfiguration(isStoredInMemoryOnly:
  true)
          let container = try ModelContainer(for: Message.self,
  configurations: config)

          let viewModel = ChatViewModel(modelContext:
  container.mainContext)
          viewModel.inputText = ""

          await viewModel.sendMessage()

          #expect(viewModel.messages.isEmpty)
      }

      @Test("Clear chat removes all messages")
      @MainActor
      func testClearChat() async throws {
          let config = ModelConfiguration(isStoredInMemoryOnly:
  true)
          let container = try ModelContainer(for: Message.self,
  configurations: config)

          let viewModel = ChatViewModel(modelContext:
  container.mainContext)

          // Ajouter un message de test
          let msg1 = Message(role: .user, content: "Test 1")
          container.mainContext.insert(msg1)
          try container.mainContext.save()

          viewModel.loadMessages()
          #expect(viewModel.messages.count == 1)

          viewModel.clearChat()
          #expect(viewModel.messages.isEmpty)
      }
  }//
//  ChatViewModelTests.swift
//  lil Claudio
//
//  Created by Romain  Lagrange on 16/12/2025.
//

