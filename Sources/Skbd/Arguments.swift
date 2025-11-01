import ArgumentParser
import Foundation

struct Arguments: ParsableArguments {
  @Option(
    name: .shortAndLong,
    help: ArgumentHelp("Path to a configuration file", valueName: "path"),
    transform: URL.init(fileURLWithPath:)
  )
  var config: URL = FileManager.default.homeDirectoryForCurrentUser.appending(
    path: ".config/skbd/skbdrc"
  )

  @Flag(name: .shortAndLong, help: "Show version information")
  var version = false
}
