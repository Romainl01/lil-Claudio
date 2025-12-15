import MLX
import MLXLLM
import MLXLMCommon
import MLXRandom
import Observation
import Foundation

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
