import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'Lab2 Kudashkin Aleksey 8K81'),
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
  double? _first = 0;
  double? _second = 0;
  double? _result = 0;

  void _updateFirst(String value) {
    setState(() {
      _first = double.tryParse(value);
    });
  }

  void _updateSecond(String value) {
    setState(() {
      _second = double.tryParse(value);
    });
  }

  void _getSum() {
    setState(() {
      if (_first!.isNaN || _second!.isNaN)
        return;
      _result = _first! + _second!;
    });
  }

  void _getDifference() {
    setState(() {
      if (_first!.isNaN || _second!.isNaN)
        return;
      _result = _first! - _second!;
    });
  }

  void _getMultiplication() {
    setState(() {
      if (_first!.isNaN || _second!.isNaN)
        return;
      _result = _first! * _second!;
    });
  }

  void _getDivision() {
    setState(() {
      if (_first!.isNaN || _second!.isNaN)
        return;
      _result = (_first! / _second! * 1000).roundToDouble() / 1000;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextField(
                decoration: InputDecoration(
                  labelText: 'Первое число',
                ),
                keyboardType: TextInputType.number,
                onChanged: (String value) {
                  _updateFirst(value);
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: TextField(
                decoration: InputDecoration(
                  labelText: 'Второе число',
                ),
                keyboardType: TextInputType.number,
                onChanged: (String value) {
                  _updateSecond(value);
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: ElevatedButton(
                onPressed: _getSum,
                style: ElevatedButton.styleFrom(
                  textStyle: TextStyle(fontSize: 20),
                ),
                child: Text('Сложить'),
              ),
            ),
            ElevatedButton(
              onPressed: _getDifference,
              style: ElevatedButton.styleFrom(
                textStyle: TextStyle(fontSize: 20),
              ),
              child: Text('Вычесть'),
            ),
            ElevatedButton(
              onPressed: _getMultiplication,
              style: ElevatedButton.styleFrom(
                textStyle: TextStyle(fontSize: 20),
              ),
              child: Text('Умножить'),
            ),
            ElevatedButton(
              onPressed: _getDivision,
              style: ElevatedButton.styleFrom(
                textStyle: TextStyle(fontSize: 20),
              ),
              child: Text('Разделить'),
            ),
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Text(
                'Результат операции: $_result',
                style: Theme.of(context).textTheme.headline5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
