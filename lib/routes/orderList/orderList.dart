import 'dart:convert';

import 'package:linkeat/widgets/loadMoreDelegate.dart';
import 'package:flutter/material.dart';

import 'package:loadmore/loadmore.dart';

import 'package:linkeat/models/order.dart';
import 'package:linkeat/l10n/localizations.dart';
import 'package:linkeat/service/request.dart';
import 'package:linkeat/utils/sputil.dart';
import 'package:linkeat/routes/orderList/orderCard.dart';
import 'package:linkeat/routes/signIn/login.dart';

class OrderList extends StatefulWidget {
  static const routeName = '/orderList';

  OrderList({Key? key}) : super(key: key);

  _OrderListState createState() => _OrderListState();
}

class _OrderListState extends State<OrderList> {
  List<Order>? orders;
  late int pageIdx;
  int? ordersTotal;

  ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    pageIdx = -1;
    ordersTotal = 0;
    _loadMore();
  }

  Future<bool> _loadMore() async {
    String? token = SpUtil.preferences.getString('accessToken');
    if (token == null) {
      return true;
    }
    final dynamic response = await Services.asyncRequest(
        'GET', '/store/my/orders?pageIdx=${pageIdx + 1}&pageSize=20', context);
    var data = json.decode(response.toString());
    List<Order>? newOrders =
        data['records'].map<Order>((json) => Order.fromJson(json)).toList();

    setState(() {
      ordersTotal = data['totalCount'];
      pageIdx = pageIdx + 1;
      if (orders == null) {
        orders = newOrders;
      } else {
        orders!.addAll(newOrders!);
      }
    });
    return true;
  }

  Future<void> _refresh() async {
    String? token = SpUtil.preferences.getString('accessToken');
    if (token == null) {
      return;
    }
    orders!.clear();
    pageIdx = -1;
    final dynamic response = await Services.asyncRequest(
        'GET', '/store/my/orders?pageIdx=${pageIdx + 1}&pageSize=20', context);
    var data = json.decode(response.toString());
    List<Order>? newOrders =
        data['records'].map<Order>((json) => Order.fromJson(json)).toList();

    setState(() {
      pageIdx = pageIdx + 1;
      if (orders == null) {
        orders = newOrders;
      } else {
        orders!.addAll(newOrders!);
      }
    });
    return;
  }

  void scrollToTop() {
    _scrollController.animateTo(
      0.0,
      curve: Curves.easeOut,
      duration: const Duration(milliseconds: 300),
    );
  }

  @override
  Widget build(BuildContext context) {
    String? token = SpUtil.preferences.getString('accessToken');
    final textTheme = Theme.of(context).textTheme;
    if (token == null) {
      return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          automaticallyImplyLeading: false,
          title: Text(
            AppLocalizations.of(context)!.myOrders!,
            style: textTheme.headline5,
          ),
          centerTitle: true,
          backgroundColor: Colors.white,
          // brightness: Theme.of(context).platform == TargetPlatform.android
          //     ? Brightness.dark
          //     : Brightness.light),
        ),
        body: Center(
          child: SizedBox(
            width: 150,
            height: 45,
            child: OutlinedButton(
              // highlightedBorderColor: Colors.grey[400],
              // highlightColor: Colors.grey[200],
              // shape: RoundedRectangleBorder(
              //     borderRadius: BorderRadius.circular(30.0)),
              onPressed: () {
                Navigator.of(context)
                    .push(new MaterialPageRoute<String>(
                        builder: (context) => Login()))
                    .then((String? value) {
                  _loadMore();
                });
              },
              child: Text(
                AppLocalizations.of(context)!.login!,
                style: textTheme.button,
              ),
            ),
          ),
        ),
      );
    }
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text(AppLocalizations.of(context)!.myOrders!,
            style: textTheme.headline5),
        centerTitle: true,
        backgroundColor: Colors.white,
        // textTheme: TextTheme(
        //     headline6: TextStyle(
        //   color: Colors.black87,
        //   fontSize: 20.0,
        // )),
      ),
      body: orders != null
          ? RefreshIndicator(
              child: LoadMore(
                isFinish: orders!.length >= ordersTotal!,
                onLoadMore: _loadMore,
                child: orders!.length > 0
                    ? ListView.builder(
                        controller: _scrollController,
                        padding: const EdgeInsets.all(8),
                        itemCount: orders!.length,
                        itemBuilder: (BuildContext context, int index) {
                          return Hero(
                            tag: orders![index].uuid!,
                            child: OrderCard(
                                order: orders![index], onRefresh: _refresh),
                          );
                        })
                    : Text(
                        AppLocalizations.of(context)!.noData!.toUpperCase(),
                        style: textTheme.caption,
                      ),
                whenEmptyLoad: false,
                delegate: CustomizedLoadMoreDelegate(context, scrollToTop),
                textBuilder: DefaultLoadMoreTextBuilder.english,
              ),
              onRefresh: _refresh,
            )
          : Center(
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  backgroundColor: Colors.white,
                  strokeWidth: 1.0,
                ),
              ),
            ),
    );
  }
}
