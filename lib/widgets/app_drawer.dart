import 'package:benji_shop_app/providers/auth.dart';
import 'package:benji_shop_app/screens/orders_screen_bar.dart';
import 'package:benji_shop_app/screens/splash_screen.dart';
import 'package:benji_shop_app/screens/users_products_bar_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // final  username = Provider.of<Auth>(context,listen:false);
    return Drawer(
      child: Column(
        children: [
          AppBar(
            title: Text('Hello '),
            automaticallyImplyLeading: false,
          ),
          Divider(),
          ListTile(
            leading: Icon(Icons.shop),
            title: Text('Shop'),
            onTap: () {
              Navigator.of(context).pushReplacementNamed('/');
            },
          ),
          Divider(),
          ListTile(
            leading: const Icon(
              Icons.credit_card,
            ),
            title: const Text('Orders'),
            onTap: () {
              Navigator.of(context).pushReplacementNamed(OrdersScreen.routName);
            },
          ),
          const Divider(),
          ListTile(
            leading: Icon(Icons.edit),
            title: const Text('Manage Product'),
            onTap: () {
              Navigator.of(context)
                  .pushReplacementNamed(UserProductsScreen.routeName);
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.exit_to_app),
            title: const Text('Log out'),
            onTap: () {
              Navigator.of(context).pop();
              Navigator.of(context).pushReplacementNamed('/');
              Provider.of<Auth>(context, listen: false).logout();
            },
          )
        ],
      ),
    );
  }
}
