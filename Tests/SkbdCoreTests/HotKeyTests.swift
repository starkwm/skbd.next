import Carbon
import Darwin
import Foundation
import Testing

@testable import SkbdCore

@Suite("HotKeyTests")
struct HotKeyTests {
  @Test("from event with no modifiers")
  func fromEventWithNoModifiers() async throws {
    let event = CGEvent(keyboardEventSource: nil, virtualKey: CGKeyCode(0), keyDown: true)!
    event.flags = CGEventFlags()

    let hotKey = HotKey.from(event: event)

    #expect(hotKey.modifierFlags == [])
    #expect(hotKey.key == 0)
  }

  @Test("from event with cmd modifier")
  func fromEventWithCmdModifier() async throws {
    let event = CGEvent(keyboardEventSource: nil, virtualKey: CGKeyCode(0), keyDown: true)!
    event.flags = .maskCommand

    let hotKey = HotKey.from(event: event)

    #expect(hotKey.modifierFlags == .cmd)
    #expect(hotKey.key == 0)
  }

  @Test("from event with multiple modifiers")
  func fromEventWithMultipleModifiers() async throws {
    let event = CGEvent(keyboardEventSource: nil, virtualKey: CGKeyCode(0), keyDown: true)!
    event.flags = [.maskCommand, .maskShift]

    let hotKey = HotKey.from(event: event)

    #expect(hotKey.modifierFlags == [.cmd, .shift])
    #expect(hotKey.key == 0)
  }

  @Test("from event with special key")
  func fromEventWithSpecialKey() async throws {
    let event = CGEvent(keyboardEventSource: nil, virtualKey: CGKeyCode(36), keyDown: true)!
    event.flags = CGEventFlags()

    let hotKey = HotKey.from(event: event)

    #expect(hotKey.modifierFlags == [])
    #expect(hotKey.key == 36)
  }

  @Test("from event with invalid keycode")
  func fromEventWithInvalidKeycode() async throws {
    let event = CGEvent(keyboardEventSource: nil, virtualKey: CGKeyCode(999), keyDown: true)!
    event.flags = .maskCommand

    let hotKey = HotKey.from(event: event)

    #expect(hotKey.modifierFlags == .cmd)
    #expect(hotKey.key == 999)
  }

  @Test("equality with identical hotkeys")
  func equalityWithIdenticalHotkeys() async throws {
    let hk1 = HotKey(modifierFlags: .cmd, key: 0)
    let hk2 = HotKey(modifierFlags: .cmd, key: 0)

    #expect(hk1 == hk2)
  }

  @Test("inequality with different keys")
  func inequalityWithDifferentKeys() async throws {
    let hk1 = HotKey(modifierFlags: .cmd, key: 0)
    let hk2 = HotKey(modifierFlags: .cmd, key: 1)

    #expect(hk1 != hk2)
  }

  @Test("inequality with different modifiers")
  func inequalityWithDifferentModifiers() async throws {
    let hk1 = HotKey(modifierFlags: .cmd, key: 0)
    let hk2 = HotKey(modifierFlags: .alt, key: 0)

    #expect(hk1 != hk2)
  }

  @Test("equality with generic matching left/right modifiers")
  func equalityWithGenericMatchingLeftRightModifiers() async throws {
    let hk1 = HotKey(modifierFlags: .alt, key: 0)
    let hk2 = HotKey(modifierFlags: .lalt, key: 0)
    let hk3 = HotKey(modifierFlags: .ralt, key: 0)

    #expect(hk1 == hk2)
    #expect(hk1 == hk3)
  }

  @Test("inequality with different left/right modifiers")
  func inequalityWithDifferentLeftRightModifiers() async throws {
    let hk1 = HotKey(modifierFlags: .lalt, key: 0)
    let hk2 = HotKey(modifierFlags: .ralt, key: 0)

    #expect(hk1 != hk2)
  }

  @Test("equality with multiple equivalent modifiers")
  func equalityWithMultipleEquivalentModifiers() async throws {
    let hk1 = HotKey(modifierFlags: [.alt, .cmd], key: 0)
    let hk2 = HotKey(modifierFlags: [.lalt, .rcmd], key: 0)

    #expect(hk1 == hk2)
  }

  @Test("equality with fn modifier")
  func equalityWithFnModifier() async throws {
    let hk1 = HotKey(modifierFlags: [.cmd, .fn], key: 0)
    let hk2 = HotKey(modifierFlags: [.cmd, .fn], key: 0)

    #expect(hk1 == hk2)
  }

  @Test("inequality with fn modifier difference")
  func inequalityWithFnModifierDifference() async throws {
    let hk1 = HotKey(modifierFlags: [.cmd, .fn], key: 0)
    let hk2 = HotKey(modifierFlags: .cmd, key: 0)

    #expect(hk1 != hk2)
  }

  @Test("equality with empty modifiers")
  func equalityWithEmptyModifiers() async throws {
    let hk1 = HotKey(modifierFlags: [], key: 0)
    let hk2 = HotKey(modifierFlags: [], key: 0)

    #expect(hk1 == hk2)
  }

  @Test("description formatting")
  func descriptionFormatting() async throws {
    let testCases: [(HotKey, String)] = [
      (HotKey(modifierFlags: .cmd, key: 0), "<HotKey flags: <ModifierFlags cmd>, key: a>"),
      (HotKey(modifierFlags: .lcmd, key: 0), "<HotKey flags: <ModifierFlags lcmd>, key: a>"),
      (HotKey(modifierFlags: .rcmd, key: 0), "<HotKey flags: <ModifierFlags rcmd>, key: a>"),
      (HotKey(modifierFlags: .alt, key: 0), "<HotKey flags: <ModifierFlags alt>, key: a>"),
      (HotKey(modifierFlags: .lalt, key: 0), "<HotKey flags: <ModifierFlags lalt>, key: a>"),
      (HotKey(modifierFlags: .ralt, key: 0), "<HotKey flags: <ModifierFlags ralt>, key: a>"),
      (HotKey(modifierFlags: .shift, key: 0), "<HotKey flags: <ModifierFlags shift>, key: a>"),
      (HotKey(modifierFlags: .lshift, key: 0), "<HotKey flags: <ModifierFlags lshift>, key: a>"),
      (HotKey(modifierFlags: .rshift, key: 0), "<HotKey flags: <ModifierFlags rshift>, key: a>"),
      (HotKey(modifierFlags: .ctrl, key: 0), "<HotKey flags: <ModifierFlags ctrl>, key: a>"),
      (HotKey(modifierFlags: .lctrl, key: 0), "<HotKey flags: <ModifierFlags lctrl>, key: a>"),
      (HotKey(modifierFlags: .rctrl, key: 0), "<HotKey flags: <ModifierFlags rctrl>, key: a>"),
      (HotKey(modifierFlags: .fn, key: 0), "<HotKey flags: <ModifierFlags fn>, key: a>"),
      (
        HotKey(modifierFlags: [.cmd, .shift], key: 0),
        "<HotKey flags: <ModifierFlags cmd|shift>, key: a>"
      ),
      (
        HotKey(modifierFlags: [.lcmd, .rshift], key: 0),
        "<HotKey flags: <ModifierFlags lcmd|rshift>, key: a>"
      ),
      (
        HotKey(modifierFlags: [.lalt, .rcmd, .rshift], key: 0),
        "<HotKey flags: <ModifierFlags lalt|rcmd|rshift>, key: a>"
      ),
      (
        HotKey(modifierFlags: [.cmd, .fn], key: 0),
        "<HotKey flags: <ModifierFlags cmd|fn>, key: a>"
      ),
      (HotKey(modifierFlags: [], key: 0), "<HotKey flags: <ModifierFlags none>, key: a>"),
      (HotKey(modifierFlags: .cmd, key: 36), "<HotKey flags: <ModifierFlags cmd>, key: return>"),
      (HotKey(modifierFlags: .cmd, key: 999), "<HotKey flags: <ModifierFlags cmd>, key: unknown>"),
    ]

    for (hotKey, expectedDescription) in testCases {
      #expect(hotKey.description == expectedDescription)
    }
  }

  @Test("execute with nil command")
  func executeWithNilCommand() async throws {
    let hotKey = HotKey(modifierFlags: .cmd, key: 0)
    var executed = false

    #expect(hotKey.command == nil)

    hotKey.execute(onExecute: { executed = true })

    #expect(executed == false)
  }

  @Test("execute with successful command")
  func executeWithSuccessfulCommand() async throws {
    let hotKey = HotKey(modifierFlags: .cmd, key: 0, command: "true")
    var executed = false

    hotKey.execute { executed = true }

    #expect(executed)
  }

  @Test("execute with failing command")
  func executeWithFailingCommand() async throws {
    let hotKey = HotKey(modifierFlags: .cmd, key: 0, command: "false")
    var executed = false

    hotKey.execute { executed = true }

    #expect(executed)
  }

  @Test("execute falls back to /bin/bash when SHELL is unset")
  func executeFallsBackToBashWhenShellUnset() async throws {
    let originalShell = getenv("SHELL").map { String(cString: $0) }

    unsetenv("SHELL")

    defer {
      if let original = originalShell {
        setenv("SHELL", original, 1)
      } else {
        unsetenv("SHELL")
      }
    }

    let hotKey = HotKey(modifierFlags: .cmd, key: 0, command: "true")
    var executed = false

    hotKey.execute { executed = true }

    #expect(executed)
  }

  @Test("execute falls back to /bin/bash when SHELL is empty")
  func executeFallsBackToBashWhenShellEmpty() async throws {
    let originalShell = getenv("SHELL").map { String(cString: $0) }

    setenv("SHELL", "", 1)

    defer {
      if let original = originalShell {
        setenv("SHELL", original, 1)
      } else {
        unsetenv("SHELL")
      }
    }

    let hotKey = HotKey(modifierFlags: .cmd, key: 0, command: "true")
    var executed = false

    hotKey.execute { executed = true }

    #expect(executed)
  }
  }
}
