import 'package:flutter/material.dart';
import 'package:multi_window/multi_window.dart';
import 'package:multi_window/echo.dart';

void main(List<String> args) async {
  WidgetsFlutterBinding.ensureInitialized();

  MultiWindow.init(args);
  await MultiWindow.current.setTitle(MultiWindow.current.key);

  runApp(DemoApp());
}

class DemoApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MultiWindow Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MultiWindowDemo(),
    );
  }
}

class MultiWindowDemo extends StatefulWidget {
  @override
  _MultiWindowDemoState createState() => _MultiWindowDemoState();
}

class _MultiWindowDemoState extends State<MultiWindowDemo> {
  var lastEvent;

  late MultiWindow currentWindow;

  @override
  void initState() {
    super.initState();

    echo('initState');

    currentWindow = MultiWindow.current;
    currentWindow.events.listen((event) {
      echo('Received event on self: $event');
      setState(() => lastEvent = event);
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<int>(
      future: MultiWindow.count(),
      builder: (context, snapshot) {
        return Container(
          child: Scaffold(
            appBar: AppBar(title: Text('Running on ${currentWindow.key}')),
            body: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (currentWindow.key == 'main')
                      TextButton(
                        onPressed: () async => await emit('test_1'),
                        child: Text('Emit to test_1'),
                      ),
                    if (currentWindow.key != 'main')
                      TextButton(
                        onPressed: () async => await emit('main'),
                        child: Text('Emit to main'),
                      ),
                  ],
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Text('The amount of windows active:'),
                    Text(
                      '${snapshot.data ?? -1}',
                      style: Theme.of(context).textTheme.headline4,
                    ),
                    Text('$lastEvent'),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> emit(String key) async {
    echo("Creating $key");
    final instance = await MultiWindow.create(key);
    instance.events.listen((event) {
      echo('Received event on ${instance.key} instance: $event');
    });
    echo("Emitting event ${instance.key}");
    await instance.emit('hello');
  }
}
