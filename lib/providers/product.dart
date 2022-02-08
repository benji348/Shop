import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;

class Product with ChangeNotifier {
  final String id;
  final String title;
  final String description;
  final double price;
  final String imageUrl;
  bool isFavorite;

  Product(
      {required this.description,
      required this.id,
      required this.imageUrl,
      this.isFavorite = false,
      required this.price,
      required this.title});

  Future<void> toggleFavoriteStatus(String token, String userId) async {
    final oldStatus = isFavorite;
    isFavorite = !isFavorite;
    notifyListeners();

    final url = Uri.parse(
        'https://benji-shop-default-rtdb.firebaseio.com/userFavorite/$userId/$id.json?auth=$token');

    try {
      final response = await http.put(url,
          body: json.encode(
            isFavorite,
          ));
      if (response.statusCode >= 400) {
        isFavorite = oldStatus;
        notifyListeners();
      }
    } catch (erro) {
      isFavorite = oldStatus;
      notifyListeners();
    }
  }
}
