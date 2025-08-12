public enum ParserError: Error {
  case expectedDashAfterModifier
  case expectedCommandAfterKey
  case expectedModifierOrKey
  case invalidModifierLiteral
  case invalidKey
  case invalidKeyHex
  case invalidKeyLiteral
  case invalidCommand
  case expectedLeftBracketAfterDirective
  case expectedRightBracket
  case expectedStringLiteral
  case invalidDirective
  case unexpectedTokenInBlocklist
}

extension ParserError: CustomStringConvertible {
  public var description: String {
    switch self {
    case .expectedDashAfterModifier:
      return "expected '-' after modifier"
    case .expectedCommandAfterKey:
      return "expected command after key"
    case .expectedModifierOrKey:
      return "expected modifier or key"
    case .invalidModifierLiteral:
      return "invalid modifier literal"
    case .invalidKey:
      return "invalid key"
    case .invalidKeyHex:
      return "invalid key hex value"
    case .invalidKeyLiteral:
      return "invalid key literal"
    case .invalidCommand:
      return "invalid command"
    case .expectedLeftBracketAfterDirective:
      return "expected '[' after directive"
    case .expectedRightBracket:
      return "expected ']'"
    case .expectedStringLiteral:
      return "expected string literal"
    case .invalidDirective:
      return "invalid directive"
    case .unexpectedTokenInBlocklist:
      return "unexpected token in blocklist"
    }
  }
}
