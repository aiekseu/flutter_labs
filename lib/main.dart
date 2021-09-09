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
      home: MyHomePage(title: 'Lab4 Kudashkin Aleksey 8K81'),
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

  String _expression = '', _mathAction = '';
  int _firstNum = 0, _secondNum = 0, _answersRight = 0, _rightPos = 0, _answersGeneral = 0, _rightAnswer = 0;
  double _rightCoefficient = 1;
  List<int> _answers = List<int>.filled(4, 0);
  bool _isRight = false, _isAnswered = false;

  Random random = new Random();

  @override
  void initState() {
    _generateExpression();
    _generateAnswers();
    super.initState();
  }

  void _generateExpression() {
    setState(() {
      _answersGeneral++;
      _rightCoefficient = (_answersRight / _answersGeneral == 0) ? 0.1 : _answersRight / _answersGeneral;

      _firstNum = random.nextInt(25) + random.nextInt((_rightCoefficient * 2 *_answersGeneral + 1).round());
      _secondNum = random.nextInt(25) + random.nextInt((_rightCoefficient * 2 * _answersGeneral + 1).round());

      int temp = random.nextInt(3);
      switch (temp) {
        case 0: {
          _mathAction = '*';
          _firstNum = (_firstNum / 3).round() + random.nextInt(5);
          _secondNum = (_secondNum / 3).round() + random.nextInt(5);
          _rightAnswer = _firstNum * _secondNum;
          break;
        }
        case 1: {
          _mathAction = '+';
          _rightAnswer = _firstNum + _secondNum;
          break;
        }
        case 2: {
          _mathAction = '-';
          _rightAnswer = _firstNum - _secondNum;
          break;
        }
      }

      _expression = '$_firstNum $_mathAction $_secondNum = ?';
    });
  }

  void _generateAnswers() {
    setState(() {
      _rightPos = random.nextInt(4);
      _answers[_rightPos] = _rightAnswer;
      for (int i = 0; i < 4; i++) {
        if (i != _rightPos)
        {
          _answers[i] = _rightAnswer + random.nextInt(20) - 10;
          if (_answers[i] == _rightAnswer)
            _answers[i] = _rightAnswer - 1;
        }
      }
    });
  }

  void _checkAnswer(int index) {
    setState(() {
      _isAnswered = true;
      if (index == _rightPos) {
        _answersRight++;
        _isRight = true;
      }
    });
  }

  void _nextExpression() {
    setState(() {
      _isAnswered = false;
      _isRight = false;
      _generateExpression();
      _generateAnswers();
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
            padding: const EdgeInsets.only(top: 16.0),
            child: Center(
              child: Text('Выражение:', style: TextStyle(fontSize: 20),),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 16.0),
            child: Center(
              child: Text(_expression, style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),),
            ),
          ),
          Divider(),
          Column(
            children: [
              Card(
                child: ListTile(
                  title: Text('${_answers[0]}'),
                  onTap: () => _checkAnswer(0),
                ),
              ),
              Card(
                child: ListTile(
                  title: Text('${_answers[1]}'),
                  onTap: () => _checkAnswer(1),
                ),
              ),
              Card(
                child: ListTile(
                  title: Text('${_answers[2]}'),
                  onTap: () => _checkAnswer(2),
                ),
              ),
              Card(
                child: ListTile(
                  title: Text('${_answers[3]}'),
                  onTap: () => _checkAnswer(3),
                ),
              )
            ],
          ),
          Expanded(
            child: Container(
              child: Visibility(
                  visible: _isAnswered,
                  child: _isRight
                      ? Column(
                    children: [
                      Icon(Icons.check_circle, size: 128, color: Colors.green,),
                      Text('Верно!', style: TextStyle(fontSize: 24, color: Colors.green),)
                    ],
                  )
                      : Column(
                    children: [
                      Icon(Icons.close, size: 128, color: Colors.redAccent,),
                      Text('Неверно!', style: TextStyle(fontSize: 24, color: Colors.redAccent),)
                    ],
                  )
              ),
            ),
          ),
          Text('Правильных ответов: $_answersRight / $_answersGeneral', style: TextStyle(fontSize: 16),),
          Padding(
            padding: const EdgeInsets.only(bottom: 28.0),
            child: OutlinedButton(
              onPressed: _nextExpression,
              child: Text('Следующее выражение', style: TextStyle(fontSize: 26, fontWeight: FontWeight.w300),),
            ),
          )
        ],
      ),
    );
  }
}
