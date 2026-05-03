import Foundation
import Testing

@testable import Skbd

@Suite("ConfigurationLoader")
struct ConfigurationLoaderTests {
  @Test("load reads a single file")
  func loadFile() throws {
    let directory = try temporaryDirectory()
    defer { try? FileManager.default.removeItem(at: directory) }

    let file = directory.appendingPathComponent("skbdrc")
    try "cmd - a: echo file".write(to: file, atomically: true, encoding: .utf8)

    let result = try ConfigurationLoader.load(from: file)

    #expect(result == "cmd - a: echo file")
  }

  @Test("load reads a directory in lexicographical order")
  func loadDirectory() throws {
    let directory = try temporaryDirectory()
    defer { try? FileManager.default.removeItem(at: directory) }

    let zFile = directory.appendingPathComponent("20-second")
    let aFile = directory.appendingPathComponent("10-first")
    let hidden = directory.appendingPathComponent(".ignored")

    try "cmd - b: echo second".write(to: zFile, atomically: true, encoding: .utf8)
    try "cmd - a: echo first".write(to: aFile, atomically: true, encoding: .utf8)
    try "should not load".write(to: hidden, atomically: true, encoding: .utf8)

    let result = try ConfigurationLoader.load(from: directory)

    #expect(
      result
        == """
        cmd - a: echo first
        cmd - b: echo second
        """
    )
  }

  private func temporaryDirectory() throws -> URL {
    let url = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
    try FileManager.default.createDirectory(at: url, withIntermediateDirectories: true)
    return url
  }
}
