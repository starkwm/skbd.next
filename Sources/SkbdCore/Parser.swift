public class Parser {
  private let lexer: Lexer

  private var currentToken: Token!
  private var previousToken: Token?

  private var atEnd: Bool { currentToken.type == .endOfStream }

  init(with lexer: Lexer) {
    self.lexer = lexer
    advance()
  }

  public convenience init(with buffer: String) {
    self.init(with: Lexer(with: buffer))
  }

  public func parse() -> Result<Configuration, ParserError> {
    do {
      var configuration = Configuration()

      while !atEnd {
        if check(.directive) {
          let blockList = try parseBlocklist()
          configuration.blockList = blockList
        } else if check(.modifier, .key, .keyHex, .literal) {
          let hotKey = try parseHotKey()
          configuration.hotKeys.append(hotKey)
        } else {
          throw ParserError.expectedModifierOrKey
        }
      }

      return .success(configuration)
    } catch {
      return .failure(error as! ParserError)
    }
  }

  private func parseHotKey() throws -> HotKey {
    var hotKey = HotKey()

    if match(.modifier) {
      hotKey.modifierFlags = try parseModifier()
    }

    guard hotKey.modifierFlags.isEmpty || match(.dash) else {
      throw ParserError.expectedDashAfterModifier
    }

    if match(.key) {
      hotKey.key = try parseKey()
    } else if match(.keyHex) {
      hotKey.key = try parseKeyHex()
    } else if match(.literal) {
      let (key, modifierFlags) = try parseKeyLiteral()
      hotKey.key = key
      hotKey.modifierFlags.insert(modifierFlags)
    } else {
      throw ParserError.invalidKeyLiteral
    }

    if match(.command) {
      hotKey.command = try parseCommand()
    } else if match(.arrow) {
      hotKey.command = try parseCommand()
      hotKey.passthrough = true
    } else {
      throw ParserError.expectedCommandAfterKey
    }

    return hotKey
  }

  private func parseBlocklist() throws -> [String] {
    advance()
    let directive = previousToken!.text!
    guard directive == ".blocklist" else { throw ParserError.invalidDirective }

    guard match(.beginList) else { throw ParserError.expectedLeftBracketAfterDirective }

    var blockList: [String] = []

    while !check(.endList) && !atEnd {
      guard match(.string) else { throw ParserError.expectedStringLiteral }
      let processName = previousToken!.text!
      blockList.append(processName)
    }

    guard match(.endList) else { throw ParserError.expectedRightBracket }

    return blockList
  }

  private func parseModifier() throws -> ModifierFlags {
    let modifier = previousToken!.text!
    guard let value = ModifierFlags.get(modifier) else { throw ParserError.invalidModifierLiteral }

    var flags = ModifierFlags()
    flags.insert(value)

    if match(.plus) {
      advance()
      flags.insert(try parseModifier())
    }

    return flags
  }

  private func parseKey() throws -> UInt32 {
    let key = previousToken!.text!

    guard let keyCode = KeyCodes.keyCode(for: key) else {
      throw ParserError.invalidKey
    }

    return UInt32(keyCode)
  }

  private func parseKeyHex() throws -> UInt32 {
    let key = previousToken!.text!
    guard let keyCode = UInt32(key, radix: 16) else { throw ParserError.invalidKeyHex }
    return keyCode
  }

  private func parseKeyLiteral() throws -> (UInt32, ModifierFlags) {
    let key = previousToken!.text!

    guard let (code, requiresFn) = KeyCodes.specialKeys[key] else {
      throw ParserError.invalidKeyLiteral
    }

    var flags = ModifierFlags()
    if requiresFn {
      flags.insert(.fn)
    }

    return (UInt32(code), flags)
  }

  private func parseCommand() throws -> String {
    let command = previousToken!.text!
    guard !command.isEmpty else { throw ParserError.invalidCommand }
    return command
  }

  private func advance() {
    previousToken = currentToken
    currentToken = lexer.getToken()
  }

  private func check(_ types: TokenType...) -> Bool {
    guard !atEnd else { return false }
    return types.contains(currentToken.type)
  }

  private func match(_ type: TokenType) -> Bool {
    guard check(type) else { return false }
    advance()
    return true
  }
}
