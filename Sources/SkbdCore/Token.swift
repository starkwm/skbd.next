enum TokenType {
  case modifier
  case key
  case keyHex
  case literal
  case command
  case arrow
  case plus
  case dash
  case directive
  case beginList
  case endList
  case string
  case unknown
  case endOfStream
}

struct Token {
  var type: TokenType
  var text: String?
}
