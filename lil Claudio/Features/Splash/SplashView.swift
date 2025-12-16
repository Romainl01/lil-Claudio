//
//  SplashView.swift
//  lil Claudio
//
//  Created by Romain  Lagrange on 16/12/2025.
//

import Foundation
import SwiftUI

/// L'écran de démarrage affiché au lancement de l'app
struct SplashView: View {
    // MARK: - State

    /// Indique si on doit afficher l'écran suivant (après le délai)
    @State private var showNextScreen = false

    /// Vérifie si le modèle LLM est déjà téléchargé
    @AppStorage("isModelDownloaded") private var isModelDownloaded = false

    // MARK: - Body

    var body: some View {
        if showNextScreen {
            // Navigation intelligente après le splash
            if isModelDownloaded {
                // TODO: Afficher ChatView (Step 8)
                Text("Chat will appear here (Step 8)")
                    .font(.headline)
                    .foregroundStyle(.black)
            } else {
                // Afficher DownloadView (Step 7)
                DownloadView()
            }
        } else {
            // L'écran de splash lui-même
            splashContent
        }
    }

    // MARK: - Splash Content

    /// Le contenu visuel du splash screen
    private var splashContent: some View {
        ZStack {
            // Fond de couleur surfaceLight (gris très clair)
            Color.surfaceLight
                .ignoresSafeArea()

            // Logo + Titre au centre
            VStack(spacing: Spacing.lg) {
                // Logo: emoji pager 📟
                Text(SFSymbols.pagerEmoji)
                    .font(.system(size: 72))

                // Titre: "lil claudio"
                Text("lil claudio")
                    .font(.splashTitle)  // Crimson Pro 44pt
                    .foregroundStyle(Color.textPrimary)
            }
        }
        .task {
            // Attendre 1.5 secondes avant de naviguer
            try? await Task.sleep(for: .seconds(1.5))
            showNextScreen = true
        }
    }
}

// MARK: - Preview

#Preview("Splash Screen") {
    SplashView()
}
