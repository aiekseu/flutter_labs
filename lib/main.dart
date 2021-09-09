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

class Product {
  final String name, type;
  final double price, weight;

  Product(this.name, this.type, this.price, this.weight);
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key? key, required this.title}) : super(key: key);
  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List<Product> _products = <Product>[];
  int _productsCount = 0;

  @override
  void initState() {
    _products.add(new Product('Яблоко', 'Фрукт', 30, 0.2));
    _products.add(new Product('Iphone 12', 'Смартфон', 72000, 0.162));
    _products.add(new Product('Lada Granta', 'Автомобиль', 764500, 1185));
    _productsCount += 3;
    super.initState();
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
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: ListView.builder(
        itemCount: _productsCount,
        itemBuilder: (BuildContext context, int index) {
          return Card(
            child: ListTile(
              title: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(_products[index].name,
                      style:
                      TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  Text(
                    '${_products[index].price.toString()} руб.',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
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
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        label: const Text('Добавить продукт', style: TextStyle(fontSize: 16),),
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
  String _pName = '', _pType = '';
  double _pPrice = 0, _pWeight = 0;

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
              Navigator.pop(
                  context, new Product(_pName, _pType, _pPrice, _pWeight));
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
          ],
        ),
      ),
    );
  }
}
