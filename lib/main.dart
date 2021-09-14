import 'dart:async';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

void main() async {
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
      home: MyHomePage(title: 'Lab7 Kudashkin Aleksey 8K81'),
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
  late var _currentLocation;
  late StreamSubscription<Position> _positionStream;

  List<MyPlace> _checkpoints = [
    new MyPlace(name: 'ГК ТПУ', coords: '56.4654, 84.9502'),
    new MyPlace(name: 'Дом', coords: '53.9060, 87.1285'),
  ];

  void initStream() {
    _positionStream = Geolocator.getPositionStream(
            desiredAccuracy: LocationAccuracy.high, distanceFilter: 5)
        .listen((Position position) {
      setState(() {
        _currentLocation = (position.latitude.toString() +
            ', ' +
            position.longitude.toString());
      });

      double distanceBetween = 0;

      for (var i = 0; i < _checkpoints.length; ++i) {
        if (!_checkpoints[i].isChecked) continue;
        distanceBetween = Geolocator.distanceBetween(
            position.latitude,
            position.longitude,
            getLatLng(_checkpoints[i].coords)[0],
            getLatLng(_checkpoints[i].coords)[1]).roundToDouble();


          print('До ${_checkpoints[i].name} осталось $distanceBetween метров!');
        if (distanceBetween < 100) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              duration: Duration(seconds: 3),
              content: Text('До ${_checkpoints[i].name} осталось $distanceBetween метров!'),
            ),
          );
        }
      }
    });
  }

  void disposeStream() {
    _positionStream.cancel();
  }

  List<CheckboxListTile> _getList() {
    var tempList = <CheckboxListTile>[];
    for (var i = 0; i < _checkpoints.length; ++i) {
      tempList.add(new CheckboxListTile(
        title: Text(_checkpoints[i].name),
        subtitle: Text(_checkpoints[i].coords),
        value: _checkpoints[i].isChecked,
        onChanged: (bool? value) {
          setState(() {
            _checkpoints[i].isChecked = value ?? false;
          });
        },
        secondary: Icon(Icons.place),
      ));
    }
    return tempList;
  }

  @override
  void initState() {
    Future.delayed(Duration(seconds: 1), () async {
      bool serviceEnabled;
      LocationPermission permission;

      // Включены ли службы Геолокации
      serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        print('Location services are disabled.');
      }

      // Получены ли разрешения от пользователя
      permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          print('Location permissions are denied');
        }
      }

      // Если пользователь навсегда запретил приложению использовать службы
      if (permission == LocationPermission.deniedForever) {
        print(
            'Location permissions are permanently denied, we cannot request permissions.');
      }

      print('Location services are enabled');
    });

    initStream();
    super.initState();
  }

  void _addNewPlacemark(BuildContext context) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const NewPlacemark()),
    );

    if (result != null) {
      setState(() {
        _checkpoints.add(result);
      });
    }
  }

  List<double> getLatLng(String string) {
    List<double> tempDoubleList = <double>[];
    var tempStrList = string.split(', ');
    tempDoubleList.add(double.parse(tempStrList[0]));
    tempDoubleList.add(double.parse(tempStrList[1]));
    return tempDoubleList;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(widget.title),
        ),
        floatingActionButton: FloatingActionButton.extended(
          label: const Text(
            'Добавить метку',
            style: TextStyle(fontSize: 16),
          ),
          icon: const Icon(Icons.map),
          backgroundColor: Colors.pink,
          onPressed: () => {_addNewPlacemark(context)},
        ),
        body: Column(
          children: [
            Padding(
              padding: EdgeInsets.only(top: 16),
              child: Center(
                child: Column(
                  children: [
                    Text('Текущее местоположение:',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.w300)),
                    Text(_currentLocation.toString(),
                        style: TextStyle(
                            fontSize: 22, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
            ),
            Divider(),
            Padding(
              padding: const EdgeInsets.only(top: 12),
              child: Text(
                'Выберите метки',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w400),
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: _getList(),
              ),
            )
          ],
        ));
  }
}

class NewPlacemark extends StatefulWidget {
  const NewPlacemark({Key? key}) : super(key: key);

  @override
  _NewPlacemarkState createState() => _NewPlacemarkState();
}

class _NewPlacemarkState extends State<NewPlacemark> {
  String _name = '';
  String _coords = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Добавить новую метку'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          tooltip: 'Назад',
          onPressed: () {
            Navigator.pop(context, null);
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.done),
            tooltip: 'Добавить продукт',
            onPressed: () {
              Navigator.pop(context, new MyPlace(name: _name, coords: _coords));
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            TextField(
              decoration: InputDecoration(
                labelText: 'Название места',
              ),
              onChanged: (String value) {
                setState(() {
                  _name = value;
                });
              },
            ),
            TextField(
              decoration: InputDecoration(
                labelText: 'Координаты',
              ),
              onChanged: (String value) {
                setState(() {
                  _coords = value;
                });
              },
            ),
          ],
        ),
      ),
    );
  }
}

class MyPlace {
  final String name;
  final String coords;
  bool isChecked = false;

  MyPlace({required this.name, required this.coords});
}
