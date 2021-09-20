import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'Lab9 Kudashkin Aleksey 8K81'),
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
  int _timeInterval = 1, _initialValue = 0, _counter = 0;
  static const platform = MethodChannel('com.avk224.lab10/counter');

  @override
  void initState() {
    platform.setMethodCallHandler(nativeMethodCallHandler);
    super.initState();
  }

  Future<void> nativeMethodCallHandler(MethodCall methodCall) async {
    print('Kotlin call!');
    switch (methodCall.method) {
      case "counterHasChanged":
        {
          setState(() {
            _counter = methodCall.arguments;
          });
        }
    }
  }

  Future<void> _reloadCounter() async {
    setState(() {
      _counter = _initialValue;
    });

    try {
      await platform.invokeMethod(
          'reloadCounter', 0);
    } on PlatformException catch (e) {
      print(e.message);
    }
  }

  Future<void> _startAndroidService() async {
    await platform.invokeMethod('startService', {'initialValue' : _initialValue, 'timeInterval' : _timeInterval});
  }

  Future<void> _stopAndroidService() async {
    await platform.invokeMethod('stopService');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Padding(
        padding: const EdgeInsets.only(top: 28.0, left: 12, right: 12),
        child: Column(
          children: [
            TextField(
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                hintText: 'Начальное значение',
                border: OutlineInputBorder(),
              ),
              onChanged: (String value) {
                setState(() {
                  _initialValue = int.parse(value);
                });
              },
            ),
            Divider(),
            TextField(
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                hintText: 'Интервал (в секундах)',
                border: OutlineInputBorder(),
              ),
              onChanged: (String value) {
                setState(() {
                  _timeInterval = int.parse(value);
                });
              },
            ),
            Padding(
              padding: EdgeInsets.only(top: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  OutlinedButton(
                    child: Text('Запустить счетчик'),
                    onPressed: () {
                      _startAndroidService();
                    },
                  ),
                  OutlinedButton(
                    child: Text('Остановить счетчик'),
                    onPressed: () {
                      setState(() {
                        _stopAndroidService();
                      });
                    },
                  ),
                ],
              ),
            ),
            OutlinedButton(
              child: Text('Сбросить счетчик'),
              onPressed: () {
                _reloadCounter();
              },
            ),
            Padding(
              padding: const EdgeInsets.only(top: 24.0),
              child: Text('Счетчик:', style: TextStyle(fontSize: 22)),
            ),
            Text('$_counter',
                style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold))
          ],
        ),
      ),
    );
  }
}
