import 'dart:math';
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
      home: MyHomePage(title: 'Lab3 Kudashkin Aleksey 8K81'),
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
  int _buttonsAdded = 0;
  int _listSize = 0;
  var _list = <Widget>[];

  void _showSnackBar(int num) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      duration: Duration(milliseconds: 1000),
      content: Text("Нажата кнопка $num"),
    ));
  }

  void _addButton() {
    setState(() {
      _buttonsAdded++;
      _listSize++;
      _list.add(MyButton(
          id: _buttonsAdded,
          onPressed: _showSnackBar,
          buttonText: 'Кнопка №$_buttonsAdded'
      ));
    });
  }

  void _addElement() {
    setState(() {
      _listSize++;
      _list.add(Center(
        child: Text(
          'Элемент №${Random().nextInt(1000)}',
          style: TextStyle(fontSize: 16),
        ),
      ));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: Center(
              child: OutlinedButton(
                onPressed: _addElement,
                style: OutlinedButton.styleFrom(
                    textStyle: TextStyle(fontSize: 20)),
                child: Text('Добавить элемент'),
              ),
            ),
          ),
          Divider(),
          Padding(
            padding: const EdgeInsets.only(bottom: 12.0),
            child: Text(
              'Список элементов:',
              style: TextStyle(fontSize: 24),
            ),
          ),
          Expanded(
            child: ListView.builder(
                itemCount: _listSize,
                itemBuilder: (BuildContext context, int index) {
                  return _list[index];
                }),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 48.0),
            child: Center(
              child: OutlinedButton(
                onPressed: _addButton,
                style: OutlinedButton.styleFrom(
                    textStyle: TextStyle(fontSize: 20)),
                child: Text('Добавить кнопку'),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class MyButton extends StatelessWidget {
  final int id;
  final Function(int) onPressed;
  final String buttonText;

  const MyButton(
      {required this.id, required this.onPressed, required this.buttonText});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
        onPressed: () => {onPressed(this.id)},
        child: new Text(this.buttonText)
    );
  }
}
