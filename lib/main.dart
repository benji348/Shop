import 'dart:ui';

import 'package:benji_shop_app/providers/auth.dart';
import 'package:benji_shop_app/providers/cart.dart';
import 'package:benji_shop_app/providers/orders.dart';
import 'package:benji_shop_app/providers/product.dart';
import 'package:benji_shop_app/providers/products_provider.dart';
import 'package:benji_shop_app/screens/auth_scren.dart';
import 'package:benji_shop_app/screens/cart_screen.dart';
import 'package:benji_shop_app/screens/edit_product_screen.dart';
import 'package:benji_shop_app/screens/orders_screen_bar.dart';
import 'package:benji_shop_app/screens/product_detail_screen.dart';
import 'package:benji_shop_app/screens/products_overview_screen.dart';
import 'package:benji_shop_app/screens/splash_screen.dart';
import 'package:benji_shop_app/screens/users_products_bar_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyShop());
}

class MyShop extends StatelessWidget {
  final String dummyUserId = '';
  final String dummyData = '';
  List<Product> dummyProductList = [];
  List<OrderItem> dummyOrderList = [];

  MyShop({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (ctx) => Auth()),
          ChangeNotifierProxyProvider<Auth, ProductsProvider>(
              update: (ctx, auth, previousProductsProviderState) =>
                  ProductsProvider(auth.token, auth.userId,
                      previousProductsProviderState!.items),
              create: (ctx) =>
                  ProductsProvider(dummyData, dummyUserId, dummyProductList)),
          ChangeNotifierProvider(create: (ctx) => Cart()),
          ChangeNotifierProxyProvider<Auth, Order>(
            update: (ctx, authOrder, previousState) =>
                Order(authOrder.token, authOrder.userId, previousState!.orders),
            create: (ctx) => Order(dummyData, dummyUserId, dummyOrderList),
          )
        ],
        child: Consumer<Auth>(
          builder: (ctx, auth, _) => MaterialApp(
            title: 'Benji Shop',
            theme: ThemeData(
              primarySwatch: Colors.blue,
              secondaryHeaderColor: Colors.red,
              // textTheme: ThemeData.light().copyWith()
            ),
            home: auth.isAuth
                ? const ProductsOverviewScreen()
                : FutureBuilder(
                    future: auth.tryAutoLogin(),
                    builder: (ctx, authResutlSnapshot) =>
                        authResutlSnapshot.connectionState ==
                                ConnectionState.waiting
                            ? SplashScreen()
                            : const AuthScreen(),
                  ),
            routes: {
              ProductDetailScreen.routeName: (ctx) =>
                  const ProductDetailScreen(),
              CartScreen.routeName: (ctx) => const CartScreen(),
              OrdersScreen.routName: (ctx) => const OrdersScreen(),
              UserProductsScreen.routeName: (ctx) => const UserProductsScreen(),
              EditProductScreen.routeName: (ctx) => const EditProductScreen(),
            },
          ),
        ));
  }
}
