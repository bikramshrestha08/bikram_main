import 'package:eva_icons_flutter/eva_icons_flutter.dart';
import 'package:flutter/material.dart';
import 'package:linkeat/l10n/localizations.dart';
import '../../models/routeArguments.dart';
import '../../utils/SharedPreferences_util.dart';


class OrderCancelled extends StatefulWidget {
  static const routeName = '/orderCancelled';

  @override
  _OrderCancelledState createState() => _OrderCancelledState();
}

class _OrderCancelledState extends State<OrderCancelled> {
  String? storeId;

  @override
  void initState() {
    super.initState();
    _fetchStoreId();
    print(storeId);
  }

  Future<void> _fetchStoreId() async {
    storeId = await SharedPreferencesUtil.getStringItem('STORE_ID');
    // String? accessToken = await SharedPreferencesUtil.getStringItem('accessToken');
    // String? fullName = await SharedPreferencesUtil.getStringItem('fullName');
    if (mounted) {
      setState(() {});  // This will trigger a rebuild of the widget
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.white,
        iconTheme: IconThemeData(color: Colors.black87),
        title: Text("Order Cancelled"),
        centerTitle: true,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Padding(
              padding: EdgeInsets.all(50.0),
              child: Icon(
                EvaIcons.checkmarkCircle2Outline,
                size: 70.0,
                color: colorScheme.primary,
              ),
            ),
            SizedBox(
              width: 150,
              height: 45,
              child: OutlinedButton(

                onPressed: () {
                  Navigator.pushNamed(
                    context,
                    '/storeHome',
                    arguments: StoreHomeArguments(storeId),
                  );
                },
                child: Text(
                  AppLocalizations.of(context)!.backToHome!,
                  style: textTheme.button,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

