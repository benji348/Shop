import 'dart:math';

import 'package:benji_shop_app/providers/orders.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class OrdersItem extends StatefulWidget {
  const OrdersItem({Key? key, required this.orderItem}) : super(key: key);
  final OrderItem orderItem;

  @override
  State<OrdersItem> createState() => _OrdersItemState();
}

class _OrdersItemState extends State<OrdersItem> {
  bool _expanded = false;
  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.all(10),
      child: Column(
        children: [
          ListTile(
            title: Text('\$${widget.orderItem.amount}'),
            subtitle: Text(
                DateFormat('dd/MM/yy hh:mm').format(widget.orderItem.dateTime)),
            trailing: IconButton(
              icon: Icon(_expanded ? Icons.expand_less : Icons.expand_more),
              onPressed: () {
                setState(() {
                  _expanded = !_expanded;
                });
              },
            ),
          ),
          if (_expanded)
            SizedBox(
                height: min(widget.orderItem.products.length * 20.0 + 100, 100),
                child: ListView(
                  children: widget.orderItem.products
                      .map((e) => Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  e.title,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14),
                                ),
                                Text('${e.quantity}x \$${e.price}',
                                    style: const TextStyle(
                                        fontSize: 14, color: Colors.grey))
                              ],
                            ),
                          ))
                      .toList(),
                ))
        ],
      ),
    );
  }
}
