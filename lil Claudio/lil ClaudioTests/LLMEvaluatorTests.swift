import Testing
@testable import lil_Claudio

@Suite("LLMEvaluator Tests")
struct LLMEvaluatorTests {

    @Test("Initial state is correct")
    @MainActor
    func testInitialState() {
        let evaluator = LLMEvaluator()

        #expect(evaluator.progress == 0.0)
        #expect(evaluator.running == false)
        #expect(evaluator.output.isEmpty)
    }

    @Test("Running state toggles correctly")
    @MainActor
    func testRunningStateToggle() {
        let evaluator = LLMEvaluator()

        evaluator.running = true
        #expect(evaluator.running == true)

        evaluator.cancel()
        #expect(evaluator.running == false)
    }
}
