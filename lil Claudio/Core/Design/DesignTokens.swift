//
//  DesignTokens.swift
//  lil Claudio
//
//  Created by Romain  Lagrange on 14/12/2025.
//

import SwiftUI

// MARK: - Color Extension with Hex Support
extension Color {
    /// Initialise une couleur depuis une chaîne hexadécimale (ex: "f9fafb")
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
    static let surfaceLight = Color(hex: "f9fafb")      // Fond principal
    static let backgroundWhite = Color.white             // Fond splash screen

    // MARK: - Text Colors
    static let textPrimary = Color.black                 // Texte principal (#000000)
    static let textSecondary = Color(hex: "6a7282")      // Texte secondaire / placeholder
    static let textNeutralDark = Color(hex: "262629")    // Texte header
    static let textButtonIcon = Color(hex: "404040")     // Icônes boutons glass (from Figma)

    // MARK: - UI Colors
    static let accentPrimary = Color(hex: "f28c59")      // Barre de progression (orange/corail)
    static let neutralGray200 = Color(hex: "d9dbe1")     // Fond input, track progress
    static let accentBlue = Color(hex: "0088ff")         // Boutons (si nécessaire)
}

// MARK: - Typography
extension Font {
    static let splashTitle = Font.custom("Crimson Pro", size: 44)         // "lil claudio"
    static let headerTitle = Font.custom("Inter", size: 16).weight(.medium) // "chat"
    static let inputText = Font.custom("Inter", size: 16).weight(.medium)   // Placeholder input
    static let bodyText = Font.system(size: 16, weight: .regular)           // Texte messages
}

// MARK: - SF Symbols
enum SFSymbols {
    static let sendArrow = "arrow.up"              // Bouton envoyer
    static let stopSquare = "stop.fill"            // Bouton stop génération
    static let menuIcon = "line.3.horizontal"      // Bouton gauche header (hambourger)
    static let helpIcon = "questionmark.circle"    // Bouton droite header
    static let pagerEmoji = "📟"                   // Logo app
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
    static let cornerRadiusLarge: CGFloat = 26   // Champ de saisie
    static let cornerRadiusSmall: CGFloat = 100  // Boutons (circulaires)
    static let buttonSize: CGFloat = 40          // Boutons icône
    static let headerButtonSize: CGFloat = 48    // Boutons header
    static let inputHeight: CGFloat = 52         // Hauteur champ de saisie
    static let progressHeight: CGFloat = 6       // Hauteur barre de progression
}

// MARK: - Preview
#Preview("Design Tokens") {
    VStack(spacing: 20) {
        // Couleurs
        HStack(spacing: 10) {
            Circle().fill(Color.accentPrimary).frame(width: 50, height: 50)
            Circle().fill(Color.neutralGray200).frame(width: 50, height: 50)
            Circle().fill(Color.textSecondary).frame(width: 50, height: 50)
        }

        // Typographie
        Text("lil claudio")
            .font(.splashTitle)

        Text("chat")
            .font(.headerTitle)

        Text("message")
            .font(.inputText)
            .foregroundStyle(Color.textSecondary)

        // Icônes
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
