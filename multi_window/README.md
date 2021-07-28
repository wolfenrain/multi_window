[![plugin version](https://img.shields.io/pub/v/multi_window?label=pub)](https://pub.dev/packages/multi_window)
[![coverage report](https://gitlab.com/wolfenrain/multi_window/badges/master/coverage.svg)](https://gitlab.com/wolfenrain/multi_window/-/commits/master)
[![pipeline status](https://gitlab.com/wolfenrain/multi_window/badges/master/pipeline.svg)](https://gitlab.com/wolfenrain/multi_window/-/commits/master)
[![dependencies](https://img.shields.io/librariesio/release/pub/multi_window?label=dependencies)](https://gitlab.com/wolfenrain/multi_window/-/blob/master/multi_window/pubspec.yaml)
<h1 align="center">multi_window</h1>

A Flutter package for easily creating and destroying new windows on Desktop.

**NOTE**: This plugin is still under heavy development, as long as v1 hasn't been reach expect breaking changes left and right.

## Features

| Feature                     | **MacOS** | **Linux** | **Windows** |
| --------------------------- | --------- | --------- | ----------- |
| Creating new windows        |	✔️         | ✔️         |             |
| Receive window events¹      | ✔️         | ✔️         |             |
| Communicate between windows | ✔️         | ✔️         |             |

Notes: 
1. For more info about implemented events see the [Events table](https://gitlab.com/wolfenrain/multi_window/-/tree/master/CONTRIBUTING.md#events-table).

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
let flutterViewController = MultiWindowViewController()
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

### Accessing your current window

You don't want to keep track of your own current window, so we introduced a helper property called `current` for you:

```dart
final window = MultiWindow.current; // Returns the current instance this code is running on.
```

**NOTE**: The first window on startup always has the key `main`.

### Creating a new window

To create a new window you can call the `MultiWindow.create` method:

```dart
final window = await MultiWindow.create(
  'your_unique_key',
  size: Size(100, 100), // Optional size.
  title: 'Your Title', // Optional title.
);
```

If a window with the given key already exists it will return a reference to that window.

### Getting lists of total created windows

Retrieving the total amount of windows can be done using the `MultiWindow.count` method:

```dart
final totalWindows = await MultiWindow.count();
```

### Setting and getting a window title

If you want to set or get the title of your window you can use the `setTitle` and `getTitle` methods respectively on your instance:

```dart
await window.setTitle('My fancy title');
final currentTitle = await window.getTitle(); // Returns 'My fancy title'.
```

### Listening and emitting events

You can also send data to other windows and listen to events on them.

If you want to listen to events on your current window you can do the following:

```dart
MultiWindow.current.events.listen((event) {
  print('From: ${event.from}, of type ${event.type} with data ${event.data}');
});
```

You can also emit events on your own window like so:

```dart
await MultiWindow.current.emit('Hello!');
```

If your current window's key is `main`, then another window can listen to events on your current window by just getting a reference to that window:

```dart
final window = await MultiWindow.create('main');
window.events.listen((event) {
  print('From: ${event.from}, of type ${event.type} with data ${event.data}');
});
```