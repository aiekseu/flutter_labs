import 'package:flutter/material.dart';
import 'dart:math' as math;

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
      home: MyHomePage(title: 'Lab11 Kudashkin Aleksey 8K81'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key? key, required this.title}) : super(key: key);
  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> with TickerProviderStateMixin {
  double _size = 100;

  late Animation<double> animation;
  late AnimationController controller;

  @override
  void initState() {
    super.initState();

    controller = AnimationController(
      vsync: this,
      duration: Duration(seconds: 5),
    );
    Tween<double> _movingTween = Tween(begin: -math.pi, end: math.pi);
    animation = _movingTween.animate(controller)
      ..addListener(() {
        setState(() {});
      })
      ..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          controller.repeat();
        } else if (status == AnimationStatus.dismissed) {
          controller.forward();
        }
      });
    controller.forward();

  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Expanded(
              // child: CustomPaint(
              //   painter: TPainterU(_size, animation.value),
              //   child: Container(),
              // ),
              child: AnimatedBuilder(
                animation: animation,
                builder: (context, snapshot) {
                  return CustomPaint(
                    painter: TPainterU(_size, animation.value),
                    child: Container(),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 24.0),
              child: Text('Размер', style: TextStyle(fontSize: 18),),
            ),
            Slider(
              value: _size,
              min: 25.0,
              max: 180.0,
              label: _size.toInt().toString(),
              divisions: 25,
              onChanged: (value) {
                setState(() {
                  _size = value;
                });
              },
            ),
          ],
        ),
      ),
    );
  }
}

class TPainterU extends CustomPainter {
  final double radius;
  final double radians;

  TPainterU(this.radius, this.radians);

  @override
  void paint(Canvas canvas, Size size) {
    var greenPaint = Paint()
      ..color = Colors.green
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    var blackPaint = Paint()
      ..color = Colors.black
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    Offset center = Offset(size.width / 2 + math.sin(radians)*5000/radius, size.height / 2 + math.cos(radians)*5000/radius);

    var greenPath = Path()
    ..addRect(Rect.fromCenter(center: Offset(center.dx-radius*2/3, center.dy-radius*2/3), width: radius*2/3 - (radius / 10), height: radius*2/3 - (radius / 10)))
    ..addRect(Rect.fromCenter(center: Offset(center.dx, center.dy-radius/3), width: radius*2/3 - (radius / 10), height: radius*4/3 - (radius / 10)))
    ..addRect(Rect.fromCenter(center: Offset(center.dx+radius*2/3, center.dy-radius*2/3), width: radius*2/3 - (radius / 10), height: radius*2/3 - (radius / 10)));

    var blackPath = Path()
      ..addRect(Rect.fromCenter(center: Offset(center.dx-radius*2/3, center.dy+radius/3), width: radius*2/3 - (radius / 10), height: radius*4/3 - (radius / 10)))
      ..addRect(Rect.fromCenter(center: Offset(center.dx, center.dy+radius*2/3), width: radius*2/3 - (radius / 10), height: radius*2/3 - (radius / 10)))
      ..addRect(Rect.fromCenter(center: Offset(center.dx+radius*2/3, center.dy+radius/3), width: radius*2/3 - (radius / 10), height: radius*4/3 - (radius / 10)));

    canvas.drawPath(greenPath, greenPaint);
    canvas.drawPath(blackPath, blackPaint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}
