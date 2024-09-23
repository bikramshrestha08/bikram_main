import 'dart:io';
import 'package:linkeat/states/app.dart';
import 'package:double_back_to_close_app/double_back_to_close_app.dart';
import 'package:eva_icons_flutter/eva_icons_flutter.dart';
// import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:another_flushbar/flushbar.dart';
import 'package:flutter/material.dart';

import 'package:linkeat/l10n/localizations.dart';
import 'package:linkeat/routes/home/home.dart';
import 'package:linkeat/routes/search/search.dart';
import 'package:linkeat/routes/orderList/orderList.dart';
import 'package:linkeat/routes/account/account.dart';
import 'package:flutter_ringtone_player/flutter_ringtone_player.dart';
import 'package:linkeat/service/request.dart';
import 'package:linkeat/utils/sputil.dart';
import 'package:provider/provider.dart';

AndroidNotificationChannel? channel;
FlutterLocalNotificationsPlugin? flutterLocalNotificationsPlugin;

class BottomNavigation extends StatefulWidget {
  const BottomNavigation({Key? key}) : super(key: key);

  @override
  _BottomNavigationState createState() => _BottomNavigationState();
}

class _BottomNavigationState extends State<BottomNavigation> {
  int _currentIndex = 0;
  final _tabs = [
    Home(),
    Search(),
    OrderList(),
    Account(),
  ];

  // Future<void> initFirebaseMessaging() async {
  //   var app = Provider.of<AppModel>(context, listen: false);

  //   await FirebaseMessaging.instance
  //       .setForegroundNotificationPresentationOptions(
  //     alert: true,
  //     badge: true,
  //     sound: true,
  //   );

  //   // Register callback functions
  //   FirebaseMessaging.onMessage.listen((RemoteMessage message) {
  //     print("onMessage: $message");
  //     FlutterRingtonePlayer.playNotification();

  //     Flushbar(
  //       title: message.notification!.title,
  //       message: message.notification!.body ?? message.notification!.title,
  //       duration: Duration(seconds: 3),
  //     )..show(context);
  //   });

  //   // FirebaseMessaging.onBackgroundMessage(myBackgroundMessageHandler);

  //   Stream<String> fcmStream = FirebaseMessaging.instance.onTokenRefresh;
  //   fcmStream.listen((token) {
  //     // _subscribeFCMToken(token);
  //     app.updateFcmToken(token, context);
  //   });

  //   // update user token
  //   String? accessToken = SpUtil.preferences.getString('accessToken');
  //   if (accessToken != null) {
  //     app.updateAccessToken(accessToken, context);
  //   }

  //   print("FCM token:" + (await FirebaseMessaging.instance.getToken())!);
  // }

  // Future<void> _subscribeFCMToken(String token) async {
  //   String userToken = SpUtil.preferences.getString('accessToken');
  //   print("userToken: $userToken");
  //   if (token != null && userToken != null) {
  //     print("FCMtoken: $token");
  //     await Services.asyncRequest(
  //         'POST', '/store/v3/notification/subscription', context,
  //         payload: {
  //           'token': token,
  //         });
  //   }
  // }

  @override
  void initState() {
    super.initState();
    // initFirebaseMessaging();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      body: DoubleBackToCloseApp(
        snackBar: SnackBar(
          content: Text(AppLocalizations.of(context)!.tapBackAgainForExit!),
        ),
        child: _tabs[_currentIndex],
      ),
      bottomNavigationBar: BottomNavigationBar(
        showUnselectedLabels: true,
        items: [
          BottomNavigationBarItem(
              icon: const Icon(EvaIcons.homeOutline),
              label: AppLocalizations.of(context)!.home),
          BottomNavigationBarItem(
              icon: const Icon(EvaIcons.searchOutline),
              label: AppLocalizations.of(context)!.search),
          BottomNavigationBarItem(
              icon: const Icon(EvaIcons.shoppingBagOutline),
              label: AppLocalizations.of(context)!.order),
          BottomNavigationBarItem(
              icon: const Icon(EvaIcons.personOutline),
              label: AppLocalizations.of(context)!.account),
        ],
        currentIndex: _currentIndex,
        type: BottomNavigationBarType.fixed,
        selectedFontSize: textTheme.caption!.fontSize!,
        unselectedFontSize: textTheme.caption!.fontSize!,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        selectedItemColor: colorScheme.onBackground,
        unselectedItemColor: colorScheme.onBackground.withOpacity(0.38),
        backgroundColor: colorScheme.background,
      ),
    );
  }
}

// Future<void> myBackgroundMessageHandler(RemoteMessage message) {
  
//   if (message.data != null) {
//     // Handle data message
//     final dynamic data = message.data;
//   }

//   if (message.notification != null) {
//     // Handle notification message
//     final dynamic notification = message.notification;
//   }
// }
