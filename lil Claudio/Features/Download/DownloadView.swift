import SwiftUI

/// Écran de téléchargement du modèle LLM
/// Affiche une barre de progression pendant le téléchargement (~700MB)
struct DownloadView: View {
    // État pour suivre la progression du téléchargement
    @State private var llmEvaluator = LLMEvaluator()

    // Sauvegarde si le modèle est téléchargé (persiste entre les lancements)
    @AppStorage("isModelDownloaded") private var isModelDownloaded = false

    // Contrôle la navigation vers ChatView une fois le téléchargement terminé
    @State private var navigateToChatView = false

    // Affiche les erreurs si le téléchargement échoue
    @State private var errorMessage: String?

    var body: some View {
        NavigationStack {
            ZStack {
                // Fond (couvre tout l'écran)
                Color.surfaceLight
                    .ignoresSafeArea()

                // Contenu centré
                VStack(spacing: 32) {
                    // Logo (même que splash screen)
                    Text(SFSymbols.pagerEmoji)
                        .font(.system(size: 80))

                    // Titre
                    Text("downloading model...")
                        .font(.headerTitle)
                        .foregroundStyle(Color.textSecondary)

                    // Barre de progression
                    VStack(spacing: 12) {
                        // La barre elle-même
                        ProgressView(value: llmEvaluator.progress, total: 1.0)
                            .progressViewStyle(.linear)
                            .tint(Color.accentPrimary)
                            .frame(height: Dimensions.progressHeight)

                        // Pourcentage (0% → 100%)
                        Text("\(Int(llmEvaluator.progress * 100))%")
                            .font(.inputText)
                            .foregroundStyle(Color.textSecondary)
                    }
                    .padding(.horizontal, 32)

                    // Afficher l'erreur si elle existe
                    if let error = errorMessage {
                        Text(error)
                            .font(.caption)
                            .foregroundStyle(.red)
                            .padding()
                            .multilineTextAlignment(.center)
                    }
                }
            }
            .task {
                // Lance le téléchargement dès que l'écran apparaît
                await downloadModel()
            }
            .navigationDestination(isPresented: $navigateToChatView) {
                // ChatView() // TODO: Uncomment in Step 8 when ChatView is created
                Text("Chat will appear here")
                    .font(.headerTitle)
                    .foregroundStyle(Color.textSecondary)
            }
        }
    }

    /// Télécharge le modèle et navigue vers ChatView une fois terminé
    private func downloadModel() async {
        #if targetEnvironment(simulator)
        // Mode simulateur : téléchargement simulé pour tester l'UI
        // (MLX ne fonctionne pas dans le simulateur iOS)
        for i in 0...10 {
            llmEvaluator.progress = Double(i) / 10.0
            try? await Task.sleep(for: .milliseconds(500))
        }

        isModelDownloaded = true
        navigateToChatView = true

        #else
        // Appareil réel : téléchargement du modèle LLM via MLX
        do {
            try await llmEvaluator.load()

            // Succès : marquer comme téléchargé et naviguer vers le chat
            isModelDownloaded = true
            navigateToChatView = true

        } catch {
            // En cas d'erreur (pas de connexion internet, etc.)
            errorMessage = error.localizedDescription
            print("Erreur de téléchargement du modèle: \(error)")
        }
        #endif
    }
}

// Preview pour voir le design sans télécharger le vrai modèle
#Preview("Download Screen") {
    DownloadView()
}
