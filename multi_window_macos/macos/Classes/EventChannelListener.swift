import FlutterMacOS

class EventChannelListener: NSObject, FlutterStreamHandler {

    func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
        guard let key = arguments as? String else {
            return FlutterError(code: "MISSING_PARAMS", message: "Missing 'key' parameter", details: nil)
        }
        print("EventChannelListener.onListen => eventChannel for \(key) attached")

        MultiWindowMacosPlugin.multiEventSinks[key] = events
        return nil
    }

    func onCancel(withArguments arguments: Any?) -> FlutterError? {
        guard let key = arguments as? String else {
            return FlutterError(code: "MISSING_PARAMS", message: "Missing 'key' parameter", details: nil)
        }
        print("EventChannelListener.onCancel => eventChannel for \(key) detached")

        MultiWindowMacosPlugin.multiEventSinks.removeValue(forKey: key)
        return nil
    }
}
