import 'package:flutter/material.dart';
import 'package:multi_window/multi_window.dart';
import 'package:multi_window/echo.dart';

void main(List<String> args) {
  MultiWindow.init(args);
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  var lastEvent;

  late MultiWindow currentWindow;

  @override
  void initState() {
    super.initState();

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
                    // TextButton(
                    //   onPressed: () async {
                    //     await MultiWindow.create('test_1');
                    //     setState(() {});
                    //   },
                    //   child: Text('Create test 1'),
                    // ),
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
                    TextButton(
                      onPressed: () async {
                        echo('Title was: ${await currentWindow.getTitle()}');
                        await currentWindow.setTitle(
                          'My key is: ${currentWindow.key}',
                        );
                        echo('Title is: ${await currentWindow.getTitle()}');
                      },
                      child: Text('Change title on self'),
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
    final instance = await MultiWindow.create(key);
    instance.events.listen((event) {
      echo('Received event on ${instance.key} instance: $event');
    });
    echo("Emitting event ${instance.key}");
    await instance.emit('hello');
  }
}
