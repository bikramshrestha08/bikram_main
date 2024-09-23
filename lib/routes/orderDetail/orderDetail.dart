import 'dart:async';

import 'package:flutter/material.dart';

import 'package:linkeat/models/order.dart';
import 'package:linkeat/routes/orderList/orderCard.dart';
import 'package:linkeat/service/api.dart';

class OrderDetail extends StatefulWidget {
  static const routeName = '/orderDetail';
  final String orderId;

  OrderDetail({
    Key? key,
    required this.orderId,
  }) : super(key: key);

  @override
  _OrderDetailState createState() => _OrderDetailState();
}

class _OrderDetailState extends State<OrderDetail> {
  Future<Order>? futureOrder;

  @override
  void initState() {
    super.initState();
    futureOrder = fetchOrderById(context, widget.orderId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
//        automaticallyImplyLeading: false,
        backgroundColor: Colors.white,
        // textTheme: TextTheme(
        //     titleMedium: TextStyle(
        //       color: Colors.black87,
        //       fontSize: 20.0,
        //     )),
        iconTheme: IconThemeData(
          color: Colors.black87,
        ),
        title: Text('Order Detail'),
      ),
      body: FutureBuilder<Order>(
        future: futureOrder,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            var order = snapshot.data!;
            return ListView(
              children: <Widget>[
                Hero(
                  tag: order.uuid!,
                  child: OrderCard(order: order),
                ),
              ],
            );
          } else if (snapshot.hasError) {
            return Text("${snapshot.error}");
          }
          // By default, show a loading spinner.
          return Center(
            widthFactor: 9.5,
            heightFactor: 9.5,
            child: SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                backgroundColor: Colors.white,
                strokeWidth: 1.0,
              ),
            ),
          );
        },
      ),
    );
  }
}
