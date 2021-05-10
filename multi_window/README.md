# multi_window

A Flutter package for easily creating and destroying new windows on Desktop.

## Features
- ??

## Getting Started

### Linux Setup

No setup required for Linux.

### MacOS Setup

Inside your application folder, go to `macos\runner\MainFlutterWindow.swift` and add this line after the one saying `import FlutterMacOS`:

```swift
import FlutterMacOS
import multi_window_macos // Add this line.
```

Then add the following line as the first line inside the `awakeFromNib()` function:

```swift
  override func awakeFromNib() {
    MultiWindowMacosPlugin.registerGeneratedPlugins = RegisterGeneratedPlugins // Add this line.
```
