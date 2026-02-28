public enum FileLockError: Error {
  case alreadyLocked
  case failed(reason: String)
}

extension FileLockError: CustomStringConvertible {
  public var description: String {
    switch self {
    case .alreadyLocked:
      return "lock file is already in use"
    case .failed(let reason):
      return reason
    }
  }
}
