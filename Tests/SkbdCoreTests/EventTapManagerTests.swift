import Carbon
import CoreGraphics
import Foundation
import Testing

@testable import SkbdCore

@Suite("EventTapManager")
struct EventTapManagerTests {
  @Test("processEvent with unhannled type")
  func testProcessEventWithUnhandledType() throws {
    let manager = EventTapManager(hotKeys: [])
    let source = CGEventSource(stateID: .hidSystemState)
    let event = CGEvent(mouseEventSource: source, mouseType: .leftMouseDown, mouseCursorPosition: .zero, mouseButton: .left)!

    let result = manager.process(event: event, type: .leftMouseDown)

    #expect(result == event)
  }

  @Test("processEvent with keyDown no match")
  func testProcessEventKeyDownNoMatch() throws {
    let manager = EventTapManager(hotKeys: [])
    let source = CGEventSource(stateID: .hidSystemState)
    let event = CGEvent(keyboardEventSource: source, virtualKey: 0, keyDown: true)!

    let result = manager.process(event: event, type: .keyDown)

    #expect(result == event)
  }

  @Test("processEvent with keyDown consume match")
  func testProcessEventKeyDownConsumeMatch() throws {
    let hotkey = HotKey(modifierFlags: [], key: 0, command: "true")
    let manager = EventTapManager(hotKeys: [hotkey])
    let source = CGEventSource(stateID: .hidSystemState)
    let event = CGEvent(keyboardEventSource: source, virtualKey: 0, keyDown: true)!

    let result = manager.process(event: event, type: .keyDown)

    #expect(result == nil)
  }

  @Test("processEvent with keyDown consume match")
  func testProcessEventKeyDownPassthroughMatch() throws {
    let hotkey = HotKey(modifierFlags: [], key: 0, command: "true", passthrough: true)
    let manager = EventTapManager(hotKeys: [hotkey])
    let source = CGEventSource(stateID: .hidSystemState)
    let event = CGEvent(keyboardEventSource: source, virtualKey: 0, keyDown: true)!

    let result = manager.process(event: event, type: .keyDown)

    #expect(result == event)
  }
}
