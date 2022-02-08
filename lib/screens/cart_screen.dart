import 'package:benji_shop_app/providers/cart.dart' show Cart;
import 'package:benji_shop_app/providers/orders.dart';
import 'package:benji_shop_app/widgets/cart_item.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({Key? key}) : super(key: key);
  static const routeName = '/cart_Screen';

  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<Cart>(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Cart'),
      ),
      body: Column(
        children: [
          Card(
            margin: const EdgeInsets.all(15),
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Total', style: TextStyle(fontSize: 20)),
                  const Spacer(),
                  Chip(
                    label: Text(
                      '\$${cart.toatAmount.toStringAsFixed(2)}',
                      style: const TextStyle(
                        color: Colors.white,
                      ),
                    ),
                    backgroundColor: Theme.of(context).primaryColor,
                  ),
                  OrderNow(
                    cart: cart,
                  )
                ],
              ),
            ),
          ),
          const SizedBox(height: 10),
          Expanded(
              child: ListView.builder(
            itemBuilder: (ctx, i) => CartItem(
                id: cart.items.values.toList()[i].id,
                productId: cart.items.keys.toList()[i],
                price: cart.items.values.toList()[i].price,
                quantity: cart.items.values.toList()[i].quantity,
                title: cart.items.values.toList()[i].title),
            itemCount: cart.items.length,
          ))
        ],
      ),
    );
  }
}

class OrderNow extends StatefulWidget {
  final Cart cart;

  const OrderNow({Key? key, required this.cart}) : super(key: key);
  @override
  State<StatefulWidget> createState() {
    return OrderNowState();
  }
}

class OrderNowState extends State<OrderNow> {
  var _isLoading = false;
  @override
  Widget build(BuildContext context) {
    return TextButton(
        onPressed: (widget.cart.toatAmount <= 0 || _isLoading)
            ? null
            : () async {
                setState(() {
                  _isLoading = true;
                });
                await Provider.of<Order>(context, listen: false).addOrder(
                    widget.cart.items.values.toList(), widget.cart.toatAmount);
                setState(() {
                  _isLoading = false;
                });
                widget.cart.clear();
              },
        child: _isLoading
            ? const CircularProgressIndicator()
            : const Text('Order Now'),
        style: TextButton.styleFrom(
            textStyle: TextStyle(color: Theme.of(context).primaryColor)));
  }
}
