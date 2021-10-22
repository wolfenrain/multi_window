import Cocoa
import FlutterMacOS

public class MultiWindowMacosPlugin: NSObject, FlutterPlugin {
    public static var registerGeneratedPlugins: ((FlutterPluginRegistry) -> Void)?

    static var multiEventSinks: [String: FlutterEventSink?] = [:]

    private var windows: [NSWindow] {
        NSApp.windows.filter({$0.contentViewController is MultiWindowViewController})
    }

    public static func register(with registrar: FlutterPluginRegistrar) {
        let instance = MultiWindowMacosPlugin(registrar)

        // Setup method channel.
        let methodChannel = FlutterMethodChannel(name: "multi_window_macos", binaryMessenger: registrar.messenger)
        registrar.addMethodCallDelegate(instance, channel: methodChannel)
    }

    public static func emitEvent(_ key: String, _ from: String, _ type: String, data: Any?) {
        for (eventKey, eventSink) in multiEventSinks {
            if eventKey.hasSuffix("/\(key)") {
                eventSink?([
                    "to": key,
                    "from": from,
                    "type": type,
                    "data": data
                ])
            }
        }
    }

    public init(_ registrar: FlutterPluginRegistrar) {
        self.registrar = registrar
        super.init()

        // Check if we have a main sink, if not this is the first run.
        if MultiWindowMacosPlugin.multiEventSinks.isEmpty {
            registerEventChannel("main")
        } else {
            for (eventKey, _) in MultiWindowMacosPlugin.multiEventSinks {
                let key = eventKey.split(separator: "/").last!
                registerEventChannel(String(key))
            }
        }
    }

    private let registrar: FlutterPluginRegistrar

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
        case "close":
            return close(call, result: result)
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
        let mainWindow = getWindow(["key": "main"])!

        guard let key = args["key"] as? String else {
            return result(FlutterError(code: "MISSING_PARAMS", message: "Missing 'key' parameter", details: nil))
        }

        // Registering a channel first, before starting a new flutter project.
        registerEventChannel(key)

        let project = FlutterDartProject.init()
        project.dartEntrypointArguments = [key]

        let controller = MultiWindowViewController.init(project: project)
        controller.key = key
        registerGeneratedPlugins(controller)

        let window = NSWindow()
        window.styleMask = mainWindow.styleMask
        window.backingType = mainWindow.backingType

        // Setup title.
        if let title = args["title"] as? String {
            window.title = title
        } else {
            window.title = mainWindow.title
        }

        var frame = mainWindow.frame
        // Setup size.
        if let size = args["size"] as? [String: Double] {
            guard let width = size["width"] else {
                return result(FlutterError(code: "MISSING_PARAMS", message: "Missing 'size.width' parameter", details: nil))
            }
            guard let height = size["height"] else {
                return result(FlutterError(code: "MISSING_PARAMS", message: "Missing 'size.height' parameter", details: nil))
            }
            frame = NSRect(origin: frame.origin, size: CGSize(width: width, height: height))
        }
        controller.view.frame = frame
        
        var origin = NSPoint(
                x: mainWindow.frame.origin.x + (mainWindow.frame.size.width - frame.size.width) / 2,
                y: mainWindow.frame.origin.y + mainWindow.frame.size.height /    2
        )
        if let alignment = args["alignment"] as? [String: Double] {
            guard let alignmentX = alignment["x"] else {
                return result(FlutterError(code: "MISSING_PARAMS", message: "Missing 'alignment.x' parameter", details: nil))
            }
            guard let alignmentY = alignment["y"] else {
                return result(FlutterError(code: "MISSING_PARAMS", message: "Missing 'alignment.y' parameter", details: nil))
            }
                
            // Using visibleFrame as this takes the Dock and Menubar in account.
            let screenFrame = mainWindow.screen!.convertRectToBacking(mainWindow.screen!.visibleFrame)

            if alignmentX == 0 {
                // center
                origin.x =  screenFrame.origin.x + (screenFrame.size.width - frame.size.width) / 2
            } else if alignmentX == 1 {
                // right
                origin.x =  screenFrame.origin.x + screenFrame.size.width - frame.size.width
            } else {
                // left
                origin.x = screenFrame.origin.x
            }
                
            if alignmentY == 0 {
                // TODO: Does not feel like true center (even taking the dock and menu bar in account)
                // center
                origin.y = screenFrame.origin.y + (screenFrame.size.height / 2)
            } else if alignmentY == -1 {
                // top
                origin.y = screenFrame.size.height
            } else {
                // bottom
                origin.y = screenFrame.origin.y
            }
        }
            
        window.setFrameOrigin(origin)
        window.contentViewController = controller

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
        guard let from = args["from"] as? String else {
            return result(FlutterError(code: "MISSING_PARAMS", message: "Missing 'from' parameter", details: nil))
        }

        MultiWindowMacosPlugin.emitEvent(key, from, "user", data: args["data"] ?? nil)

        return result(nil)
    }

    public func close(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        let args = getArgs(call.arguments)
        guard let window = getWindow(args) else {
            return result(FlutterError(code: "ERROR", message: "Could not find the window", details: nil))
        }

        window.close()

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

        return windows.first(where: {($0.contentViewController as! MultiWindowViewController).key == key})
    }

    private func registerEventChannel(_ key: String) {
        if !MultiWindowMacosPlugin.multiEventSinks.keys.contains("\(key)/\(key)") {
            MultiWindowMacosPlugin.multiEventSinks["\(key)/\(key)"] = nil as FlutterEventSink?
        }
        let eventChannel = FlutterEventChannel(name: "multi_window_macos/events/\(key)", binaryMessenger: registrar.messenger)
        eventChannel.setStreamHandler(EventChannelListener())
    }
}
