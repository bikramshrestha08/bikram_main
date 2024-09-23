import 'package:eva_icons_flutter/eva_icons_flutter.dart';
import 'package:flutter/material.dart';
import 'package:linkeat/l10n/localizations.dart';
import '../../models/routeArguments.dart'; // Ensure this file exists and is correct
import '../../utils/SharedPreferences_util.dart';

class OrderDeclined extends StatefulWidget {
  static const routeName = '/orderDeclined';  // Corrected route name

  @override
  _OrderDeclinedState createState() => _OrderDeclinedState();  // Corrected state class name
}

class _OrderDeclinedState extends State<OrderDeclined> {
  String? storeId;

  @override
  void initState() {
    super.initState();
    _fetchStoreId();
  }

  Future<void> _fetchStoreId() async {
    storeId = await SharedPreferencesUtil.getStringItem('STORE_ID');
    // String? accessToken = await SharedPreferencesUtil.getStringItem('accessToken');
    // String? fullName = await SharedPreferencesUtil.getStringItem('fullName');
    // Moved the print statement here to ensure it prints the fetched value
    print(storeId);
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
        title: Text("Order Declined"),  // Corrected the title to match the class functionality
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
                  // Passing the storeId properly within StoreHomeArguments
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
