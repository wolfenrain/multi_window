import Foundation
import FlutterMacOS
import Cocoa

public class MultiWindowViewController: FlutterViewController, NSWindowDelegate {
    var key: String = "main"

    open override func viewWillAppear() {
        let window = view.window
        window!.delegate = self

        super.viewWillAppear()
    }

    public func windowWillClose(_ notification: Notification) {
        emit([
            "event": "windowClose"
        ])

        for (eventKey, _) in MultiWindowMacosPlugin.multiEventSinks {
            if eventKey.starts(with: "\(key)/") {
                MultiWindowMacosPlugin.multiEventSinks.removeValue(forKey: eventKey)
            }
        }
        NotificationCenter.default.removeObserver(self, name: NSWindow.willCloseNotification, object: notification.object)
    }
    
    public func windowShouldClose(_ sender: NSWindow) -> Bool {
        //force deinit everything else and close the flutter engine
        sender.contentViewController?.view.removeFromSuperview()
        sender.contentViewController = nil
        sender.windowController?.window = nil
        sender.windowController = nil// will force deinit.
        sender.delegate = nil
        self.engine.viewController = nil
        self.engine.shutDownEngine() //shut down the flutter engine to reduce memory usage after the window close
        return true // allow to close.
    }

    private func emit(_ data: Any?) {
        MultiWindowMacosPlugin.emitEvent(key, key, "system", data: data)
    }
}
