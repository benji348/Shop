import 'dart:convert';
import 'package:benji_shop_app/models/my_exceptions.dart';
import 'package:benji_shop_app/providers/cart.dart';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;

class OrderItem {
  final String id;
  final double amount;
  final List<CartItem> products;
  final DateTime dateTime;

  OrderItem(
      {required this.amount,
      required this.dateTime,
      required this.id,
      required this.products});
}

class Order with ChangeNotifier {
  List<OrderItem> _orders = [];
  final String authToken;
  final String userId;

  Order(this.authToken, this.userId, this._orders);

  List<OrderItem> get orders {
    return [..._orders];
  }

  Future<void> httpFetchSetOrders() async {
    final url = Uri.parse(
        'https://benji-shop-default-rtdb.firebaseio.com/neworders/$userId.json?auth=$authToken');
    final response = await http.get(url);
    final List<OrderItem> loadedOrdersFromWebServer = [];
    final extractedOrderFireBase =
        json.decode(response.body) as Map<String, dynamic>;
    extractedOrderFireBase.forEach((orderId, orderData) {
      if (extractedOrderFireBase != null) {
        loadedOrdersFromWebServer.add(OrderItem(
            amount: orderData['amount'],
            dateTime: DateTime.parse(orderData['dateTime']),
            id: orderId,
            products: (orderData['products'] as List<dynamic>)
                .map((e) => CartItem(
                    id: e['id'],
                    price: e['price'],
                    quantity: e['quantity'],
                    title: e['title']))
                .toList()));
      }
    });
    _orders = loadedOrdersFromWebServer.reversed.toList();
    notifyListeners();
  }

  Future<void> addOrder(List<CartItem> cartProducts, double total) async {
    final url = Uri.parse(
        'https://benji-shop-default-rtdb.firebaseio.com/neworders/$userId.json?auth=$authToken');
    final timeStamp = DateTime.now();
    try {
      final response = await http.post(url,
          body: json.encode({
            'amount': total,
            'dateTime': timeStamp.toIso8601String(),
            'products': cartProducts
                .map((cp) => {
                      'id': cp.id,
                      'title': cp.title,
                      'quantity': cp.quantity,
                      'price': cp.price
                    })
                .toList()
          }));
      _orders.insert(
        0,
        OrderItem(
            id: json.decode(response.body)['name'],
            amount: total,
            dateTime: timeStamp,
            products: cartProducts),
      );
      notifyListeners();
    } catch (error) {
      MyHttpExecptions(error.toString());
    }
  }
}
