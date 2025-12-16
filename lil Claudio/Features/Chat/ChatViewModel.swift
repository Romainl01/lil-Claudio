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

      @ObservationIgnored
    @AppStorage("systemPrompt") private var systemPrompt = "you are a helpful assistant"

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
          let userMessage = Message(role: .user, content:
  messageText)
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
          let assistantMessage = Message(role: .assistant,
  content: response)
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
  }//
//  ChatViewModel.swift
//  lil Claudio
//
//  Created by Romain  Lagrange on 16/12/2025.
//

