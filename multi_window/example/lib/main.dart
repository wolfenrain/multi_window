import 'package:flavor_text/flavor_text.dart';
import 'package:flutter/material.dart';
import 'package:multi_window/multi_window.dart';
import 'package:multi_window/echo.dart';
import 'package:multi_window/multi_widget.dart';

void main(List<String> args) async {
  WidgetsFlutterBinding.ensureInitialized();

  MultiWindow.init(args);

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
      debugShowCheckedModeBanner: false,
      home: MultiWidget({
        'settings': Text('Settings page'),
        'topLeft': Text('topLeft'),
        'topCenter': Text('topCenter'),
        'topRight': Text('topRight'),
        'bottomLeft': Text('bottomLeft'),
        'bottomCenter': Text('bottomCenter'),
        'bottomRight': Text('bottomRight'),
        'centerLeft': Text('centerLeft'),
        'center': Text('center'),
        'centerRight': Text('centerRight'),
        'noAlignment': Text('noAlignment'),
      }, fallback: MultiWindowDemo()),
    );
  }
}

class MultiWindowDemo extends StatefulWidget {
  @override
  _MultiWindowDemoState createState() => _MultiWindowDemoState();
}

class _MultiWindowDemoState extends State<MultiWindowDemo> {
  MultiWindow get currentWindow => MultiWindow.current;

  MultiWindow? secondaryWindow;

  List<DataEvent> events = [];

  TextEditingController? controller;

  @override
  void initState() {
    super.initState();
    MultiWindow.current.setTitle(MultiWindow.current.key);

    controller = TextEditingController();

    currentWindow.events.listen((event) {
      echo('Received event on self: $event');
      setState(() => events.add(event));
    });

    if (currentWindow.key != "main") {
      MultiWindow.create('main').then(
        (value) => setState(() => secondaryWindow = value),
      );
    }
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }

  Widget buildConsole(int windowCount) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Expanded(
        child: ListView(
          children: [
            for (final event in events)
              FlavorText(
                'From <style color="primaryColor">${event.from}</style> to <style color="primaryColor">${event.to}</style> with message <style color="primaryColor">${event.data}</style>',
              ),
          ],
        ),
      ),
      Text('The amount of windows active: $windowCount'),
      Form(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              child: TextFormField(
                controller: controller,
                decoration: InputDecoration(hintText: 'Message'),
                onFieldSubmitted: (_) => emit(
                  currentWindow.key == 'main' ? 'secondary' : 'main',
                ),
              ),
            ),
            IconButton(
              onPressed: () => emit(
                currentWindow.key == 'main' ? 'secondary' : 'main',
              ),
              icon: Icon(Icons.send),
            ),
          ],
        ),
      )
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<int>(
      future: MultiWindow.count(),
      builder: (context, snapshot) {
        return Scaffold(
          appBar: AppBar(
            title: Text('Running on ${currentWindow.key}'),
            actions: [
              IconButton(
                onPressed: currentWindow.close,
                icon: Icon(Icons.close),
              ),
              IconButton(
                onPressed: () {
                  final size = Size(300, 300);
                  MultiWindow.create(
                    'topLeft',
                    size: size,
                    title: 'Top Left',
                    alignment: Alignment.topLeft,
                  );
                  MultiWindow.create(
                    'topCenter',
                    size: size,
                    title: 'Top Center',
                    alignment: Alignment.topCenter,
                  );
                  MultiWindow.create(
                    'topRight',
                    size: size,
                    title: 'Top Right',
                    alignment: Alignment.topRight,
                  );
                  MultiWindow.create(
                    'bottomLeft',
                    size: size,
                    title: 'Bottom Left',
                    alignment: Alignment.bottomLeft,
                  );
                  MultiWindow.create(
                    'bottomCenter',
                    size: size,
                    title: 'Bottom Center',
                    alignment: Alignment.bottomCenter,
                  );
                  MultiWindow.create(
                    'bottomRight',
                    size: size,
                    title: 'Bottom Right',
                    alignment: Alignment.bottomRight,
                  );
                  MultiWindow.create(
                    'centerLeft',
                    size: size,
                    title: 'Center Left',
                    alignment: Alignment.centerLeft,
                  );
                  MultiWindow.create(
                    'center',
                    size: size,
                    title: 'Center',
                    alignment: Alignment.center,
                  );
                  MultiWindow.create(
                    'centerRight',
                    size: size,
                    title: 'Center Right',
                    alignment: Alignment.centerRight,
                  );
                  MultiWindow.create(
                    'noAlignment',
                    size: size,
                    title: 'No Alignment',
                  );
                },
                icon: Icon(Icons.grid_view),
              ),
            ],
          ),
          body: Padding(
              padding: const EdgeInsets.all(8.0),
              child: secondaryWindow == null
                  ? ElevatedButton(
                      onPressed: () => create(
                        currentWindow.key == 'main' ? 'secondary' : 'main',
                      ),
                      child: Text('Create secondary window'),
                    )
                  : buildConsole(snapshot.data ?? -1)),
        );
      },
    );
  }

  Future<void> create(String key) async {
    secondaryWindow = await MultiWindow.create(
      key,
      alignment: Alignment.topLeft,
    );
    secondaryWindow?.events.listen((event) {
      if (event.type == DataEventType.system &&
          event.data['event'] == 'windowClose') {
        setState(() {
          secondaryWindow = null;
        });
      }
    });
    setState(() {});
  }

  Future<void> emit(String key) async {
    echo("Emitting event ${secondaryWindow?.key}");
    await secondaryWindow?.emit(controller?.text);
    setState(() => controller?.text = '');
  }
}
