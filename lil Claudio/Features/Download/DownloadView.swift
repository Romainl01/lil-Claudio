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

    var body: some View {
        NavigationStack {
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
                    ProgressView(value: llmEvaluator.progress)
                        .progressViewStyle(.linear)
                        .tint(Color.accentPrimary) // Couleur orange du design
                        .frame(height: Dimensions.progressHeight)

                    // Pourcentage (0% → 100%)
                    Text("\(Int(llmEvaluator.progress * 100))%")
                        .font(.inputText)
                        .foregroundStyle(Color.textSecondary)
                }
                .padding(.horizontal, 32)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color.surfaceLight) // Couleur de fond du design
            .task {
                // ⚠️ Cette ligne lance le téléchargement dès que l'écran apparaît
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
        do {
            // Lance le téléchargement (LLMEvaluator met à jour sa propriété `progress`)
            try await llmEvaluator.load()

            // Succès! Marquer comme téléchargé
            isModelDownloaded = true

            // Naviguer vers le chat
            navigateToChatView = true

        } catch {
            // En cas d'erreur (pas de connexion internet, etc.)
            print("Erreur de téléchargement: \(error)")
            // TODO (V2): Afficher une alerte à l'utilisateur
        }
    }
}

// Preview pour voir le design sans télécharger le vrai modèle
#Preview("Download Screen") {
    DownloadView()
}
