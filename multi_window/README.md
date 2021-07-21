# multi_window

A Flutter package for easily creating and destroying new windows on Desktop.

## Features

| Feature                     | **MacOS** | **Linux** | **Windows** |
| --------------------------- | --------- | --------- | ----------- |
| Creating new windows        |	✔️         | ✔️         |             |
| Receive window events       |           |           |             |
| Communicate between windows | ✔️         | ✔️         |             |

## Getting Started

### Required Flutter Setup

In your `lib/main.dart` change your `main` method to the following:

```dart
void main(List<String> args) {
  MultiWindow.init(args);

  ... // Rest of your code
}
```

### Linux Setup

No setup is required for Linux.

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

And below that line change the `FlutterViewController` to `MultiWindowViewController`:

```swift
let flutterViewController = MultiWindowViewController.init()
```

Your code should now look something like this: 

```swift
... // Your other imports

import multi_window_macos

class MainFlutterWindow: NSWindow {
  override func awakeFromNib() {
    MultiWindowMacosPlugin.registerGeneratedPlugins = RegisterGeneratedPlugins
    
    let flutterViewController = MultiWindowViewController.init()

    ... // Rest of your code
```

## Usage

To create a new window you can call the `MultiWindow.create` method:

```dart
void createNewWindow() async {
  final instance = await MultiWindow.create('your_unique_key');
}
```
