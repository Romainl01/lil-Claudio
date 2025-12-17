import SwiftUI
import UIKit

/// Vue SwiftUI qui wrap UITextView pour permettre la sélection native de texte
/// Utilise UIKit pour avoir le comportement exact de l'app Messages (double-tap, long-press, etc.)
struct SelectableText: UIViewRepresentable {
    let attributedText: AttributedString?
    let plainText: String?
    let font: UIFont
    let textColor: UIColor

    // Initializer pour AttributedString (markdown)
    init(attributedText: AttributedString, font: UIFont = .systemFont(ofSize: 16), textColor: UIColor = .label) {
        self.attributedText = attributedText
        self.plainText = nil
        self.font = font
        self.textColor = textColor
    }

    // Initializer pour texte brut
    init(text: String, font: UIFont = .systemFont(ofSize: 16), textColor: UIColor = .label) {
        self.attributedText = nil
        self.plainText = text
        self.font = font
        self.textColor = textColor
    }

    func makeUIView(context: Context) -> UITextView {
        let textView = UITextView()

        // Configuration pour sélection (pas d'édition)
        textView.isEditable = false
        textView.isSelectable = true
        textView.isScrollEnabled = false

        // Style transparent (comme Text SwiftUI)
        textView.backgroundColor = .clear
        textView.textContainerInset = .zero
        textView.textContainer.lineFragmentPadding = 0

        // Désactive les interactions non désirées
        textView.dataDetectorTypes = []
        textView.linkTextAttributes = [:]

        return textView
    }

    func updateUIView(_ textView: UITextView, context: Context) {
        // Appliquer le texte (AttributedString ou plain text)
        if let attributedText = attributedText {
            // Convertir AttributedString → NSAttributedString
            let nsAttributedString = NSMutableAttributedString(attributedText)

            // Force notre font et couleur sur TOUT le texte (override markdown font)
            let range = NSRange(location: 0, length: nsAttributedString.length)
            nsAttributedString.addAttribute(.font, value: font, range: range)
            nsAttributedString.addAttribute(.foregroundColor, value: textColor, range: range)

            textView.attributedText = nsAttributedString
        } else if let plainText = plainText {
            textView.text = plainText
            textView.font = font
            textView.textColor = textColor
        }

        // Invalidate intrinsic content size pour que SwiftUI recalcule la taille
        textView.invalidateIntrinsicContentSize()
    }

    func sizeThatFits(_ proposal: ProposedViewSize, uiView: UITextView, context: Context) -> CGSize? {
        // Calculer la taille nécessaire pour le texte
        let width = proposal.width ?? UIView.layoutFittingCompressedSize.width
        let size = uiView.sizeThatFits(CGSize(width: width, height: .greatestFiniteMagnitude))
        return size
    }
}
