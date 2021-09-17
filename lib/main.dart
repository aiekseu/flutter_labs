import 'dart:math';
import 'package:flutter/cupertino.dart';
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
      home: MyHomePage(title: 'Lab8 Kudashkin Aleksey 8K81'),
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
  String _expression = '', _mathAction = '+';
  int _firstNum = 0,
      _secondNum = 0,
      _answersRight = 0,
      _rightPos = 0,
      _answersGeneral = 0,
      _rightAnswer = 0;
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
      _rightCoefficient = (_answersRight / _answersGeneral == 0)
          ? 0.1
          : _answersRight / _answersGeneral;

      _firstNum = random.nextInt(25) +
          random.nextInt((_rightCoefficient * 2 * _answersGeneral + 1).round());
      _secondNum = random.nextInt(25) +
          random.nextInt((_rightCoefficient * 2 * _answersGeneral + 1).round());

      switch (_mathAction) {
        case '*':
          {
            _firstNum = (_firstNum / 3).round() + random.nextInt(5);
            _secondNum = (_secondNum / 3).round() + random.nextInt(5);
            _rightAnswer = _firstNum * _secondNum;
            break;
          }
        case '+':
          {
            _rightAnswer = _firstNum + _secondNum;
            break;
          }
        case '-':
          {
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
        if (i != _rightPos) {
          _answers[i] = _rightAnswer + random.nextInt(20) - 10;
          if (_answers[i] == _rightAnswer) _answers[i] = _rightAnswer - 1;
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

  void _changeAction() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const PickMathActionPage()),
    );

    if (result != null) {
      setState(() {
        _mathAction = result;
      });
      _nextExpression();
    }
  }

  void _changeActionTo(String action) {
    setState(() {
      _mathAction = action;
    });
    _nextExpression();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: OrientationBuilder(
        builder: (context, orientation) {
          return Row(
            children: [
              (orientation == Orientation.landscape)
                  ? Expanded(
                      flex: 1,
                      child: Column(
                        children: [
                          ListTile(
                            title: Text('Сложение'),
                            leading: Icon(Icons.plus_one),
                            onTap: () {
                              _changeActionTo('+');
                            },
                          ),
                          ListTile(
                            title: Text('Вычитание'),
                            leading: Icon(Icons.exposure_minus_1),
                            onTap: () {
                              _changeActionTo('-');
                            },
                          ),
                          ListTile(
                            title: Text('Умножение'),
                            leading: Icon(Icons.two_k),
                            onTap: () {
                              _changeActionTo('*');
                            },
                          ),
                        ],
                      ),
                    )
                  : Container(),
              Expanded(
                flex: 3,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Padding(
                      padding: (orientation == Orientation.portrait)
                          ? EdgeInsets.only(top: 16.0)
                          : EdgeInsets.only(top: 4.0),
                      child: Center(
                        child: Text(
                          'Выражение:',
                          style: (orientation == Orientation.portrait)
                              ? TextStyle(fontSize: 20)
                              : TextStyle(fontSize: 16),
                        ),
                      ),
                    ),
                    (orientation == Orientation.portrait)
                        ? Tooltip(
                            message:
                                'Нажмите на выражение для смены арифметического действия',
                            decoration: BoxDecoration(
                                color: Colors.grey,
                                borderRadius: BorderRadius.circular(15)),
                            margin: EdgeInsets.symmetric(horizontal: 24),
                            textStyle:
                                TextStyle(fontSize: 16, color: Colors.white),
                            child: InkWell(
                              onTap: _changeAction,
                              child: Padding(
                                padding: const EdgeInsets.only(top: 16.0),
                                child: Center(
                                  child: Text(
                                    _expression,
                                    style: TextStyle(
                                        fontSize: 28,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ),
                            ),
                          )
                        : Padding(
                            padding: const EdgeInsets.only(top: 4.0),
                            child: Center(
                              child: Text(
                                _expression,
                                style: TextStyle(
                                    fontSize: 20, fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                    Divider(),
                    (orientation == Orientation.portrait)
                        ? Column(
                            children: answersVariants,
                          )
                        : Row(children: answersVariants),
                    Expanded(
                      child: Container(
                        child: Visibility(
                            visible: _isAnswered,
                            child: _isRight
                                ? Column(
                                    children: [
                                      (orientation == Orientation.portrait)
                                          ? Icon(
                                              Icons.check_circle,
                                              size: 128,
                                              color: Colors.green,
                                            )
                                          : Container(),
                                      Text(
                                        'Верно!',
                                        style: TextStyle(
                                            fontSize: 24, color: Colors.green),
                                      )
                                    ],
                                  )
                                : Column(
                                    children: [
                                      (orientation == Orientation.portrait)
                                          ? Icon(
                                              Icons.close,
                                              size: 128,
                                              color: Colors.redAccent,
                                            )
                                          : Container(),
                                      Text(
                                        'Неверно!',
                                        style: TextStyle(
                                            fontSize: 24,
                                            color: Colors.redAccent),
                                      )
                                    ],
                                  )),
                      ),
                    ),
                    Text(
                      'Правильных ответов: $_answersRight / $_answersGeneral',
                      style: TextStyle(fontSize: 16),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 28.0),
                      child: OutlinedButton(
                        onPressed: _nextExpression,
                        child: Text(
                          'Следующее выражение',
                          style: TextStyle(
                              fontSize: 26, fontWeight: FontWeight.w300),
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  List<Widget> get answersVariants {
    bool isPortair =
        (MediaQuery.of(context).orientation == Orientation.portrait);

    return isPortair
        ? [
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
          ]
        : [
            Expanded(
              child: Card(
                child: ListTile(
                  title: Text('${_answers[0]}'),
                  onTap: () => _checkAnswer(0),
                ),
              ),
            ),
            Expanded(
              child: Card(
                child: ListTile(
                  title: Text('${_answers[1]}'),
                  onTap: () => _checkAnswer(1),
                ),
              ),
            ),
            Expanded(
              child: Card(
                child: ListTile(
                  title: Text('${_answers[2]}'),
                  onTap: () => _checkAnswer(2),
                ),
              ),
            ),
            Expanded(
              child: Card(
                child: ListTile(
                  title: Text('${_answers[3]}'),
                  onTap: () => _checkAnswer(3),
                ),
              ),
            )
          ];
  }
}

class PickMathAction extends StatelessWidget {
  const PickMathAction({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            ListTile(
              title: Text('Сложение'),
              leading: Icon(Icons.plus_one),
              onTap: () {
                Navigator.pop(context, '+');
              },
            ),
            ListTile(
              title: Text('Вычитание'),
              leading: Icon(Icons.exposure_minus_1),
              onTap: () {
                Navigator.pop(context, '-');
              },
            ),
            ListTile(
              title: Text('Умножение'),
              leading: Icon(Icons.two_k),
              onTap: () {
                Navigator.pop(context, '*');
              },
            ),
          ],
        ),
      ),
    );
  }
}

class PickMathActionPage extends StatelessWidget {
  const PickMathActionPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Выбрать математическое действие'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            tooltip: 'Назад',
            onPressed: () {
              Navigator.pop(context, null);
            },
          ),
        ),
        body: PickMathAction());
  }
}
