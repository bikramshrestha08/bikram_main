import 'package:linkeat/models/routeArguments.dart';
import 'package:eva_icons_flutter/eva_icons_flutter.dart';
import 'package:flutter/material.dart';
import 'package:linkeat/routes/store/qrviewExample.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:linkeat/widgets/navigationDrawer.dart';


import 'package:cached_network_image/cached_network_image.dart';
import 'package:provider/provider.dart';

import 'package:linkeat/models/store.dart';
import 'package:linkeat/models/order.dart';
import 'package:linkeat/states/cart.dart';
import 'package:linkeat/states/app.dart';
import 'package:linkeat/l10n/localizations.dart';
import 'package:linkeat/routes/store/slider.dart';

class StoreHome extends StatefulWidget {
  static const routeName = '/storeHome';
  var store;
  final String? uuid;

  StoreHome({
    Key? key,
    required this.uuid,
  }) : super(key: key);

  @override
  _StoreHomeState createState() => _StoreHomeState();
}

class _StoreHomeState extends State<StoreHome> {
  Future<StoreDetail?>? futureStoreDetail;

  @override
  void initState() {
    super.initState();
    var appModel = Provider.of<AppModel>(context, listen: false);
    var cartModel = Provider.of<CartModel>(context, listen: false);
    futureStoreDetail = cartModel.fetchStoreDetail(
        widget.uuid, appModel.getLanguageCode(), context);
  }

  _launchURL(String? phoneNumber) async {
    var url = 'tel:$phoneNumber';
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  _openStoreMap(String? mapContent) {
    Navigator.push<void>(
      context,
      MaterialPageRoute(
        builder: (context) => _FullScreenDialogStoreMap(
          mapContent: mapContent,
        ),
        fullscreenDialog: true,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    var appModel = Provider.of<AppModel>(context, listen: false);
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        // Even if the AppBar is invisible, it needs to enable drawer icon if used.
        leading: Builder(
          builder: (context) => IconButton(
            icon: Icon(Icons.menu),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
        backgroundColor: Colors.transparent, // Ensuring the AppBar is invisible
        elevation: 0.0, // No shadow
      ),
      // appBar: PreferredSize(
      //     preferredSize: Size.fromHeight(0.0), // here the desired height
      //     child: AppBar()),
      // floatingActionButton: Padding(
      //   padding: const EdgeInsets.only(top: 20.0),
      //   child: FloatingActionButton(
      //       heroTag: 'back',
      //       onPressed: () => print("FloatingActionButton"),
      //       child: IconButton(
      //           icon: Icon(EvaIcons.arrowIosBackOutline),
      //           onPressed: () => Navigator.pop(context)),
      //       foregroundColor: Colors.black87,
      //       backgroundColor: Colors.white,
      //       elevation: 2.0,
      //       mini: true,
      //       // highlightElevation: 12.0,
      //       shape: CircleBorder()),
      // ),
      // floatingActionButtonLocation: FloatingActionButtonLocation.startTop,

      drawer: FutureBuilder<StoreDetail?>(
        future: futureStoreDetail,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            var store = snapshot.data!;
            return HomeList( store: store
            );
          } else if (snapshot.hasError) {
            return Text("${snapshot.error}");
          }
          // By default, show a loading spinner.
//          return CircularProgressIndicator(
//            backgroundColor: Colors.black12,
//            strokeWidth: 2.0,
//          );
          return SizedBox.shrink();
        },
      ),
      // drawer: HomeList(store: widget.store),
      body: Scrollbar(
        child: ListView(
          children: <Widget>[
            FutureBuilder<StoreDetail?>(
              future: futureStoreDetail,
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  var store = snapshot.data!;
                  return Column(
                    children: <Widget>[
                      Container(
                          child: store.isOpened()
                              ? StoreSlider(
                                  bannerUrl: store.bannerUrl,
                                )
                              : Stack(
                                  children: <Widget>[
                                    StoreSlider(
                                      bannerUrl: store.bannerUrl,
                                    ),
                                    Container(
                                      color: Color.fromRGBO(0, 0, 0, 0.5),
                                      height: 190,
                                      width: MediaQuery.of(context).size.width,
                                      child: Center(
                                          child: Text(
                                        AppLocalizations.of(context)!
                                            .storeClosed!,
                                        style: textTheme.subtitle1!
                                            .copyWith(color: Colors.white),
                                      )),
                                    ),
                                  ],
                                )),
                      Padding(
                        padding: EdgeInsets.fromLTRB(25.0, 25.0, 25.0, 0),
                        child: Column(
                          children: <Widget>[
                            CachedNetworkImage(
                              imageUrl: store.logoImgUrl!,
                              placeholder: (context, url) => Center(
                                child: SizedBox(
                                  height: 20.0,
                                  width: 20.0,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 1.0,
                                  ),
                                ),
                              ),
                              errorWidget: (context, url, error) =>
                                  Icon(Icons.error),
                              width: 80,
                              height: 80,
                              fit: BoxFit.cover,
                            ),
                            Text(
                              store.getTranslatedName(
                                  appModel.getLanguageCode())!,
                              style: Theme.of(context).textTheme.headline5,
                            ),
                            SizedBox(
                              child: store.tags!.length > 0
                                  ? Padding(
                                      padding: EdgeInsets.only(top: 5.0),
                                      child: Container(
                                        padding: EdgeInsets.only(
                                            left: 10,
                                            right: 10,
                                            top: 3,
                                            bottom: 3),
                                        decoration: BoxDecoration(
                                          border: Border.all(
                                            color: Colors.grey[100]!,
                                            width: 2,
                                          ),
                                          borderRadius:
                                              BorderRadius.circular(12),
                                        ),
                                        child: Text(store.tags![0],
                                            style: textTheme.caption!
                                                .copyWith(fontSize: 10)),
                                      ),
                                    )
                                  : SizedBox.shrink(),
                            ),
                            (store.getTranslatedDescription(
                                            appModel.getLanguageCode()) !=
                                        null &&
                                    store
                                        .getTranslatedDescription(
                                            appModel.getLanguageCode())!
                                        .isNotEmpty)
                                ? Padding(
                                    padding: EdgeInsets.only(top: 15.0),
                                    child: Text(
                                      store.getTranslatedDescription(
                                          appModel.getLanguageCode())!,
                                      style:
                                          Theme.of(context).textTheme.bodyText2,
                                      textAlign: TextAlign.left,
                                    ),
                                  )
                                : SizedBox.shrink(),
                            SizedBox(
                              height: 10,
                            ),
                            Divider(),
                            InkWell(
                              onTap: () {
                                _openStoreMap(store.mapContent);
                              },
                              child: Container(
                                height: 34,
                                child: Row(
                                  children: [
                                    Icon(
                                      EvaIcons.navigation2Outline,
                                      size: 20.0,
                                      color: Colors.black38,
                                    ),
                                    SizedBox(
                                      width: 15,
                                    ),
                                    Expanded(
                                        child: Text(
                                      store.address!.address1! +
                                          ', ' +
                                          store.address!.city! +
                                          ', ' +
                                          store.address!.state! +
                                          ',' +
                                          store.address!.postCode!,
                                      style: Theme.of(context)
                                          .textTheme
                                          .caption!
                                          .copyWith(fontSize: 13),
                                    ))
                                  ],
                                ),
                              ),
                            ),
                            Divider(),
                            InkWell(
                              onTap: () {
                                _launchURL(store.phone);
                              },
                              child: Container(
                                height: 34,
                                child: Row(
                                  children: [
                                    Icon(
                                      EvaIcons.phoneOutline,
                                      size: 20.0,
                                      color: Colors.black38,
                                    ),
                                    SizedBox(
                                      width: 15,
                                    ),
                                    Text(
                                      store.phone!,
                                      style: Theme.of(context)
                                          .textTheme
                                          .caption!
                                          .copyWith(fontSize: 13),
                                    )
                                  ],
                                ),
                              ),
                            ),
                            Divider(),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(top: 5.0),
                                  child: Icon(
                                    EvaIcons.clockOutline,
                                    size: 20.0,
                                    color: Colors.black38,
                                  ),
                                ),
                                SizedBox(
                                  width: 15,
                                ),
                                Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    for (final day in store.businessHour!)
                                      for (final openingHour
                                          in day.openingHours!)
                                        Padding(
                                          padding: EdgeInsets.symmetric(
                                              vertical: 4.0),
                                          child: Text(
                                            DayOfWeekMapping[
                                                    day.dayOfTheWeek]! +
                                                ': ' +
                                                openingHour.toString(),
                                            style: Theme.of(context)
                                                .textTheme
                                                .caption!
                                                .copyWith(fontSize: 13),
                                          ),
                                        )
                                  ],
                                )
                              ],
                            ),
                          ],
                        ),
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
          ],
        ),
      ),
      bottomNavigationBar: FutureBuilder<StoreDetail?>(
        future: futureStoreDetail,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            var store = snapshot.data!;
            return _BottomAppBar(
              acceptDelivery: store.storeConfig!.acceptDelivery,
              acceptTakeaway: store.storeConfig!.acceptTakeaway,
              context: context,
              storeId: store.uuid,
            );
          } else if (snapshot.hasError) {
            return Text("${snapshot.error}");
          }
          // By default, show a loading spinner.
//          return CircularProgressIndicator(
//            backgroundColor: Colors.black12,
//            strokeWidth: 2.0,
//          );
          return SizedBox.shrink();
        },
      ),
    );
  }
}

class _BottomAppBar extends StatelessWidget {
  const _BottomAppBar({
    this.fabLocation,
    this.shape,
    this.acceptDelivery,
    this.acceptTakeaway,
    this.context,
    this.storeId,
  });

  final FloatingActionButtonLocation? fabLocation;
  final NotchedShape? shape;
  final bool? acceptDelivery;
  final bool? acceptTakeaway;
  final BuildContext? context;
  final String? storeId;

//  static final centerLocations = <FloatingActionButtonLocation>[
//    FloatingActionButtonLocation.centerDocked,
//    FloatingActionButtonLocation.centerFloat,
//  ];

  void selectOrderType(OrderType orderType, String route) {
    var cart = Provider.of<CartModel>(context!, listen: false);
    cart.setOrderType(orderType);
    Navigator.pushNamed(context!, route,
        arguments: StoreMenuArguments(storeId));
  }

  @override
  Widget build(BuildContext context) {
    return BottomAppBar(
      elevation: 0.0,
      shape: shape,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Padding(
            padding: EdgeInsets.all(20.0),
            child: FloatingActionButton.extended(
              heroTag: 'takeaway',
              backgroundColor: Theme.of(context).colorScheme.secondary,
              foregroundColor: Colors.white,
              icon: const Icon(Icons.local_mall, size: 20),
              label: Text(AppLocalizations.of(context)!.takeaway!),
              onPressed: () {
                selectOrderType(OrderType.TAKEAWAY, '/storeMenu');
              },
            ),
          ),
          Padding(
            padding: EdgeInsets.all(20.0),
            child: FloatingActionButton.extended(
              heroTag: 'booking',
              backgroundColor: Theme.of(context).colorScheme.primary,
              foregroundColor: Colors.white,
              icon: const Icon(Icons.local_mall, size: 20),
              label: Text('BOOKING'),
              onPressed: () {
                Navigator.pushNamed(
                  context,
                  '/booking',
                  arguments: BookingArguments(storeId),
                );
              },
            ),
          ),
          Padding(
            padding: EdgeInsets.all(20.0),
            child: FloatingActionButton.extended(
              heroTag: 'scanQR',
              backgroundColor: Theme.of(context).colorScheme.secondary,
              foregroundColor: Colors.white,
              icon: const Icon(Icons.qr_code_scanner, size: 20),
              label: Text('SCAN QR'),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => QRViewExample()),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

}

class _FullScreenDialogStoreMap extends StatelessWidget {
  const _FullScreenDialogStoreMap({
    this.mapContent,
  });

  final String? mapContent;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
//        automaticallyImplyLeading: false,
        backgroundColor: Colors.white,
        // brightness: Theme.of(context).platform == TargetPlatform.android
        //     ? Brightness.dark
        //     : Brightness.light,
        iconTheme: IconThemeData(
          color: Colors.black87,
        ),
        title: Text(
          AppLocalizations.of(context)!.storeMap!,
          style: textTheme.headline5,
        ),
      ),
      body: Center(
        child: CachedNetworkImage(
          imageUrl: mapContent!,
          placeholder: (context, url) => Center(
            child: SizedBox(
              height: 20.0,
              width: 20.0,
              child: CircularProgressIndicator(
                strokeWidth: 1.0,
              ),
            ),
          ),
          errorWidget: (context, url, error) => Icon(Icons.error),
          width: MediaQuery.of(context).size.width,
//            height: 80,
          fit: BoxFit.fitWidth,
        ),
      ),
    );
  }
}
