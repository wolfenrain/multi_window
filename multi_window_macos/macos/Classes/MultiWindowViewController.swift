import Foundation
import FlutterMacOS

public class MultiWindowViewController: FlutterViewController, NSWindowDelegate {
    var key: String = "main"
    
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
        MultiWindowMacosPlugin.emitEvent(key, key, "system", data: data)
    }
}
