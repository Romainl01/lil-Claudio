import Testing
import SwiftData
import Foundation
@testable import lil_Claudio

@Suite("Message Model Tests")
struct MessageTests {

    @Test("Message created with correct properties")
    func testMessageCreation() {
        let message = Message(role: .user, content: "Hello")

        #expect(message.content == "Hello")
        #expect(message.role == .user)
        #expect(message.timestamp <= Date())
    }

    @Test("Message roles are distinct")
    func testMessageRoles() {
        let userMsg = Message(role: .user, content: "Hi")
        let assistantMsg = Message(role: .assistant, content: "Hello")

        #expect(userMsg.role == .user)
        #expect(assistantMsg.role == .assistant)
        #expect(userMsg.role != assistantMsg.role)
    }
}
