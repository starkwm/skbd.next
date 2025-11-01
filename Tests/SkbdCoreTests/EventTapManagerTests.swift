import Carbon
import CoreGraphics
import Foundation
import Testing

@testable import SkbdCore

@Suite("EventTapManager")
struct EventTapManagerTests {
  @Test("processEvent with keyDown no match")
  func testProcessEventKeyDownNoMatch() throws {
    let manager = EventTapManager(hotKeys: [])
    let source = CGEventSource(stateID: .hidSystemState)
    let event = CGEvent(keyboardEventSource: source, virtualKey: 0, keyDown: true)!

    let result = manager.process(event: event, type: .keyDown)

    #expect(result == event)
  }

  @Test("processEvent with keyDown match")
  func testProcessEventKeyDownMatch() throws {
    let hotkey = HotKey(modifierFlags: [], key: 0, command: "true")
    let manager = EventTapManager(hotKeys: [hotkey])
    let source = CGEventSource(stateID: .hidSystemState)
    let event = CGEvent(keyboardEventSource: source, virtualKey: 0, keyDown: true)!

    let result = manager.process(event: event, type: .keyDown)

    #expect(result == nil)
  }
}
