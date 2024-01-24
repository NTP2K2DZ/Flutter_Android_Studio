import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Danh sach san pham',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: HomeScreen(),
    );
  }
}

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Trang Chu"),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            Navigator.push(context, MaterialPageRoute(builder: (context) => ProductListScreen()),);
          },
          child: Text('Go to ProductListScreen'),
        ),
      ),
    );
  }

}

class ProductListScreen extends StatefulWidget {
  @override
  _ProductListScreenState createState() => _ProductListScreenState();
}

class _ProductListScreenState extends State<ProductListScreen> {
  late List<Product> products;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    products = [];
    fetchProduct();
  }
  List<Product> convertMapToProductList(Map<String, dynamic> data) {
    List<Product> productList = [];
    data.forEach((key, value) {
      for (int i = 0; i < value.length; i++) {
        Product product = Product(
            search_image: value[i]['search_image'] ?? '',
            styleid: value[i]['styleid'] ?? '',
            brands_filter_facet: value[i]['brands_filter_facet'] ?? '',
            price: value[i]['price'] ?? '',
            product_additional_info: value[i]['product_additional_info'] ?? ''
        );
        productList.add(product);
      }
    });
    return productList;
  }
  Future<void> fetchProduct() async {
    final response = await http.get(Uri.parse("http://192.168.1.5/aserver/api.php"));
    if(response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      setState(() {
        products = convertMapToProductList(data);
      });
    }
    else {
      throw Exception("Khong load dc su lieu");
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Danh sach san pham'),
      ),
      body: products != null ?
        ListView.builder(
          itemCount: products.length,
          itemBuilder: (context, index) {
            return ListTile(
              title: Text(products[index].brands_filter_facet),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Price: ${products[index].price}'),
                  Text('Product_additional_info: ${products[index].product_additional_info}'),

                ],
              ),
              leading: Image.network(
                products[index].search_image,
                width: 50,
                height: 50,
                fit: BoxFit.cover,
              ),
              onTap: () {
                Navigator.push(context,
                  MaterialPageRoute(builder: (context) => ProductDetailScreen(products[index]),
                  ),
                );
              },
            );
          },
        )
        : Center(
          child: CircularProgressIndicator(),
      )
    );
  }
}

// dinh nghia ProductDetails
class ProductDetailScreen extends StatelessWidget{
  final Product product;
  ProductDetailScreen(this.product);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('ProductDetail'),
        actions: [
            ElevatedButton(onPressed: () {
              Navigator.push(context,
              MaterialPageRoute(builder: (context) => CartScreen()),);
            },
            child: Icon(Icons.shopping_cart),
            style: ElevatedButton.styleFrom(
              shape: CircleBorder(),
              padding: EdgeInsets.all(0)
            ),
            ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(padding: const EdgeInsets.all(8.0),
          child: Text('Brand: ${product.brands_filter_facet}'),
          ),
          Image.network(product.search_image),
          Padding(padding: const EdgeInsets.all(8),
            child: Text('Info: ${product.product_additional_info}',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          Padding(padding: const EdgeInsets.all(8),
          child: Text('ID: ${product.styleid}'),
          ),
          Padding(padding: const EdgeInsets.all(8),
            child: Text('Price: ${product.price}'),
          ),
        ],
      ),
    );
}
}

class CartScreen extends StatelessWidget{
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Shopping Cart"),
      ),
      body: Center(child: Text("Gio hang cua ban"),),
    );
  }

}

class Product {
  String search_image;
  String styleid;
  String brands_filter_facet;
  String price;
  String product_additional_info;

  Product({
    required this.search_image,
    required this.styleid,
    required this.brands_filter_facet,
    required this.price,
    required this.product_additional_info
  });
}

