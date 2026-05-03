import Foundation

enum ConfigurationLoader {
  static func load(from url: URL) throws -> String {
    let values = try url.resourceValues(forKeys: [.isDirectoryKey])

    if values.isDirectory == true {
      return try loadDirectory(at: url)
    }

    return try String(contentsOf: url, encoding: .utf8)
  }

  private static func loadDirectory(at url: URL) throws -> String {
    let fileManager = FileManager.default
    let entries = try fileManager.contentsOfDirectory(
      at: url,
      includingPropertiesForKeys: [.isRegularFileKey],
      options: [.skipsHiddenFiles]
    )

    let files =
      try entries
      .filter { entry in
        let values = try entry.resourceValues(forKeys: [.isRegularFileKey])
        return values.isRegularFile == true
      }
      .sorted { $0.lastPathComponent < $1.lastPathComponent }

    return
      try files
      .map { try String(contentsOf: $0, encoding: .utf8) }
      .joined(separator: "\n")
  }
}
