import Carbon

struct KeyCodes {
  static let specialKeys: [String: (Int, Bool)] = [
    "return": (kVK_Return, false),
    "tab": (kVK_Tab, false),
    "space": (kVK_Space, false),
    "backspace": (kVK_Delete, false),
    "escape": (kVK_Escape, false),
    "backtick": (kVK_ANSI_Grave, false),
    "delete": (kVK_ForwardDelete, true),
    "home": (kVK_Home, true),
    "end": (kVK_End, true),
    "pageup": (kVK_PageUp, true),
    "pagedown": (kVK_PageDown, true),
    "insert": (kVK_Help, true),
    "left": (kVK_LeftArrow, true),
    "right": (kVK_RightArrow, true),
    "up": (kVK_UpArrow, true),
    "down": (kVK_DownArrow, true),
    "f1": (kVK_F1, true),
    "f2": (kVK_F2, true),
    "f3": (kVK_F3, true),
    "f4": (kVK_F4, true),
    "f5": (kVK_F5, true),
    "f6": (kVK_F6, true),
    "f7": (kVK_F7, true),
    "f8": (kVK_F8, true),
    "f9": (kVK_F9, true),
    "f10": (kVK_F10, true),
    "f11": (kVK_F11, true),
    "f12": (kVK_F12, true),
    "f13": (kVK_F13, true),
    "f14": (kVK_F14, true),
    "f15": (kVK_F15, true),
    "f16": (kVK_F16, true),
    "f17": (kVK_F17, true),
    "f18": (kVK_F18, true),
    "f19": (kVK_F19, true),
    "f20": (kVK_F20, true),
  ]

  // swift-format-ignore
  static let layoutDependentValues = [
    kVK_ANSI_A,            kVK_ANSI_B,           kVK_ANSI_C,
    kVK_ANSI_D,            kVK_ANSI_E,           kVK_ANSI_F,
    kVK_ANSI_G,            kVK_ANSI_H,           kVK_ANSI_I,
    kVK_ANSI_J,            kVK_ANSI_K,           kVK_ANSI_L,
    kVK_ANSI_M,            kVK_ANSI_N,           kVK_ANSI_O,
    kVK_ANSI_P,            kVK_ANSI_Q,           kVK_ANSI_R,
    kVK_ANSI_S,            kVK_ANSI_T,           kVK_ANSI_U,
    kVK_ANSI_V,            kVK_ANSI_W,           kVK_ANSI_X,
    kVK_ANSI_Y,            kVK_ANSI_Z,           kVK_ANSI_0,
    kVK_ANSI_1,            kVK_ANSI_2,           kVK_ANSI_3,
    kVK_ANSI_4,            kVK_ANSI_5,           kVK_ANSI_6,
    kVK_ANSI_7,            kVK_ANSI_8,           kVK_ANSI_9,
    kVK_ANSI_Grave,        kVK_ANSI_Equal,       kVK_ANSI_Minus,
    kVK_ANSI_RightBracket, kVK_ANSI_LeftBracket, kVK_ANSI_Quote,
    kVK_ANSI_Semicolon,    kVK_ANSI_Backslash,   kVK_ANSI_Comma,
    kVK_ANSI_Slash,        kVK_ANSI_Period,      kVK_ISO_Section,
  ]

  private static let keymap: [String: Int] = {
    var keys = [String: Int]()

    let data = getKeyboardLayoutData()

    for keyCode in layoutDependentValues {
      var deadKeyState = UInt32(0)
      let maxLength = 255
      var length = 0
      var chars = [UniChar](repeating: 0, count: maxLength)

      UCKeyTranslate(
        data,
        UInt16(keyCode),
        UInt16(kUCKeyActionDisplay),
        0,
        UInt32(LMGetKbdType()),
        OptionBits(kUCKeyTranslateNoDeadKeysBit),
        &deadKeyState,
        maxLength,
        &length,
        &chars
      )

      if length > 0 {
        let key = String(utf16CodeUnits: &chars, count: length)
        keys[key.lowercased()] = keyCode
      }
    }

    return keys
  }()

  private static let reverseKeys: [Int: String] = {
    var dict = [Int: String]()
    for (name, (code, _)) in specialKeys {
      dict[code] = name
    }
    for (name, code) in keymap {
      dict[code] = name
    }
    return dict
  }()

  static func keyCode(for key: String) -> Int? {
    specialKeys[key]?.0 ?? keymap[key]
  }

  static func key(for code: Int) -> String {
    reverseKeys[code] ?? "unknown"
  }

  private static func getKeyboardLayoutData() -> UnsafePointer<UCKeyboardLayout>? {
    let source = TISCopyCurrentASCIICapableKeyboardLayoutInputSource().takeUnretainedValue()
    let dataRefPtr = TISGetInputSourceProperty(source, kTISPropertyUnicodeKeyLayoutData)
    let dataRef = unsafeBitCast(dataRefPtr, to: CFData?.self)

    return unsafeBitCast(CFDataGetBytePtr(dataRef), to: UnsafePointer<UCKeyboardLayout>.self)
  }
}
