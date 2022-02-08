import 'package:benji_shop_app/providers/products_provider.dart';
import 'package:benji_shop_app/screens/edit_product_screen.dart';
import 'package:benji_shop_app/widgets/app_drawer.dart';
import 'package:benji_shop_app/widgets/user_product_item.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class UserProductsScreen extends StatelessWidget {
  const UserProductsScreen({Key? key}) : super(key: key);
  static const routeName = '/user_products_screen';
  Future<void> _refreshProducts(BuildContext context) async {
    await Provider.of<ProductsProvider>(context, listen: false)
        .httpFetchSetProducts(true);
  }

  @override
  Widget build(BuildContext context) {
    // final product = Provider.of<ProductsProvider>(context);

    return Scaffold(
        appBar: AppBar(
          title: Text('Your Products'),
          actions: [
            IconButton(
                onPressed: () {
                  Navigator.of(context).pushNamed(EditProductScreen.routeName);
                },
                icon: Icon(Icons.add))
          ],
        ),
        drawer: AppDrawer(),
        body: FutureBuilder(
          future: _refreshProducts(context),
          builder: (ctx, sapshot) =>
              sapshot.connectionState == ConnectionState.waiting
                  ? Center(
                      child: CircularProgressIndicator(),
                    )
                  : RefreshIndicator(
                      onRefresh: () => _refreshProducts(context),
                      child: Consumer<ProductsProvider>(
                        builder: (ctx, product, _) => Padding(
                          padding: const EdgeInsets.all(5),
                          child: ListView.builder(
                            itemBuilder: (ctx, i) {
                              return UserProductItem(
                                  id: product.items[i].id,
                                  title: product.items[i].title,
                                  imageUrl: product.items[i].imageUrl);
                            },
                            itemCount: product.items.length,
                          ),
                        ),
                      ),
                    ),
        ));
  }
}
