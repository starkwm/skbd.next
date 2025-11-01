import AppKit
import CoreGraphics

public class EventTapManager {
  private var eventTap: CFMachPort?
  private var runloopSource: CFRunLoopSource?

  private var hotKeys: [HotKey]
  private var blockList: [String]

  public init(hotKeys: [HotKey], blockList: [String] = []) {
    self.hotKeys = hotKeys
    self.blockList = blockList
  }

  deinit {
    if let eventTap = eventTap {
      CGEvent.tapEnable(tap: eventTap, enable: false)
      CFMachPortInvalidate(eventTap)
    }

    if let runloopSource = runloopSource {
      CFRunLoopRemoveSource(CFRunLoopGetMain(), runloopSource, .commonModes)
    }

    eventTap = nil
    runloopSource = nil
  }

  public func begin() -> Result<Void, EventTapError> {
    guard eventTap == nil, runloopSource == nil else { return .success(()) }

    let callback: CGEventTapCallBack = { _, type, event, refcon in
      guard let refcon = refcon else { return Unmanaged.passUnretained(event) }

      let manager = Unmanaged<EventTapManager>.fromOpaque(refcon).takeUnretainedValue()
      let result = manager.process(event: event, type: type)

      guard let result = result else { return nil }

      return Unmanaged.passUnretained(result)
    }

    eventTap = CGEvent.tapCreate(
      tap: .cghidEventTap,
      place: .headInsertEventTap,
      options: .listenOnly,
      eventsOfInterest: (1 << CGEventType.keyDown.rawValue),
      callback: callback,
      userInfo: Unmanaged.passUnretained(self).toOpaque()
    )

    guard let eventTap = eventTap else { return .failure(.creationFailed) }

    runloopSource = CFMachPortCreateRunLoopSource(kCFAllocatorDefault, eventTap, 0)

    CFRunLoopAddSource(CFRunLoopGetCurrent(), runloopSource, .commonModes)
    CGEvent.tapEnable(tap: eventTap, enable: true)

    return .success(())
  }

  func process(event: CGEvent, type: CGEventType) -> CGEvent? {
    switch type {
    case .tapDisabledByTimeout, .tapDisabledByUserInput:
      guard let eventTap = eventTap else { return event }
      CGEvent.tapEnable(tap: eventTap, enable: true)
    case .keyDown:
      let processName = NSWorkspace.shared.frontmostApplication?.localizedName
      guard let processName = processName, !blockList.contains(processName) else { return event }

      let eventHotKey = HotKey.from(event: event)
      let hotkey = hotKeys.first { $0 == eventHotKey }
      let result = try? hotkey?.execute()

      if case .consumed = result { return nil }
      return event
    default:
      break
    }

    return event
  }
}
