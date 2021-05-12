import Cocoa
import FlutterMacOS

public class MultiWindowMacosPlugin: NSObject, FlutterPlugin {
  public static var registerGeneratedPlugins: ((FlutterPluginRegistry) -> Void?

  static var multiEventSinks: [String: [FlutterEventSink]] = [:]

  public static func register(with registrar: FlutterPluginRegistrar) {
    let instance = MultiWindowMacosPlugin(registrar)

    // Setup method channel.
    let methodChannel = FlutterMethodChannel(name: "multi_window_macos", binaryMessenger: registrar.messenger)
    registrar.addMethodCallDelegate(instance, channel: methodChannel)
  }

  public static func emitEvent(_ key: String, _ type: String, data: Any?) {
    MultiWindowMacosPlugin.multiEventSinks[key]?.forEach({
      $0([
        "key": key,
        "type": type,
        "data": data
      ])
    })
  }

  public init(_ registrar: FlutterPluginRegistrar) {
    self.registrar = registrar
    super.init()

    // Check if we have a main sink, if not this is the first run.
    if MultiWindowMacosPlugin.multiEventSinks["main"] == nil {
        registerEventChannel("main")
    } else {
        MultiWindowMacosPlugin.multiEventSinks.keys.forEach({registerEventChannel($0)})
    }
  }

  private let registrar: FlutterPluginRegistrar

  private var mainWindow: NSWindow {
    get { NSApp.windows.first(where: {!($0 is MultiWindow)})! }
  }

  private var multiWindows: [MultiWindow] {
    get { NSApp.windows.filter({$0 is MultiWindow}) as! [MultiWindow] }
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    switch call.method {
    case "create":
      return create(call, result: result)
    case "setTitle":
      return setTitle(call, result: result)
    case "getTitle":
      return getTitle(call, result: result)
    case "emit":
      return emit(call, result: result)
    case "count":
      return result(NSApp.windows.count)
    default:
      return result(FlutterMethodNotImplemented)
    }
  }

  public func setTitle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    let args = getArgs(call.arguments)
    guard let window = getWindow(args) else {
      return result(FlutterError(code: "ERROR", message: "Could not find the window", details: nil))
    }

    guard let title = args["title"] as? String else {
      return result(FlutterError(code: "MISSING_PARAMS", message: "Missing 'title' parameter", details: nil))
    }
    window.title = title

    return result(nil)
  }

  public func getTitle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    let args = getArgs(call.arguments)
    guard let window = getWindow(args) else {
      return result(FlutterError(code: "ERROR", message: "Could not find the window", details: nil))
    }

    return result(window.title)
  }

  public func create(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    guard let registerGeneratedPlugins = MultiWindowMacosPlugin.registerGeneratedPlugins else {
      return result(FlutterError(code: "ERROR", message: "RegisterGeneratedPlugins was not bound", details: nil))
    }

    let args = getArgs(call.arguments)

    // Check if we already have a window with given key.
    if getWindow(args) != nil {
      return result(nil)
    }

    guard let key = args["key"] as? String else {
      return result(FlutterError(code: "MISSING_PARAMS", message: "Missing 'key' parameter", details: nil))
    }

    // Registering a channel first, before starting a new flutter project.
    registerEventChannel(key)

    let project = FlutterDartProject.init()
    project.dartEntrypointArguments = [key]

    let controller = MultiWindowViewController.init(project: project)
    registerGeneratedPlugins(controller)

    let window = MultiWindow()
    window.key = key
    window.styleMask = mainWindow.styleMask
    window.backingType = mainWindow.backingType

    window.setFrameOrigin(mainWindow.frame.origin)
    window.setContentSize(NSSize(width: 500, height: 500))
    window.contentViewController = controller
    window.title = mainWindow.title

    let windowController = NSWindowController()
    windowController.contentViewController = window.contentViewController
    windowController.shouldCascadeWindows = mainWindow.windowController?.shouldCascadeWindows ?? true
    windowController.window = window
    windowController.showWindow(self)

    return result(nil)
  }

  public func emit(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    let args = getArgs(call.arguments)

    guard let key = args["key"] as? String else {
      return result(FlutterError(code: "MISSING_PARAMS", message: "Missing 'key' parameter", details: nil))
    }

    MultiWindowMacosPlugin.emitEvent(key, "user", data: args["data"] ?? nil)

    return result(nil)
  }

  public func getArgs(_ arguments: Any?) -> [String: Any?] {
    guard let arguments = arguments as? [String: Any?] else {
      return [:]
    }
    return arguments
  }

  public func getWindow(_ arguments: [String: Any?]) -> NSWindow? {
    guard let key = arguments["key"] as? String else {
      return nil
    }

    if key == "main" {
      return mainWindow
    }
    return multiWindows.first(where: {$0.key == key})
  }

  private func registerEventChannel(_ key: String) {
    if MultiWindowMacosPlugin.multiEventSinks[key] == nil {
      MultiWindowMacosPlugin.multiEventSinks[key] = []
    }
    let eventChannel = FlutterEventChannel(name: "multi_window_macos/events/\(key)", binaryMessenger: registrar.messenger)
    eventChannel.setStreamHandler(EventChannelListener(key: key))
  }
}
