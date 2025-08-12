import Carbon

struct ModifierFlags: OptionSet, Hashable {
  static let alt = ModifierFlags(rawValue: 1 << 0)
  static let lalt = ModifierFlags(rawValue: 1 << 1)
  static let ralt = ModifierFlags(rawValue: 1 << 2)
  static let shift = ModifierFlags(rawValue: 1 << 3)
  static let lshift = ModifierFlags(rawValue: 1 << 4)
  static let rshift = ModifierFlags(rawValue: 1 << 5)
  static let cmd = ModifierFlags(rawValue: 1 << 6)
  static let lcmd = ModifierFlags(rawValue: 1 << 7)
  static let rcmd = ModifierFlags(rawValue: 1 << 8)
  static let ctrl = ModifierFlags(rawValue: 1 << 9)
  static let lctrl = ModifierFlags(rawValue: 1 << 10)
  static let rctrl = ModifierFlags(rawValue: 1 << 11)
  static let fn = ModifierFlags(rawValue: 1 << 12)

  static let literals = allCases.map(\.0)

  private static let allCases: [(String, ModifierFlags)] = [
    ("alt", .alt), ("lalt", .lalt), ("ralt", .ralt),
    ("opt", .alt), ("lopt", .lalt), ("ropt", .ralt),
    ("cmd", .cmd), ("lcmd", .lcmd), ("rcmd", .rcmd),
    ("ctrl", .ctrl), ("lctrl", .lctrl), ("rctrl", .rctrl),
    ("shift", .shift), ("lshift", .lshift), ("rshift", .rshift),
    ("fn", .fn),
    ("meh", [.alt, .ctrl, .shift]),
    ("hyper", [.alt, .cmd, .ctrl, .shift]),
  ]

  private static let values: [String: ModifierFlags] = Dictionary(uniqueKeysWithValues: allCases)

  static func get(_ literal: String) -> ModifierFlags? {
    values[literal]
  }

  static func from(_ eventFlags: CGEventFlags) -> ModifierFlags {
    var result = ModifierFlagsGroup.groups.reduce(into: ModifierFlags()) { flags, group in
      flags.insert(group.from(eventFlags))
    }

    if eventFlags.contains(.maskSecondaryFn) {
      result.insert(.fn)
    }

    return result
  }

  static func compare(_ lhs: ModifierFlags, _ rhs: ModifierFlags) -> Bool {
    func contains(_ flags: ModifierFlags, _ flag: ModifierFlags) -> Bool {
      (flags.rawValue & flag.rawValue) != 0
    }

    func matches(_ generic: ModifierFlags, _ left: ModifierFlags, _ right: ModifierFlags) -> Bool {
      contains(lhs, generic)
        ? contains(rhs, left)
          || contains(rhs, right)
          || contains(rhs, generic)
        : contains(lhs, left) == contains(rhs, left)
          && contains(lhs, right) == contains(rhs, right)
          && contains(lhs, generic) == contains(rhs, generic)
    }

    return ModifierFlagsGroup.groups.allSatisfy { group in
      matches(group.generic, group.left, group.right)
    } && contains(lhs, .fn) == contains(rhs, .fn)
  }

  let rawValue: UInt32
}

extension ModifierFlags: CustomStringConvertible {
  var description: String {
    guard !isEmpty else { return "<ModifierFlags none>" }

    let excludedLiterals: Set<String> = ["meh", "hyper", "opt", "lopt", "ropt"]

    let flags = Self.allCases.compactMap { (name, flag) in
      contains(flag) && !excludedLiterals.contains(name) ? name : nil
    }

    return "<ModifierFlags \(flags.joined(separator: "|"))>"
  }
}
