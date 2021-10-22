[![plugin version](https://img.shields.io/pub/v/multi_window?label=pub)](https://pub.dev/packages/multi_window)
[![coverage report](https://gitlab.com/wolfenrain/multi_window/badges/master/coverage.svg)](https://gitlab.com/wolfenrain/multi_window/-/commits/master)
[![pipeline status](https://gitlab.com/wolfenrain/multi_window/badges/master/pipeline.svg)](https://gitlab.com/wolfenrain/multi_window/-/commits/master)
[![dependencies](https://img.shields.io/librariesio/release/pub/multi_window?label=dependencies)](https://gitlab.com/wolfenrain/multi_window/-/blob/master/multi_window/pubspec.yaml)

<h1 align="center">multi_window</h1>

A package for adding multi window support to Flutter on Desktop.

**WARNING**: This is an experimental package and is under heavy development. No guarantees can be giving that the API will stay the same.

## Features

| Feature                     | **MacOS** | **Linux** | **Windows** |
| --------------------------- | --------- | --------- | ----------- |
| Creating new windows        | ✔️        | ✔️        |             |
| Closing existing windows    | ✔️        | ✔️        |             |
| Receive window events¹      | ✔️        | ✔️        |             |
| Communicate between windows | ✔️        | ✔️        |             |

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

### Creating a new window

To create a new window you can call the `MultiWindow.create` method:

```dart
final myWindow = await MultiWindow.create(
  'your_unique_key',
  size: Size(100, 100), // Optional size.
  title: 'Your Title', // Optional title.
  alignment: Alignment.center, // Optional alginment.
);
```

If a window with the given key already exists it will return a reference to that window.

**NOTE**: The first window that is created on startup will use the key `main`.

### Accessing your current window

The instance of the current window (the window that your dart code is being executed on) is exposed for convencience sake:

```dart
final myWindow = MultiWindow.current; // Returns the current instance this code is running on.
```

### CLosing a window

A window can be programmatically closed by calling it's close method:

```dart
final myWindow = await MultiWindow.create('myWindow');

// Close the window instance.
await myWindow.close();
```

When the window succesfully closes the `windowClose` event will be raised.

### Get the count of the current existing windows

Retrieving the total amount of windows can be done using the `MultiWindow.count` method:

```dart
final totalWindows = await MultiWindow.count();
```

### Setting and getting a window title

If you want to set or get the title of your window you can use the `setTitle` and `getTitle` methods respectively on your instance:

```dart
await myWindow.setTitle('My fancy title');
final currentTitle = await myWindow.getTitle(); // Returns 'My fancy title'.
```

### Listening and emitting events

#### Listening to events

A `MultiWindow` instance also exposes an event stream for listening to events on a window instance:

```dart
final myWindow = await MultiWindow.create('myWindow');
myWindow.events.listen((event) {
  print('From: ${event.from}, of type ${event.type} with data ${event.data}');
});
```

An event exists out the following:

- The `to` is the key of the window that will receive this event, if you are listening on a window it will be that window's key.
- The `sender` is the key of the window that send the event, this can also be the window that you are listening on.
- The `type` is an enum that allows you to differentiate between system and user events.
- The `data` contains dynamic data that was emitted.

#### Emitting events

You can emit a user event by calling the `.emit` method on a `MultiWindow` instance:

```dart
await myWindow.emit('Hello world!');
```
