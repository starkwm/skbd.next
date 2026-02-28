import Carbon
import Foundation

enum HotKeyResult {
  case passthrough
  case consumed
}

public struct HotKey {
  static func from(event: CGEvent) -> HotKey {
    return HotKey(
      modifierFlags: ModifierFlags.from(event.flags),
      key: UInt32(event.getIntegerValueField(.keyboardEventKeycode))
    )
  }

  var modifierFlags: ModifierFlags = []
  var key: UInt32 = 0

  var command: String?

  init() {}

  init(modifierFlags: ModifierFlags, key: UInt32, command: String? = nil) {
    self.modifierFlags = modifierFlags
    self.key = key
    self.command = command
  }

  @discardableResult
  func execute(onExecute: (() -> Void)? = nil) -> HotKeyResult {
    guard let command = command else { return .passthrough }

    let shell =
      ProcessInfo.processInfo.environment["SHELL"].flatMap { $0.isEmpty ? nil : $0 } ?? "/bin/bash"

    let process = Process()
    process.executableURL = URL(fileURLWithPath: shell)
    process.arguments = ["-c", command]
    process.standardOutput = FileHandle.nullDevice
    process.standardError = FileHandle.nullDevice
    try? process.run()

    onExecute?()

    return .consumed
  }
}

extension HotKey: Equatable {
  public static func == (lhs: HotKey, rhs: HotKey) -> Bool {
    return ModifierFlags.compare(lhs.modifierFlags, rhs.modifierFlags) && lhs.key == rhs.key
  }
}

extension HotKey: CustomStringConvertible {
  public var description: String {
    "<HotKey flags: \(modifierFlags), key: \(KeyCodes.key(for: Int(key)))>"
  }
}
