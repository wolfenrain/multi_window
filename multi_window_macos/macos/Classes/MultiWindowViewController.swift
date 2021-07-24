import Foundation
import FlutterMacOS

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
            if (eventKey.starts(with: "\(key)/")) {
                MultiWindowMacosPlugin.multiEventSinks.removeValue(forKey: eventKey)
            }
        }
    }
    
    private func emit(_ data: Any?) {
        MultiWindowMacosPlugin.emitEvent(key, key, "system", data: data)
    }
}
