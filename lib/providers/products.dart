import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'product.dart';
import '../models/http_exception.dart';

class Products with ChangeNotifier {
  List<Product> _items = [
    // Product(
    //   id: 'p1',
    //   title: 'Red Shirt',
    //   description: 'A red shirt - it is pretty red!',
    //   price: 29.99,
    //   imageUrl:
    //       'https://cdn.pixabay.com/photo/2016/10/02/22/17/red-t-shirt-1710578_1280.jpg',
    //   isFavorite: false,
    // ),
    // Product(
    //   id: 'p2',
    //   title: 'Trousers',
    //   description: 'A nice pair of trousers.',
    //   price: 59.99,
    //   imageUrl:
    //       'https://upload.wikimedia.org/wikipedia/commons/thumb/e/e8/Trousers%2C_dress_%28AM_1960.022-8%29.jpg/512px-Trousers%2C_dress_%28AM_1960.022-8%29.jpg',
    //   isFavorite: false,
    // ),
    // Product(
    //   id: 'p3',
    //   title: 'Yellow Scarf',
    //   description: 'Warm and cozy - exactly what you need for the winter.',
    //   price: 19.99,
    //   imageUrl:
    //       'https://live.staticflickr.com/4043/4438260868_cc79b3369d_z.jpg',
    //   isFavorite: false,
    // ),
    // Product(
    //   id: 'p4',
    //   title: 'A Pan',
    //   description: 'Prepare any meal you want.',
    //   price: 49.99,
    //   imageUrl:
    //       'https://upload.wikimedia.org/wikipedia/commons/thumb/1/14/Cast-Iron-Pan.jpg/1024px-Cast-Iron-Pan.jpg',
    //   isFavorite: false,
    // ),
  ];

  var _showFavoritesOnly = false;
  final String _authToken;

  Products(this._authToken, this._items);

  List<Product> get items {
    // if (_showFavoritesOnly) {
    //   return _items.where((element) => element.isFavorite).toList();
    // }
    return [..._items];
  }

  List<Product> get favoriteItems {
    return _items.where((element) => element.isFavorite).toList();
  }

  Future<void> fetchAndSetProducts() async {
    try {
      var endpointUrl =
          'https://flutter-update-65521-default-rtdb.firebaseio.com/products.json';
      Map<String, String> queryParams = {
        'auth': _authToken,
      };
      String queryString = Uri(queryParameters: queryParams).query;

      var requestUrl = endpointUrl + '?' + queryString;

      final response = await http.get(requestUrl);
      final extractedData = json.decode(response.body) as Map<String, dynamic>;

      if (extractedData == null) {
        return;
      }

      final List<Product> loadedProducts = [];
      extractedData.forEach((prodId, prodData) {
        loadedProducts.add(Product(
          id: prodId,
          title: prodData['title'],
          description: prodData['description'],
          imageUrl: prodData['imageUrl'],
          price: prodData['price'],
          isFavorite: prodData['isFavorite'],
        ));
      });

      _items = loadedProducts;
      notifyListeners();
    } catch (error) {
      throw error;
    }
  }

  Future<void> addProduct(Product product) async {
    // const url =
    //     'https://flutter-update-65521-default-rtdb.firebaseio.com/products.json';

    // http.post(
    //   Uri.http('195.28.11.123', 'api/project/addproject'),
    //   headers: <String, String>{
    //     'Content-Type': 'application/json; charset=UTF-8',
    //   },
    //   body: json.encode({
    //     "name": "test from andoird",
    //     "estimatedDelivery": "2021-03-23T10:10:55.478Z",
    //     "deadline": "2021-03-23T10:10:55.478Z"
    //   }),
    // );
    try {
      final response = await http.post(
        Uri.https('flutter-update-65521-default-rtdb.firebaseio.com',
            'products.json'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: json.encode({
          'title': product.title,
          'description': product.description,
          'imageUrl': product.imageUrl,
          'price': product.price,
          'isFavorite': product.isFavorite ?? false,
        }),
      );

      final newProduct = new Product(
          title: product.title,
          description: product.description,
          imageUrl: product.imageUrl,
          price: product.price,
          id: json.decode(response.body)['name']);

      _items.add(newProduct);
      // _items.insert(0, newProduct); at the start of the line
      notifyListeners();
    } catch (error) {
      print(error);
      throw error;
    }
  }

  // void showFavoritesOnly() {
  //   _showFavoritesOnly = true;
  //   notifyListeners();
  // }

  // void showAll() {
  //   _showFavoritesOnly = false;
  //   notifyListeners();
  // }

  Product findById(String id) {
    return _items.firstWhere((product) => product.id == id);
  }

  Future<void> updateProduct(String id, Product newProduct) async {
    final prodIndex = _items.indexWhere((prod) => prod.id == id);
    if (prodIndex >= 0) {
      try {
        await http.patch(
          Uri.https(
              'flutter-update-65521-default-rtdb.firebaseio.com', '$id.json'),
          body: json.encode(
            {
              'title': newProduct.title,
              'price': newProduct.price,
              'description': newProduct.description,
              'imageUrl': newProduct.imageUrl,
            },
          ),
        );
        _items[prodIndex] = newProduct;
        notifyListeners();
      } catch (error) {
        throw error;
      }
    } else {
      print('...');
    }
  }

  Future<void> deleteProduct(String id) async {
    final existingProductIndex =
        _items.indexWhere((element) => element.id == id);
    var existingProduct = _items[existingProductIndex];

    _items.removeAt(existingProductIndex);
    notifyListeners();

    final response = await http.delete(
      Uri.https('flutter-update-65521-default-rtdb.firebaseio.com', '$id.json'),
    );

    if (response.statusCode >= 400) {
      _items.insert(existingProductIndex, existingProduct);
      notifyListeners();
      throw HttpException('Could not delete product!');
    }
    existingProduct = null;
  }
}
