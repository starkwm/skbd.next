import Carbon
import Testing

@testable import SkbdCore

@Suite("ModifierFlags")
struct ModifierFlagsTests {
  @Test("from with no modifiers")
  func fromWithNoModifiers() async throws {
    let eventFlags = CGEventFlags()

    #expect(ModifierFlags.from(eventFlags) == ModifierFlags())
  }

  @Test("from with single modifiers")
  func fromWithSingleModifiers() async throws {
    var eventFlags = CGEventFlags()
    eventFlags.insert(.maskShift)

    #expect(ModifierFlags.from(eventFlags) == .shift)
  }

  @Test("from with fn modifier")
  func fromWithFnModifier() async throws {
    var eventFlags = CGEventFlags()
    eventFlags.insert(.maskSecondaryFn)

    #expect(ModifierFlags.from(eventFlags) == .fn)
  }

  @Test("from with multiple modifiers")
  func fromWithMultipleModifiers() async throws {
    var eventFlags = CGEventFlags()
    eventFlags.insert(.maskAlternate)
    eventFlags.insert(.maskCommand)
    eventFlags.insert(.maskControl)
    eventFlags.insert(.maskShift)

    #expect(ModifierFlags.from(eventFlags) == [.alt, .cmd, .ctrl, .shift])
  }

  @Test("from with left modifiers")
  func fromWithLeftModifiers() async throws {
    var eventFlags = CGEventFlags(
      rawValue: UInt64(NX_DEVICELALTKEYMASK)
    )
    eventFlags.insert(.maskAlternate)

    #expect(ModifierFlags.from(eventFlags) == .lalt)
  }

  @Test("from with right modifiers")
  func fromWithRightModifiers() async throws {
    var eventFlags = CGEventFlags(
      rawValue: UInt64(NX_DEVICERALTKEYMASK)
    )
    eventFlags.insert(.maskAlternate)

    #expect(ModifierFlags.from(eventFlags) == .ralt)
  }

  @Test("from with left and right modifiers")
  func fromWithLeftAndRightModifiers() async throws {
    var eventFlags = CGEventFlags(
      rawValue: UInt64(NX_DEVICELALTKEYMASK | NX_DEVICERALTKEYMASK | NX_DEVICELCMDKEYMASK)
    )
    eventFlags.insert(.maskAlternate)
    eventFlags.insert(.maskCommand)

    #expect(ModifierFlags.from(eventFlags) == [.lalt, .ralt, .lcmd])
  }

  @Test("compare with left and right modifiers")
  func equalsWithLRModifiers() async throws {
    let mods: [(ModifierFlags, ModifierFlags)] = [
      (.lalt, .lalt),
      (.ralt, .ralt),
      (.lcmd, .lcmd),
      (.rcmd, .rcmd),
      (.lctrl, .lctrl),
      (.rctrl, .rctrl),
      (.lshift, .lshift),
      (.rshift, .rshift),
      (.fn, .fn),
    ]

    for (lhs, rhs) in mods {
      #expect(ModifierFlags.compare(lhs, rhs))
    }
  }

  @Test("compare with non-left and right modifiers")
  func equalsWithNonLRModifiers() async throws {
    let mods: [(ModifierFlags, ModifierFlags)] = [
      (.alt, .lalt),
      (.alt, .ralt),
      (.alt, .alt),
      (.cmd, .lcmd),
      (.cmd, .rcmd),
      (.cmd, .cmd),
      (.ctrl, .lctrl),
      (.ctrl, .rctrl),
      (.ctrl, .ctrl),
      (.shift, .lshift),
      (.shift, .rshift),
      (.shift, .shift),
      (.fn, .fn),
    ]

    for (lhs, rhs) in mods {
      #expect(ModifierFlags.compare(lhs, rhs))
    }
  }

  @Test("compare with generic modifier matches left and right modifier")
  func equalsWithGenericModifierMatchesLeftAndRightModifier() async throws {
    let mods: [(ModifierFlags, ModifierFlags)] = [
      (.alt, [.lalt, .ralt]),
      (.cmd, [.lcmd, .rcmd]),
      (.ctrl, [.lctrl, .rctrl]),
      (.shift, [.lshift, .rshift]),
    ]

    for (lhs, rhs) in mods {
      #expect(ModifierFlags.compare(lhs, rhs))
    }
  }

  @Test("compare with multiple modifiers")
  func equalsWithMultipleModifiers() async throws {
    let mods: [(ModifierFlags, ModifierFlags)] = [
      ([.lalt, .rcmd, .lctrl, .rshift], [.lalt, .rcmd, .lctrl, .rshift]),
      ([.alt, .cmd, .ctrl, .shift], [.lalt, .rcmd, .lctrl, .rshift]),
      ([.alt, .cmd, .ctrl, .shift], [.ralt, .lcmd, .rctrl, .lshift]),
    ]

    for (lhs, rhs) in mods {
      #expect(ModifierFlags.compare(lhs, rhs))
    }
  }

  @Test("description with no modifiers")
  func descriptionWithNoModifiers() async throws {
    #expect(ModifierFlags().description == "<ModifierFlags none>")
  }

  @Test("description with single modifiers")
  func descriptionWithSingleModifiers() async throws {
    let mods: [(ModifierFlags, String)] = [
      (.lalt, "<ModifierFlags lalt>"),
      (.ralt, "<ModifierFlags ralt>"),
      (.lcmd, "<ModifierFlags lcmd>"),
      (.rcmd, "<ModifierFlags rcmd>"),
      (.lctrl, "<ModifierFlags lctrl>"),
      (.rctrl, "<ModifierFlags rctrl>"),
      (.lshift, "<ModifierFlags lshift>"),
      (.rshift, "<ModifierFlags rshift>"),
      (.fn, "<ModifierFlags fn>"),
    ]

    for (modifiers, description) in mods {
      #expect(modifiers.description == description)
    }
  }

  @Test("description with multiple modifiers")
  func descriptionWithMultipleModifiers() async throws {
    let mods: [(ModifierFlags, String)] = [
      ([.lalt, .ralt], "<ModifierFlags lalt|ralt>"),
      ([.shift, .ralt], "<ModifierFlags ralt|shift>"),
      ([.alt, .ctrl, .shift], "<ModifierFlags alt|ctrl|shift>"),
      ([.alt, .cmd, .ctrl, .shift], "<ModifierFlags alt|cmd|ctrl|shift>"),
      ([.rshift, .alt, .lctrl], "<ModifierFlags alt|lctrl|rshift>"),
    ]

    for (modifiers, description) in mods {
      #expect(modifiers.description == description)
    }
  }

  @Test("get with alternative names")
  func getWithAlternativeNames() async throws {
    #expect(ModifierFlags.get("opt") == .alt)
    #expect(ModifierFlags.get("lopt") == .lalt)
    #expect(ModifierFlags.get("ropt") == .ralt)
  }
}
