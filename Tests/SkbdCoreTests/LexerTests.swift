import Testing

@testable import SkbdCore

@Suite("Lexer")
struct LexerTests {
  @Test("getToken with empty buffer")
  func getTokenWithEmptyBuffer() async throws {
    let input = ""

    let lexer = Lexer(with: input)
    let tokens = Array(lexer)

    #expect(tokens.isEmpty)
  }

  @Test("getToken")
  func getToken() async throws {
    let input = """
        # simple modifier and key literal with command
        alt-space: open -a iTerm2.app

        # multiline comment
        # simple multiple modifer and key with command
        cmd + shift - a : echo "Hello world"

        # multiline command
        ctrl + lalt - return : echo "foo bar"; \\
            rm -fr /

        # meh modifier
        meh - a: echo "meh"

        # hyper modifier
        hyper - b: echo "hyper"

        # this is a key mapping with a number
        rcmd + ralt - 5: cat ~/.config/skbd/skbdrc | pbcopy

        # hex keycode
        rshift + ralt - 0x32: echo "Hello hex!"

        # no modifier
        a: echo "hello a"

        # blocklist with multiple apps
        .blocklist [
          "Safari"
          "Terminal"
          "Finder"
        ]
      """

    let expected: [(TokenType, String?)] = [
      (.modifier, "alt"), (.dash, nil), (.literal, "space"), (.command, "open -a iTerm2.app"),
      (.modifier, "cmd"), (.plus, nil), (.modifier, "shift"), (.dash, nil), (.key, "a"),
      (.command, "echo \"Hello world\""),
      (.modifier, "ctrl"), (.plus, nil), (.modifier, "lalt"), (.dash, nil), (.literal, "return"),
      (
        .command,
        """
        echo "foo bar"; \\
              rm -fr /
        """
      ),
      (.modifier, "meh"), (.dash, nil), (.key, "a"),
      (.command, "echo \"meh\""),
      (.modifier, "hyper"), (.dash, nil), (.key, "b"),
      (.command, "echo \"hyper\""),
      (.modifier, "rcmd"), (.plus, nil), (.modifier, "ralt"), (.dash, nil), (.key, "5"),
      (.command, "cat ~/.config/skbd/skbdrc | pbcopy"),
      (.modifier, "rshift"), (.plus, nil), (.modifier, "ralt"), (.dash, nil), (.keyHex, "32"),
      (.command, "echo \"Hello hex!\""),
      (.key, "a"), (.command, "echo \"hello a\""),
      (.directive, ".blocklist"), (.beginList, nil), (.string, "Safari"), (.string, "Terminal"),
      (.string, "Finder"), (.endList, nil),
    ]

    let lexer = Lexer(with: input)

    for (idx, token) in lexer.enumerated() {
      #expect(expected[idx].0 == token.type)
      #expect(expected[idx].1 == token.text)
    }
  }

  @Test("getToken with digit EOL")
  func getTokenWithDigitEOL() async throws {
    let input = "cmd - 0"

    let expected: [(TokenType, String?)] = [
      (.modifier, "cmd"), (.dash, nil), (.key, "0"),
    ]

    let lexer = Lexer(with: input)

    for (idx, token) in lexer.enumerated() {
      #expect(expected[idx].0 == token.type)
      #expect(expected[idx].1 == token.text)
    }
  }

  @Test("getToken with unknown key")
  func getTokenWithUnknownKey() async throws {
    let input = """
        cmd + rctrl - §: echo "unknown"
      """

    let expected: [(TokenType, String?)] = [
      (.modifier, "cmd"), (.plus, nil), (.modifier, "rctrl"), (.dash, nil), (.unknown, "§"),
      (.command, "echo \"unknown\""),
    ]

    let lexer = Lexer(with: input)

    for (idx, token) in lexer.enumerated() {
      #expect(expected[idx].0 == token.type)
      #expect(expected[idx].1 == token.text)
    }
  }

  @Test("getToken with unknown literal")
  func getTokenWithUnknownLiteral() async throws {
    let input = """
        cmd + rctrl - f100: echo "unknown"
      """

    let expected: [(TokenType, String?)] = [
      (.modifier, "cmd"), (.plus, nil), (.modifier, "rctrl"), (.dash, nil), (.unknown, "f100"),
      (.command, "echo \"unknown\""),
    ]

    let lexer = Lexer(with: input)

    for (idx, token) in lexer.enumerated() {
      #expect(expected[idx].0 == token.type)
      #expect(expected[idx].1 == token.text)
    }
  }
}
