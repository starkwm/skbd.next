@testable import SkbdCore

class FakeLexer: Lexer {
  private var tokens: [Token]

  init(tokens: [Token]) {
    self.tokens = tokens

    super.init(with: "")
  }

  override func getToken() -> Token {
    return tokens.isEmpty ? Token(type: .endOfStream) : tokens.removeFirst()
  }
}
