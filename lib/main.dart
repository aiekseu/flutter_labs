import 'dart:io';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final database = openDatabase(
    join(await getDatabasesPath(), 'products_database.db'),
    onCreate: (db, version) {
      return db.execute(
        'CREATE TABLE products(id INTEGER PRIMARY KEY, name TEXT, type TEXT, imagePath TEXT, price REAL, weight REAL)',
      );
    },
    version: 1,
  );

  runApp(MyApp(database: database,));
}

class MyApp extends StatelessWidget {

  final database;

  MyApp({required this.database});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(
        title: 'Lab6 Kudashkin Aleksey 8K81', database: database,),
    );
  }
}

class Product {
  final String name, type, imagePath;
  final double price, weight;
  final int id;

  Product(
      {required this.id, required this.name, required this.type, required this.price, required this.weight, required this.imagePath});

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'type': type,
      'imagePath': imagePath,
      'price': price,
      'weight': weight
    };
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key? key, required this.title, required this.database})
      : super(key: key);
  final String title;
  final database;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List<Product> _products = <Product>[];
  var loadedProducts;
  int _productsCount = 0;

  @override
  void initState() {
    Future.delayed(Duration(seconds: 1),() async {
      loadedProducts = getProducts();
    });
    super.initState();
  }

  Future<List<Product>> getProducts() async {
    final db = await widget.database;
    final List<Map<String, dynamic>> maps = await db.query('products');

    var temp = List.generate(maps.length, (i) {
      return Product(
          id: maps[i]['id'],
          name: maps[i]['name'],
          type: maps[i]['type'],
          imagePath: maps[i]['imagePath'],
          price: maps[i]['price'],
          weight: maps[i]['weight']
      );
    });

    setState(() {
      _products = temp;
      _productsCount = _products.length;
    });

    return temp;
  }

  Future<void> insertProductToDb(Product product) async {
    final db = await widget.database;

    await db.insert(
      'products',
      product.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> deleteProductFromDb(int id) async {
    final db = await widget.database;

    await db.delete(
      'products',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  void _deleteProduct(int index) {
    deleteProductFromDb(_products[index].id);
    setState(() {
      _products.removeAt(index);
      _productsCount--;
    });
  }

  void _addNewProduct(BuildContext context) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AddProduct()),
    );

    if (result != null) {
      setState(() {
        _productsCount++;
        _products.add(result);
        insertProductToDb(result);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: FutureBuilder(
          future: loadedProducts,
          builder: (BuildContext context, AsyncSnapshot snapshot) {
            if (!snapshot.hasData) {
              return Center(
                child: CircularProgressIndicator(
                    backgroundColor: Colors.red,
                    valueColor: new AlwaysStoppedAnimation<Color>(Colors.blue)),);
              } else {
              return ListView.builder(
                itemCount: _productsCount,
                itemBuilder: (BuildContext context, int index) {
                  return Dismissible(
                    key: Key((_products[index].id).toString()),
                    onDismissed: (direction) {_deleteProduct(index);},
                    background: Container(color: Colors.red),
                    child: Card(
                      child: ListTile(
                        leading: Image.file(
                          File(_products[index].imagePath),
                          fit: BoxFit.fitWidth,
                          height: 100,
                          width: 140,
                        ),
                        title: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(_products[index].name,
                                style:
                                TextStyle(fontSize: 18,
                                    fontWeight: FontWeight.bold)),
                            Text(
                              '${_products[index].price.toString()} руб.',
                              style: TextStyle(
                                  fontSize: 18, fontWeight: FontWeight
                                  .bold),
                            )
                          ],
                        ),
                        subtitle: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(_products[index].type),
                            Text('${_products[index].weight.toString()} кг')
                          ],
                        ),
                      ),
                    ),
                  );
                },
              );
            }
          }
      ),
      floatingActionButton: FloatingActionButton.extended(
        label: const Text(
          'Добавить продукт',
          style: TextStyle(fontSize: 16),
        ),
        icon: const Icon(Icons.plus_one),
        backgroundColor: Colors.pink,
        onPressed: () => {_addNewProduct(context)},
      ),
    );
  }
}

class AddProduct extends StatefulWidget {
  const AddProduct({Key? key}) : super(key: key);

  @override
  _AddProductState createState() => _AddProductState();
}

class _AddProductState extends State<AddProduct> {
  String _pName = '',
      _pType = '';
  double _pPrice = 0,
      _pWeight = 0;
  XFile? _photo;

  Future<void> _takePhoto() async {
    final ImagePicker _picker = ImagePicker();
    final photo = await _picker.pickImage(
        source: ImageSource.camera, maxHeight: 280, maxWidth: 200);
    setState(() {
      _photo = photo;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Добавить новый продукт'),
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
              Navigator.pop(context,
                  new Product(name: _pName,
                      type: _pType,
                      price: _pPrice,
                      weight: _pWeight,
                      imagePath: _photo!.path,
                      id: Random().nextInt(10000)));
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
                labelText: 'Название',
              ),
              onChanged: (String value) {
                setState(() {
                  _pName = value;
                });
              },
            ),
            TextField(
              decoration: InputDecoration(
                labelText: 'Тип',
              ),
              onChanged: (String value) {
                setState(() {
                  _pType = value;
                });
              },
            ),
            TextField(
              decoration: InputDecoration(
                labelText: 'Масса',
              ),
              keyboardType: TextInputType.number,
              onChanged: (String value) {
                setState(() {
                  _pWeight = double.parse(value);
                });
              },
            ),
            TextField(
              decoration: InputDecoration(
                labelText: 'Цена',
              ),
              keyboardType: TextInputType.number,
              onChanged: (String value) {
                setState(() {
                  _pPrice = double.parse(value);
                });
              },
            ),
            Text('Фото:'),
            _photo == null
                ? Text('Image is not loaded')
                : Image.file(File(_photo!.path)),
            ElevatedButton(onPressed: _takePhoto, child: Text('Добавить фото')),
          ],
        ),
      ),
    );
  }
}
