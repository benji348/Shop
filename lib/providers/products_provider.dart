import 'dart:convert';

import 'package:benji_shop_app/models/my_exceptions.dart';
import 'package:benji_shop_app/providers/product.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class ProductsProvider with ChangeNotifier {
  List<Product> _loadedProducts = [
    // Product(
    //   id: 'p1',
    //   title: 'Red Shirt',
    //   description: 'A red shirt - it is pretty red!',
    //   price: 29.99,
    //   imageUrl:
    //       'https://cdn.pixabay.com/photo/2016/10/02/22/17/red-t-shirt-1710578_1280.jpg',
    // ),
    // Product(
    //   id: 'p2',
    //   title: 'Trousers',
    //   description: 'A nice pair of trousers.',
    //   price: 59.99,
    //   imageUrl:
    //       'https://upload.wikimedia.org/wikipedia/commons/thumb/e/e8/Trousers%2C_dress_%28AM_1960.022-8%29.jpg/512px-Trousers%2C_dress_%28AM_1960.022-8%29.jpg',
    // ),
    // Product(
    //   id: 'p3',
    //   title: 'Yellow Scarf',
    //   description: 'Warm and cozy - exactly what you need for the winter.',
    //   price: 19.99,
    //   imageUrl:
    //       'https://live.staticflickr.com/4043/4438260868_cc79b3369d_z.jpg',
    // ),
    // Product(
    //   id: 'p4',
    //   title: 'A Pan',
    //   description: 'Prepare any meal you want.',
    //   price: 49.99,
    //   imageUrl:
    //       'https://upload.wikimedia.org/wikipedia/commons/thumb/1/14/Cast-Iron-Pan.jpg/1024px-Cast-Iron-Pan.jpg',
    // ),
  ];

  // var _showFavoritesOnly = false;
  final String authToken;
  final String userId;

  Product findById(String id) {
    return _loadedProducts.firstWhere((element) => element.id == id);
  }

  List<Product> get favoriteItems {
    return _loadedProducts.where((element) => element.isFavorite).toList();
  }

  List<Product> get items {
    // if (_showFavoritesOnly) {
    //   return _loadedProducts.where((prodItem) => prodItem.isFavorite).toList();
    // }
    return [..._loadedProducts];
  }

  ProductsProvider(this.authToken, this.userId, this._loadedProducts);

  // void showFavoritesOnly() {
  //   _showFavoritesOnly = true;
  //   notifyListeners();
  // }

  // void showAll() {
  //   _showFavoritesOnly = false;
  //   notifyListeners();
  // }

  Future<void> httpFetchSetProducts([bool filterByUserId = false]) async {
    final filterString =
        filterByUserId ? '&orderBy="creatorId"&equalTo="$userId"' : '';
    final url = Uri.parse(
        'https://benji-shop-default-rtdb.firebaseio.com/newproducts.json?auth=$authToken$filterString');
    try {
      final response = await http.get(url);
      debugPrint(json.decode(response.body));
      final extratedData = json.decode(response.body) as Map<String, dynamic>;
      final favoriteResponse = await http.get(Uri.parse(
          'https://benji-shop-default-rtdb.firebaseio.com/userFavorite/$userId.json?auth=$authToken'));
      final favoriteData = json.decode(favoriteResponse.body);
      final List<Product> loadedProductsFromWebServer = [];
      extratedData.forEach((httpGetProdId, httpGetProddata) {
        if (extratedData != null) {
          loadedProductsFromWebServer.add(Product(
            description: httpGetProddata['description'],
            id: httpGetProdId,
            imageUrl: httpGetProddata['imageUrl'],
            price: httpGetProddata['price'],
            title: httpGetProddata['title'],
            isFavorite: favoriteData == null
                ? false
                : favoriteData[httpGetProdId] ?? false,
          ));
        }
      });

      _loadedProducts = loadedProductsFromWebServer;
      notifyListeners();
    } catch (error) {
      print(error);
      rethrow;
    }
  }

  Future<void> httpAddProducts(Product addingProdcut) async {
    final url = Uri.parse(
        'https://benji-shop-default-rtdb.firebaseio.com/newproducts.json?auth=$authToken');
    try {
      final response = await http.post(url,
          body: json.encode({
            'title': addingProdcut.title,
            'description': addingProdcut.description,
            'imageUrl': addingProdcut.imageUrl,
            'price': addingProdcut.price,
            'creatorId': userId
          }));
      print(json.encode(response.body));

      final newProduct = Product(
          description: addingProdcut.description,
          id: json.decode(response.body)['name'],
          imageUrl: addingProdcut.imageUrl,
          price: addingProdcut.price,
          title: addingProdcut.title);
      _loadedProducts.add(newProduct);
      notifyListeners();
    } catch (error) {
      print(error);
      rethrow;
    }
  }

  Future<void> updateProduct(String id, Product newProduct) async {
    final prodIndex = _loadedProducts.indexWhere((element) => element.id == id);
    if (prodIndex >= 0) {
      final url = Uri.parse(
          'https://benji-shop-default-rtdb.firebaseio.com/newproducts/$id.json?auth=$authToken');
      await http.patch(url,
          body: json.encode({
            'title': newProduct.title,
            'description': newProduct.description,
            'imagUrl': newProduct.imageUrl,
            'price': newProduct.price
          }));
      _loadedProducts[prodIndex] = newProduct;
      notifyListeners();
    } else {
      print('...');
    }
  }

  Future<void> deleteProduct(String id) async {
    final url = Uri.parse(
        'https://benji-shop-default-rtdb.firebaseio.com/newproducts/$id.json?auth=$authToken');
    final existingProductIndex =
        _loadedProducts.indexWhere((prod) => prod.id == id);
    var existingProduct = _loadedProducts[existingProductIndex];
    _loadedProducts.removeAt(existingProductIndex);
    notifyListeners();
    final response = await http.delete(url);

    if (response.statusCode >= 400) {
      _loadedProducts.insert(existingProductIndex, existingProduct);
      notifyListeners();
      throw MyHttpExecptions('Delete product failed');
    } else {
      existingProduct = null as dynamic;
      notifyListeners();
    }
  }
}
