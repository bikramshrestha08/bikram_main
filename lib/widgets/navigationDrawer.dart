import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:provider/provider.dart';

import '../models/routeArguments.dart';
import '../states/app.dart'; // Ensure this package is added to your pubspec.yaml

class HomeList extends StatelessWidget {
  final dynamic store; // Assuming 'store' is passed to this widget that contains 'logoImgUrl'
  const HomeList({super.key, required this.store});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    var appModel = Provider.of<AppModel>(context, listen: false);
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          DrawerHeader(
            decoration: BoxDecoration(
              color: Colors.red, // Keep consistent with your theme
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                CachedNetworkImage(
                  imageUrl: store.logoImgUrl!, // Ensure the URL is not null here
                  placeholder: (context, url) => Center(
                    child: CircularProgressIndicator(strokeWidth: 1.0),
                  ),
                  errorWidget: (context, url, error) => Icon(Icons.error),
                  width: 80,
                  height: 80,
                  fit: BoxFit.cover,
                ),
                // Text(
                //   'Delite Sushi',
                //   style: TextStyle(color: Colors.white, fontSize: 24),
                // ),
                Text(
                  store.getTranslatedName(
                      appModel.getLanguageCode())!,
                  style: Theme.of(context).textTheme.headline5,
                ),
              ],
            ),
          ),
          ListTile(
            leading: Icon(Icons.home),
            title: Text('Home'),
            onTap: () {
              Navigator.pushNamed(
                context,
                '/home',
                );
            },
          ),
          ListTile(
            leading: Icon(Icons.home),
            title: Text('Store Home'),
            onTap: () {
              Navigator.pushNamed(
                  context,
                  '/storeHome',
                  arguments: StoreHomeArguments(
                  store.uuid,
              ),);
            },
          ),
          ListTile(
            leading: Icon(Icons.receipt),
            title: Text('Order'),
            onTap: () {
              Navigator.pushNamed(
                context,
                '/order',
              );

            },
          ),
          // ListTile(
          //   leading: Icon(Icons.book_online),
          //   title: Text('Account'),
          //   onTap: () {
          //     String storeId = store.uuid;
          //     Navigator.pushNamed(
          //         context,
          //         '/membership_login/?storeid=$storeId',arguments: LoginArguments(false));
          //   },
          // ),
          // ListTile(
          //   leading: Icon(Icons.card_giftcard),
          //   title: Text('Vouchers'),
          //   onTap: () {
          //     Navigator.pop(context);
          //     Navigator.pushNamed(context, '/vouchersPage');
          //   },
          // ),
        ],
      ),
    );
  }
}
