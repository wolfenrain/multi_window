import FlutterMacOS

class EventChannelListener: NSObject, FlutterStreamHandler {
    let plugin: MultiWindowMacosPlugin
    
    init(plugin: MultiWindowMacosPlugin) {
        self.plugin = plugin
        super.init()
    }
    
    func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
        print("EventChannelListener.onListen => eventChannel attached")
        
        // TODO: see if we can use arguments to identify different windows

        return nil
    }

    func onCancel(withArguments arguments: Any?) -> FlutterError? {
        print("EventChannelListener.onCancel => eventChannel detached")
        
        return nil
    }
}
