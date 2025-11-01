public struct Configuration {
  public var hotKeys: [HotKey]
  public var blockList: [String]

  public init(hotKeys: [HotKey] = [], blockList: [String] = []) {
    self.hotKeys = hotKeys
    self.blockList = blockList
  }
}
