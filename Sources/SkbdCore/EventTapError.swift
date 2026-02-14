import Foundation

public enum EventTapError: Error, LocalizedError {
  case creationFailed
}

extension EventTapError: CustomStringConvertible {
  public var description: String {
    switch self {
    case .creationFailed:
      return "failed to create event tap"
    }
  }
}
