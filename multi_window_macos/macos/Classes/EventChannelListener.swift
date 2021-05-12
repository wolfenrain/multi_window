import FlutterMacOS

class EventChannelListener: NSObject, FlutterStreamHandler {
  let key: String

  init(key: String) {
    self.key = key
    super.init()
  }

  func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
    print("EventChannelListener.onListen => eventChannel for \(key) attached")
    MultiWindowMacosPlugin.multiEventSinks[key]?.append(events)
    return nil
  }

  func onCancel(withArguments arguments: Any?) -> FlutterError? {
    print("EventChannelListener.onCancel => eventChannel for \(key) detached")
    // TODO clear from multiEventSinks
    return nil
  }
}
