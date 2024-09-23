import 'dart:io';

import 'package:flutter/material.dart';
// import 'package:flutter/foundation.dart' show kDebugMode;

// import 'package:firebase_core/firebase_core.dart';
// import 'package:firebase_analytics/firebase_analytics.dart';
// import 'package:firebase_analytics/observer.dart';
// import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/services.dart';
import 'package:linkeat/routes/orderComplete/orderApproved.dart';
import 'package:linkeat/routes/orderComplete/orderCancelled.dart';
import 'package:linkeat/routes/orderComplete/orderDeclined.dart';
import 'package:linkeat/routes/orderList/orderList.dart';
import 'package:linkeat/routes/signIn/membershipLogin.dart';
import 'package:linkeat/routes/storeMenu/booking.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_strategy/url_strategy.dart';


import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:devicelocale/devicelocale.dart';

import 'package:linkeat/config.dart';
import 'package:linkeat/states/cart.dart';
import 'package:linkeat/states/app.dart';
import 'package:linkeat/l10n/localizations.dart';
import 'package:linkeat/utils/sputil.dart';
import 'package:linkeat/models/routeArguments.dart';
import 'package:linkeat/widgets/bottomNav.dart';
import 'package:linkeat/routes/store/storeHome.dart';
import 'package:linkeat/routes/storeMenu/menu.dart';
import 'package:linkeat/routes/product/product.dart';
import 'package:linkeat/routes/cart/cart.dart';
import 'package:linkeat/routes/checkout/delivery.dart';
import 'package:linkeat/routes/checkout/takeaway.dart';
import 'package:linkeat/routes/payment/payment.dart';
import 'package:linkeat/routes/orderComplete/orderCompete.dart';
import 'package:linkeat/routes/orderDetail/orderDetail.dart';
import 'package:linkeat/routes/signIn/login.dart';
import 'package:linkeat/routes/signIn/forgotPassword.dart';

class MyHttpOverrides extends HttpOverrides {
  // avoid error: 'Connection closed before full header was received' when fetching network images
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)..maxConnectionsPerHost = 5;
  }
}

void main() {
  setPathUrlStrategy();
  const bool isProduction = bool.fromEnvironment('dart.vm.product');
  //const bool isProduction = true;
  if (isProduction) {
    Constants.setEnvironment(Environment.PROD);
  } else {
    Constants.setEnvironment(Environment.DEV);
  }

  HttpOverrides.global = MyHttpOverrides();
  WidgetsFlutterBinding.ensureInitialized();
  realRunApp();
}

void realRunApp() async {
  // Initialize Firebase before accessing any instances
  // await Firebase.initializeApp();

  // // Disable Crashlytics in debug mode
  // FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(!kDebugMode);

  // // Pass all uncaught errors from the framework to Crashlytics.
  // FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterError;

  bool success = await SpUtil.getInstance();
  String? systemLocale = await Devicelocale.currentLocale;
  print("init-" + success.toString());
  runApp(MyApp(systemLocale: systemLocale));
}

class MyApp extends StatelessWidget {
  final String? systemLocale;

  MyApp({this.systemLocale});
  // static FirebaseAnalytics analytics = FirebaseAnalytics.instance;
  // static FirebaseAnalyticsObserver observer =
  //     FirebaseAnalyticsObserver(analytics: analytics);

  @override
  Widget build(BuildContext context) {
    Locale locale = Locale('en', '');
    if (systemLocale!.contains('zh', 0))
      locale = Locale.fromSubtags(languageCode: 'zh');
    String? persistedLocaleCode = SpUtil.preferences.getString('locale');
    if (persistedLocaleCode == 'zh')
      locale = Locale.fromSubtags(languageCode: 'zh');
    if (persistedLocaleCode == 'en') locale = Locale('en', '');
    final textTheme = Theme.of(context).textTheme;

    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => CartModel()),
        ChangeNotifierProvider(create: (context) => AppModel(locale: locale)),
      ],
      child: Consumer<AppModel>(builder: (context, appModel, child) {
        SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
          statusBarColor: Colors.black,
//            statusBarBrightness: Brightness.light, // ios
        ));

        return MaterialApp(
          // remove debug banner
          debugShowCheckedModeBanner: false,
          // for route with arguments
          locale: appModel.locale,
          localizationsDelegates: [
            const AppLocalizationsDelegate(),
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: [
            const Locale('en', ''),
            const Locale.fromSubtags(languageCode: 'zh'),
          ],
          onGenerateRoute: (settings) {
            if (settings.name == '/storeHome') {
              final StoreHomeArguments? args =
                  settings.arguments as StoreHomeArguments?;
              return MaterialPageRoute(
                builder: (context) {
                  return StoreHome(uuid: args!.uuid);
                },
              );
            }
            if (settings.name == '/storeMenu') {
              final StoreMenuArguments? args =
                  settings.arguments as StoreMenuArguments?;
              return MaterialPageRoute(
                builder: (context) {
                  return StoreMenu(uuid: args!.uuid);
                },
              );
            }
            if (settings.name == '/booking') {
              final BookingArguments? args =
              settings.arguments as BookingArguments?;
              return MaterialPageRoute(
                builder: (context) {
                  return Booking(uuid: args!.uuid);
                },
              );
            }

            if (settings.name == '/productDetail') {
              final ProductDetailArguments? args =
                  settings.arguments as ProductDetailArguments?;
              return MaterialPageRoute(
                builder: (context) {
                  return ProductDetail(
                    product: args!.product,
                    storeOpened: args.storeOpened,
                  );
                },
              );
            }
            if (settings.name == '/payment') {
              final OrderPaymentArguments? args =
                  settings.arguments as OrderPaymentArguments?;
              return MaterialPageRoute(
                builder: (context) {
                  return Payment(
                    orderId: args!.orderId,
                  );
                },
              );
            }
            if (settings.name == '/orderDetail') {
              final OrderDetailArguments? args =
                  settings.arguments as OrderDetailArguments?;
              return MaterialPageRoute(
                builder: (context) {
                  return OrderDetail(
                    orderId: args!.orderId,
                  );
                },
              );
            }
            if (settings.name == '/login') {
              final LoginArguments? args =
                  settings.arguments as LoginArguments?;
              var resetToHome = args?.resetToHome ?? false;
              return MaterialPageRoute(
                builder: (context) {
                  return Login(resetToHome: resetToHome);
                },
              );
            }
            if (settings.name?.startsWith('/membership_login') ?? false) {
              final args = settings.arguments as LoginArguments?;
              final resetToHome = args?.resetToHome ?? true;

              // Parse the URI to extract query parameters
              final uri = Uri.tryParse(settings.name!);
              final storeId = uri?.queryParameters['storeid']??'123';
              print(storeId);

              return MaterialPageRoute(
                builder: (context) => MembershipLogin(
                  resetToHome: resetToHome,
                  storeId: storeId,
                ),
              );
            }
            if (settings.name?.startsWith('/orderCancelled') ?? false) {
              return MaterialPageRoute(
                builder: (context) => OrderCancelled(),
              );
            }
            if (settings.name?.startsWith('/orderApproved') ?? false) {
              return MaterialPageRoute(
                builder: (context) => OrderApproved(),
              );
            }
            if (settings.name?.startsWith('/orderDeclined') ?? false) {
              return MaterialPageRoute(
                builder: (context) => OrderDeclined(),
              );
            }
            assert(false, 'Need to implement ${settings.name}');
            return null;
          },
          theme: ThemeData(
            primaryColor: Colors.black,
            // accentColor: Color(0xffeb5050),
            dividerColor: Colors.black12,
            colorScheme: ColorScheme(
              primary: Color(0xffeb5050),
              onPrimary: Colors.white,
              // primaryVariant: Colors.orange,
              background: Colors.white,
              onBackground: Colors.black,
              secondary: Colors.black,
              onSecondary: Colors.black,
              // secondaryVariant: Colors.deepOrange,
              error: Colors.black,
              onError: Colors.white,
              surface: Colors.white,
              onSurface: Colors.black,
              brightness: Brightness.light,
            ),
            textTheme: GoogleFonts.poppinsTextTheme(textTheme).copyWith(
                headline5: GoogleFonts.poppinsTextTheme()
                    .headline5!
                    .copyWith(fontSize: 20)),
//            textTheme: TextTheme(
//              headline5: TextStyle(fontSize: 72.0,  fontWeight: FontWeight.bold),
//              headline6: TextStyle(fontSize: 24.0),
//              subtitle2: TextStyle(fontSize: 16.0),
//              caption: TextStyle(fontSize: 12.0),
//              bodyText2: TextStyle(
//                fontSize: 14.0,
//              ),
//            ),
//        primarySwatch: white,
          ),
          home: BottomNavigation(),
          // navigatorObservers: [
          //   FirebaseAnalyticsObserver(analytics: analytics),
          // ],
          routes: {
            '/home': (context) => BottomNavigation(),
//            '/storeMenu': (context) => StoreMenu(),
            '/cart': (context) => Cart(),
            '/checkoutDelivery': (context) => DeliveryForm(),
            '/checkoutTakeaway': (context) => TakeAwayForm(),
            '/orderComplete': (context) => OrderComplete(),
            '/orderApproved': (context) => OrderApproved(),
            '/orderCancelled': (context) => OrderCancelled(),
            '/orderDeclined': (context) => OrderDeclined(),
            '/order': (context) => OrderList(),
           '/login': (context) => Login(),
            '/membershipLogin': (context) => Placeholder(),
            '/forgotPassword': (context) => ForgotPassword(),
          },
        );
      }),
    );
  }
}
