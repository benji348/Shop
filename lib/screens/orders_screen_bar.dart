import 'package:benji_shop_app/providers/orders.dart';
import 'package:benji_shop_app/widgets/app_drawer.dart';
import 'package:benji_shop_app/widgets/orders_item.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class OrdersScreen extends StatefulWidget {
  const OrdersScreen({Key? key}) : super(key: key);
  static const routName = '/orsers_screen';

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  var _isLoading = false;
  @override
  void initState() {
    setState(() {
      _isLoading = true;
    });
    Provider.of<Order>(context, listen: false)
        .httpFetchSetOrders()
        .then((value) {
      setState(() {
        _isLoading = false;
      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final ordersData = Provider.of<Order>(context);
    return Scaffold(
        appBar: AppBar(
          title: const Text('Your orders'),
        ),
        drawer: const AppDrawer(),
        body: _isLoading
            ? const Center(
                child: CircularProgressIndicator(),
              )
            : ListView.builder(
                itemBuilder: (ctx, i) =>
                    OrdersItem(orderItem: ordersData.orders[i]),
                itemCount: ordersData.orders.length,
              ));
  }
}
