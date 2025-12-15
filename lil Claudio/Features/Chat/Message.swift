import SwiftData
import Foundation

/// Représente un message dans le chat (utilisateur ou assistant)
@Model
class Message {
    var id: UUID
    var role: Role
    var content: String
    var timestamp: Date

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
