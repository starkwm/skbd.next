class Lexer {
  private var buffer: String
  private var position: String.Index
  private var current: Character

  private var atEnd: Bool { position >= buffer.endIndex }

  init(with buffer: String) {
    self.buffer = buffer
    position = self.buffer.startIndex
    current = self.buffer.isEmpty ? "\0" : self.buffer[position]
  }

  func getToken() -> Token {
    skipWhitespace()

    var token = Token(type: .unknown)

    switch current {
    case "\0":
      token.type = .endOfStream
    case "#":
      skipComment()
      return getToken()
    case ":":
      advance()
      skipWhitespace()
      token.type = .command
      token.text = readCommand()
    case "+":
      token.type = .plus
      advance()
    case "-":
      token.type = .dash
      advance()
    case "[":
      token.type = .beginList
      advance()
    case "]":
      token.type = .endList
      advance()
    case "\"":
      token.type = .string
      token.text = readString()
    case ".":
      token.text = readDirective()
      token.type = .directive
    case _ where current.isNumber:
      if current == "0" && peek() == "x" {
        advance(by: 2)
        token.type = .keyHex
        token.text = readKeyHex()
      } else {
        token.type = .key
        token.text = String(current)
        advance()
      }
    case _ where current.isLetter:
      token.text = readIdentifier()
      token.type = resolveTokenType(for: token.text!)
    default:
      token.text = String(current)
      advance()
    }

    return token
  }

  private func advance(by n: Int = 1) {
    let remaining = buffer.distance(from: position, to: buffer.endIndex)
    let offset = Swift.min(n, remaining)

    position = buffer.index(position, offsetBy: offset)
    current = position < buffer.endIndex ? buffer[position] : "\0"
  }

  private func peek() -> Character? {
    let nextIndex = buffer.index(after: position)
    return nextIndex < buffer.endIndex ? buffer[nextIndex] : "\0"
  }

  private func skipWhitespace() {
    while !atEnd && current.isWhitespace {
      advance()
    }
  }

  private func skipComment() {
    while !atEnd && !current.isNewline {
      advance()
    }
  }

  private func readCommand() -> String {
    let start = position

    while !atEnd && !current.isNewline {
      if current == "\\" {
        advance()
      }

      advance()
    }

    return String(buffer[start..<position])
  }

  private func readIdentifier() -> String? {
    let start = position
    advance()

    while !atEnd && (current.isLetter || current.isNumber) {
      advance()
    }

    return String(buffer[start..<position])
  }

  private func readKeyHex() -> String {
    let start = position

    while !atEnd && current.isHexDigit {
      advance()
    }

    return String(buffer[start..<position])
  }

  private func readString() -> String {
    advance()
    let start = position

    while !atEnd && current != "\"" {
      advance()
    }

    let result = String(buffer[start..<position])
    if !atEnd {
      advance()
    }

    return result
  }

  private func readDirective() -> String {
    let start = position

    while !atEnd && (current == "." || current.isLetter || current.isNumber) {
      advance()
    }

    return String(buffer[start..<position])
  }

  private func resolveTokenType(for identifier: String) -> TokenType {
    if identifier.count == 1 {
      return .key
    }

    if ModifierFlags.literals.contains(identifier) {
      return .modifier
    }

    if KeyCodes.specialKeys.keys.contains(identifier) {
      return .literal
    }

    return .unknown
  }
}

extension Lexer: Sequence {
  func makeIterator() -> LexerIterator {
    LexerIterator(with: self)
  }
}

struct LexerIterator: IteratorProtocol {
  private var lexer: Lexer

  init(with lexer: Lexer) {
    self.lexer = lexer
  }

  mutating func next() -> Token? {
    let token = lexer.getToken()
    return token.type == .endOfStream ? nil : token
  }
}
