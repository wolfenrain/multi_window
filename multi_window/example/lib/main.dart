import 'package:flutter/material.dart';
import 'package:multi_window/multi_window.dart';

void main(List<String> args) {
  print(args);
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
      home: MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  void initState() {
    super.initState();

    // final instance = MultiWindow.create('unique key');
    // instance.events.listen((event) {
    //   print(event);
    // });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<int>(
      future: MultiWindow.count(),
      builder: (context, snapshot) {
        print(snapshot.data);
        return Container(
          child: Scaffold(
            appBar: AppBar(title: Text(widget.title)),
            body: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    TextButton(
                      onPressed: () async {
                        await MultiWindow.create('test_1');
                        setState(() {});
                      },
                      child: Text('Create test 1'),
                    ),
                  ],
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Text(
                      'The amount of windows active:',
                    ),
                    Text(
                      '${snapshot.data ?? -1}',
                      style: Theme.of(context).textTheme.headline4,
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
