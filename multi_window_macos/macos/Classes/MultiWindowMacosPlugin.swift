import Cocoa
import FlutterMacOS

public class MultiWindowMacosPlugin: NSObject, FlutterPlugin {
  private static var _registerGeneratedPlugins = [] as [(FlutterPluginRegistry) -> ()];
  
  public static var registerGeneratedPlugins: (FlutterPluginRegistry) -> () {
    set { _registerGeneratedPlugins.append(newValue) }
    get { _registerGeneratedPlugins.last!  }
  }
    
  private var mainWindow: NSWindow {
    get { NSApp.windows.first(where: {!($0 is MultiWindow)})! }
  }
  
  private var multiWindows: [MultiWindow] {
    get { NSApp.windows.filter({$0 is MultiWindow}) as! [MultiWindow] }
  }
  
  public static func register(with registrar: FlutterPluginRegistrar) {
    // Setup method channel.
    let methodChannel = FlutterMethodChannel(name: "multi_window_macos", binaryMessenger: registrar.messenger)
    let instance = MultiWindowMacosPlugin()
    registrar.addMethodCallDelegate(instance, channel: methodChannel)
    
    // Setup event channel.
    let eventChannel = FlutterEventChannel(name: "multi_window_macos/events", binaryMessenger: registrar.messenger)
    eventChannel.setStreamHandler(EventChannelListener(plugin: instance))
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    switch call.method {
   case "create":
     create(call, result: result)
    case "count":
      result(NSApp.windows.count)
    default:
      result(FlutterMethodNotImplemented)
    }
  }

  public func create(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    // Check if we already have a window with given key.
    if (getWindow(call) != nil) {
        return;
    }
    
    let args = getArgs(call)
    guard let key = args["key"] as? String else {
      return result(FlutterError(code: "MISSING_PARAMS", message: "Missing 'key' parameter", details: nil))
    }
    
    let flutterController = FlutterViewController.init()
    MultiWindowMacosPlugin.registerGeneratedPlugins(flutterController)
    
    let window = MultiWindow()
    window.key = key
    window.styleMask = mainWindow.styleMask
    window.backingType = mainWindow.backingType
        
    window.setFrameOrigin(mainWindow.frame.origin)
    window.setContentSize(mainWindow.frame.size)
    window.contentViewController = flutterController
    window.title = mainWindow.title
    
    let windowController = NSWindowController()
    windowController.contentViewController = window.contentViewController
    windowController.shouldCascadeWindows = mainWindow.windowController?.shouldCascadeWindows ?? true
    windowController.window = window
    windowController.showWindow(self)
  }
  
  private func getArgs(_ call: FlutterMethodCall) -> [String: Any?] {
    guard let arguments = call.arguments as? [String: Any?] else {
      return [:]
    }
    return arguments
  }

  private func getWindow(_ call: FlutterMethodCall) -> MultiWindow? {
    let args = getArgs(call)
    
    guard let key = args["args"] as? String  else {
      return nil
    }
    
    return multiWindows.first(where: {$0.key == key})
  }
    
}
