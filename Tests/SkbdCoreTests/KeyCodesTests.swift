import Carbon
import Testing

@testable import SkbdCore

@Suite("KeyCodesTests")
struct KeyCodesTests {
  @Test("key with unknown key code")
  func keyWithUnknownKeyCode() async throws {
    let result = KeyCodes.key(for: 123_456_789)
    #expect(result == "unknown")
  }
}
