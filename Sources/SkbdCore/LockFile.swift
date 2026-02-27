import Darwin
import Foundation

public class FileLock {
  private var fd: Int32 = -1

  public init() {}

  deinit {
    release()
  }

  public func acquire() -> Result<Void, FileLockError> {
    fd = open(path(), O_CREAT | O_WRONLY | O_TRUNC, 0o600)

    guard fd != -1 else { return .failure(.failed(reason: "failed to open lock file")) }

    let flockResult = flock(fd, LOCK_EX | LOCK_NB)

    if flockResult == 0 {
      return .success(())
    } else if errno == EWOULDBLOCK {
      return .failure(.alreadyLocked)
    } else {
      return .failure(.failed(reason: "failed to acquire lock"))
    }
  }

  func release() {
    guard fd != -1 else { return }

    flock(fd, LOCK_UN)
    close(fd)
    unlink(path())

    fd = -1
  }

  private func path() -> String {
    FileManager
      .default
      .temporaryDirectory
      .appendingPathComponent("skbd_next_\(NSUserName()).lock", isDirectory: false)
      .path
  }
}
