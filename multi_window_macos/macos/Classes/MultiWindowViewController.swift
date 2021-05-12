import Foundation
import FlutterMacOS

public class MultiWindowViewController: FlutterViewController, NSWindowDelegate {
    open override func viewWillDisappear() {
        emit([
            "event": "windowDisappear"
        ])
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
            MultiWindowMacosPlugin.emitEvent(window.key, "system", data: data)
        } else if view.window != nil {
            MultiWindowMacosPlugin.emitEvent("main", "system", data: data)
        }
    }
}
