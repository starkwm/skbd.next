import Darwin
import Foundation
import SkbdCore

let arguments = Arguments.parseOrExit()

if arguments.version {
  print("skbd \(Version.current.value)")
  exit(EXIT_SUCCESS)
}

let lock = FileLock()

switch lock.acquire() {
case .success:
  break
case .failure(.alreadyLocked):
  fputs("skbd is already running\n", stderr)
  fflush(stderr)
  exit(EXIT_FAILURE)
case .failure(.failed(let reason)):
  fputs("failed to acquire lock: \(reason)\n", stderr)
  fflush(stderr)
  exit(EXIT_FAILURE)
}

let parser: Parser

do {
  let input = try ConfigurationLoader.load(from: arguments.config)
  parser = Parser(with: input)
} catch {
  fputs("failed to load configuration: \(error.localizedDescription)\n", stderr)
  fflush(stderr)
  exit(EXIT_FAILURE)
}

let eventTap: EventTapManager

switch parser.parse() {
case .success(let configuration):
  eventTap = EventTapManager(hotKeys: configuration.hotKeys, blockList: configuration.blockList)
case .failure(let error):
  fputs("error parsing the configuration file: \(error)\n", stderr)
  fflush(stderr)
  exit(EXIT_FAILURE)
}

switch eventTap.begin() {
case .success: break
case .failure(let error):
  fputs("error starting the event tap: \(error)\n", stderr)
  fflush(stderr)
  exit(EXIT_FAILURE)
}

signal(SIGINT) { _ in
  CFRunLoopStop(CFRunLoopGetMain())
}

CFRunLoopRun()
