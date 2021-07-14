import Foundation
import FlutterMacOS

public class MultiWindowViewController: FlutterViewController, NSWindowDelegate {
    open override func viewWillDisappear() {
        emit([
            "event": "windowDisappear"
        ])
        // TODO: Remove all references
        super.viewWillDisappear()
    }

    open override func viewWillAppear() {
        emit([
            "event": "windowAppear"
        ])
        super.viewWillAppear()
    }

    private func emit(_ data: Any?) {
        if let window = view.window as? MultiWindow {
            MultiWindowMacosPlugin.emitEvent(window.key, window.key, "system", data: data)
        } else if view.window != nil {
            MultiWindowMacosPlugin.emitEvent("main", "main", "system", data: data)
        }
    }
}
