import 'dart:async';
import 'dart:convert';
import 'package:linkeat/service/request.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:linkeat/models/order.dart';
import 'package:linkeat/service/api.dart';
import 'package:linkeat/l10n/localizations.dart';
import 'package:linkeat/states/cart.dart';
import 'package:linkeat/routes/payment/stripe.dart';
import 'package:linkeat/routes/checkout/membership_section.dart'; // Import the new file
import 'dart:convert';
import 'dart:html' as html; // Import for web navigation
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';

import '../../utils/SharedPreferences_util.dart';



class Payment extends StatefulWidget {
  static const routeName = '/payment';
  final String? orderId;

  Payment({
    Key? key,
    required this.orderId,
  }) : super(key: key);

  @override
  _PaymentState createState() => _PaymentState();
}

class _PaymentState extends State<Payment> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  static const supayChannel = const MethodChannel('supay');
  static const windcaveChannel = const MethodChannel('windcave');

  Future<Order>? futureOrder;

  @override
  void initState() {
    super.initState();
    futureOrder = fetchOrderById(context, widget.orderId);
    supayChannel.setMethodCallHandler(_onSupayCallback);
  }

  void _handlePOD({String? orderId, String? storeId, int? amount}) {
    initPODTransacton(
      context: context,
      orderId: orderId,
      storeId: storeId,
      amount: amount,
    );
  }

  Future<dynamic> _onSupayCallback(MethodCall methodCall) async {
    switch (methodCall.method) {
      case 'paySuccess':
        Navigator.pushNamed(
          context,
          '/orderComplete',
        );
        break;
      case 'payCancel':
        showDialog<String>(
            context: context,
            builder: (BuildContext buildContext) {
              return AlertDialog(
                title: Text('Payment Cancelled'),
              );
            });
        break;
      case 'payFailure':
        showDialog<String>(
            context: context,
            builder: (BuildContext buildContext) {
              return AlertDialog(
                title: Text('Payment Failed'),
              );
            });
        break;
    }
  }

  void _handleWindcave({
    required BuildContext context,
    String? orderId,
    String? storeId,
    int? amount,
    bool isForIframe = false,
  }) {
    if (orderId == null || storeId == null || amount == null) {
      // Log error, show error message, or handle the null case appropriately
      debugPrint('Error: Transaction details are incomplete.');
      return;
    }

    String iframeParam = isForIframe ? 'isForIframe' : 'isForWeb';
    String baseRedirectUrl;

    if (isForIframe) {
      baseRedirectUrl = 'actualIframeUrl';
    } else {
      Uri baseUri = Uri.base;
      // Only extract the scheme, host, and port
      baseRedirectUrl = '${baseUri.scheme}://${baseUri.host}${baseUri.hasPort ? ':${baseUri.port}' : ''}';
    }

    initWindcaveTransaction(
      context: context,
      orderId: orderId,
      storeId: storeId,
      amount: amount,
      approvedRedirectUrl: '$baseRedirectUrl/orderApproved',
      declinedRedirectUrl: '$baseRedirectUrl/orderDeclined',
      cancelledRedirectUrl: '$baseRedirectUrl/orderCancelled',
    );

  }


// Modify the launchURL function to use dart:html for web projects
  void launchURL(String url) {
    html.window.location.href = url;
  }

  Future<dynamic> initWindcaveTransaction({
    required BuildContext context,
    required String orderId,
    required String storeId,
    required int amount,
    required String? approvedRedirectUrl,
    required String? declinedRedirectUrl,
    required String? cancelledRedirectUrl,
  }) async {
    // Print the parameters before the try block
    print('Initializing Windcave Transaction with parameters:');
    print('orderId: $orderId');
    print('storeId: $storeId');
    print('amount: $amount');
    print('approvedRedirectUrl: $approvedRedirectUrl');
    print('declinedRedirectUrl: $declinedRedirectUrl');
    print('cancelledRedirectUrl: $cancelledRedirectUrl');

    try {
      // Check for null or empty URLs
      if (approvedRedirectUrl == null || approvedRedirectUrl.isEmpty) {
        throw Exception("Approved redirect URL is required");
      }
      if (declinedRedirectUrl == null || declinedRedirectUrl.isEmpty) {
        throw Exception("Declined redirect URL is required");
      }
      if (cancelledRedirectUrl == null || cancelledRedirectUrl.isEmpty) {
        throw Exception("Cancelled redirect URL is required");
      }

      final dynamic response = await Services.asyncRequest(
        'POST',
        '/store/v2/$storeId/transaction',
        context,
        payload: {
          "orderId": orderId,
          'storeId': storeId,
          'amount': amount,
          'note': '', // Optional: Add note if necessary
          'currency': 'AUD', // Specify the currency or make it dynamic
          'paymentMethod': 'WINDCAVEH5',
          'device': 'WEBAPP',
          'txnReqestMeta': {
            'windcaveH5TxnMeta': {
              'approvedRedirectUrl': approvedRedirectUrl,
              'declinedRedirectUrl': declinedRedirectUrl,
              'cancelledRedirectUrl': cancelledRedirectUrl,
            },
          },
        },
      );

      var data = json.decode(response.toString());
      print("Return data:");
      print(data);
      print(data['transactionId']);
      SharedPreferencesUtil.setStringItem(
          'TransactionId', data['transactionId']);

      // Extract the redirect URL from the links array
      String redirectUrl = '';
      if (data['links'] != null) {
        for (var link in data['links']) {
          if (link['method'] == 'REDIRECT') {
            redirectUrl = link['href'];
            break;
          }
        }
      }

      // Check if the redirect URL is found
      if (redirectUrl.isNotEmpty) {
        // Redirect to the URL using the modified launchURL function
        launchURL(redirectUrl);
      } else {
        // Handle the case where the redirect URL is not found
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Redirect URL not found in the response.'),
          ),
        );
      }

      return data;
    } catch (e) {
      // Improved error handling
      debugPrint('Transaction Error: ${e.toString()}');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Transaction Error: ${e.toString()}'),
        ),
      );
      return null; // Return null or handle the error as necessary
    }
  }








  Future<void> _handleSuperPay(
      {String? payChannel,
      String? gateway,
      String? orderId,
      String? storeId,
      int? amount}) async {
    final dynamic response = await Services.asyncRequest(
        'POST', '/store/v2/${storeId}/transaction', context,
        payload: {
          'storeId': storeId,
          'orderId': orderId,
          'paymentMethod': 'SUPERPAYMINIPROGRAM',
          'currency': 'AUD',
          'payWay': 'SDK',
          'payChannel': payChannel,
          'amount': amount,
          'device': 'UNKNOWN', // FIXME
        });

    var data = json.decode(response.toString());

    try {
      await supayChannel.invokeMethod(
          'onSupayPay', {"gateWay": gateway, "payInfo": data['payInfo']});
    } on PlatformException catch (e) {
      throw e;
    }
  }

  void _showBankTransferDetail(
      {String? orderId, String? storeId, int? amount}) {
    showModalBottomSheet<void>(
      context: context,
      builder: (context) {
        return _BottomSheetBankTransferDetail(
          orderId: orderId,
          storeId: storeId,
          amount: amount,
          context: context,
        );
      },
    );
  }
  Future<bool> _handleBack() async {
    final shouldLeave = await showDialog<bool>(
      context: context,
      barrierDismissible: false, // User must tap a button to close the dialog
      builder: (BuildContext context) {
        return AlertDialog(
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('Do you want to go back to the home page?'),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Cancel'),
              onPressed: () => Navigator.of(context).pop(false), // Do not exit the app
            ),
            TextButton(
              child: Text('Confirm'),
              onPressed: () => Navigator.pushNamedAndRemoveUntil(context, '/', (_) => false), // Exit the app
            ),
          ],
        );
      },
    );

    // If the dialog is dismissed by tapping outside or pressing back (which shouldn't happen as barrierDismissible is false),
    // it will return null. In this case, we treat it as a "do not exit" action.
    return shouldLeave ?? false;
  }

  @override
  Widget build(BuildContext context) {
    var cart = Provider.of<CartModel>(context, listen: false);
    var acceptPOD = cart.storeDetail!.storeConfig!.acceptPOD;
    var acceptBankTransfer = cart.storeDetail!.storeConfig!.acceptBankTransfer!;
    var acceptSuperPayMiniPay =
        cart.storeDetail!.storeConfig!.acceptSuperPayMiniPay;
    var acceptWxPayPayment =
        cart.storeDetail!.storeConfig!.acceptWxPayPayment;
    var acceptStripe = cart.storeDetail!.storeConfig!.acceptStripeConnect;
    var acceptWindcaveH5 =  cart.storeDetail!.storeConfig!.acceptWindcaveH5;
    var acceptChinaPayAlipayH5 = cart.storeDetail!.storeConfig!.acceptChinaPayAlipayH5;


    final textTheme = Theme.of(context).textTheme;
//    final colorScheme = Theme.of(context).colorScheme;

    bool invalidPayments =
        acceptBankTransfer || acceptPOD! || acceptSuperPayMiniPay!;
    return WillPopScope(
      child: Scaffold(
        key: _scaffoldKey,
        backgroundColor: Colors.white,
        appBar: AppBar(
          // automaticallyImplyLeading: false,
          backgroundColor: Colors.white,
          // brightness: Theme.of(context).platform == TargetPlatform.android
          //     ? Brightness.dark
          //     : Brightness.light,
          iconTheme: IconThemeData(
            color: Colors.black87,
          ),
          title: Text(
            AppLocalizations.of(context)!.payment!,
            style: textTheme.headline5,
          ),
          centerTitle: true,
        ),
        body: FutureBuilder<Order>(
          future: futureOrder,
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              var order = snapshot.data!;
              return Scrollbar(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 40),
                  child: ListView(
                    children: <Widget>[
                      Padding(
                        padding: EdgeInsets.all(30.0),
                        child: Center(
                          child: Text(
                            '${AppLocalizations.of(context)!.total}: \$${(order.amount! / 100).toString()}',
                            style: textTheme.headline6,
                          ),
                        ),
                      ),
                      MembershipSection(transactionId: order.uuid!),
                      Container(
                        child: invalidPayments
                            ? SizedBox.shrink()
                            : Center(
                                child: Padding(
                                  padding: EdgeInsets.symmetric(vertical: 30.0),
                                  child: Column(
                                    children: <Widget>[
                                      Text('No Available Payment Methods',
                                          style: textTheme.caption),
                                      SizedBox(
                                        height: 10.0,
                                      ),
                                      ElevatedButton(
                                        onPressed: () {
                                          Navigator.pushNamedAndRemoveUntil(
                                              context, '/', (_) => false);
                                        },
                                        child: Text('Back to Home'),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                      ),
                      Container(
                        padding: EdgeInsets.only(bottom: 10.0),
                        child: SizedBox(
//                          width: 300.0,
                          height: 55.0,
                          child: OutlinedButton(
                            // highlightedBorderColor: Colors.grey[400],
                            // highlightColor: Colors.grey[200],
                            // shape: RoundedRectangleBorder(
                            //     borderRadius: BorderRadius.circular(30.0)),
                            onPressed: acceptWxPayPayment!
                                ? () {
                              _handleSuperPay(
                                  payChannel: 'WechatPay',
                                  gateway: 'WechatPay',
                                  orderId: order.uuid,
                                  storeId: order.store!.id,
                                  amount: order.amount);
                            }:null,
                            child: Padding(
                              padding:
                                  EdgeInsets.fromLTRB(15.0, 10.0, 15.0, 10.0),
                              child: Image(
                                  image:
                                      AssetImage('assets/images/wechatPay.png'),
                                  fit: BoxFit.cover,
                                  color: acceptWxPayPayment
                                      ? null
                                      : Colors.grey[400]),
                            ),
                          ),
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.only(bottom: 10.0),
                        child: SizedBox(
//                          width: 300.0,
                          height: 55.0,
                          child: OutlinedButton(
                            // highlightedBorderColor: Colors.grey[400],
                            // highlightColor: Colors.grey[200],
                            // shape: RoundedRectangleBorder(
                            //     borderRadius: BorderRadius.circular(30.0)),
                            onPressed: acceptSuperPayMiniPay!
                                ? () {
                                    _handleSuperPay(
                                        payChannel: 'ALIPAY',
                                        gateway: 'AliPay',
                                        orderId: order.uuid,
                                        storeId: order.store!.id,
                                        amount: order.amount);
                                  }
                                : null,
                            child: Padding(
                              padding:
                                  EdgeInsets.fromLTRB(15.0, 10.0, 15.0, 10.0),
                              child: Image(
                                  image: AssetImage('assets/images/alipay.png'),
                                  fit: BoxFit.cover,
                                  color: acceptChinaPayAlipayH5!
                                      ? null
                                      : Colors.grey[400]),
                            ),
                          ),
                        ),
                      ),
                      Container(
                          padding: EdgeInsets.only(bottom: 10.0),
                          child: acceptPOD!
                              ? SizedBox(
//                                  width: 300.0,
                                  height: 55.0,
                                  child: OutlinedButton(
                                    // highlightedBorderColor: Colors.grey[400],
                                    // highlightColor: Colors.grey[200],
                                    // shape: RoundedRectangleBorder(
                                    //     borderRadius:
                                    //         BorderRadius.circular(30.0)),
                                    onPressed: () {
                                      _handlePOD(
                                          orderId: order.uuid,
                                          storeId: order.store!.id,
                                          amount: order.amount);
                                    },
                                    child: Text(
                                        AppLocalizations.of(context)!
                                            .payOnDelivery!,
                                        style: textTheme.button!
                                            .copyWith(fontSize: 18)),
                                  ),
                                )
                              : SizedBox.shrink()),
                      Container(
                          padding: EdgeInsets.only(bottom: 10.0),
                          child: acceptBankTransfer!
                              ? SizedBox(
//                                  width: 300.0,
                                  height: 55.0,
                                  child: OutlinedButton(
                                    // highlightedBorderColor: Colors.grey[400],
                                    // highlightColor: Colors.grey[200],
                                    // shape: RoundedRectangleBorder(
                                    //     borderRadius:
                                    //         BorderRadius.circular(30.0)),
                                    onPressed: () {
                                      _showBankTransferDetail(
                                          orderId: order.uuid,
                                          storeId: order.store!.id,
                                          amount: order.amount);
                                    },
                                    child: Text(
                                        AppLocalizations.of(context)!
                                            .bankTransfer!,
                                        style: textTheme.button!
                                            .copyWith(fontSize: 18)),
                                  ),
                                )
                              : SizedBox.shrink()),
                      // Container(
                      //     padding: EdgeInsets.only(bottom: 10.0),
                      //     child: (acceptStripe! && order.amount! >= 50)
                      //         ? StripePay(
                      //             scaffoldKey: _scaffoldKey,
                      //             orderId: order.uuid,
                      //             amount: order.amount,
                      //             storeId: order.store!.id,
                      //             merchantId:
                      //                 cart.storeDetail!.stripeConfig!.accountId,
                      //           )
                      //         : SizedBox.shrink()),
                      Container(
                          padding: EdgeInsets.only(bottom: 10.0),
                          child: acceptWindcaveH5!
                              ? SizedBox(
//                                  width: 300.0,
                            height: 55.0,
                            child: OutlinedButton(
                              // highlightedBorderColor: Colors.grey[400],
                              // highlightColor: Colors.grey[200],
                              // shape: RoundedRectangleBorder(
                              //     borderRadius:
                              //         BorderRadius.circular(30.0)),
                              onPressed: (){
                                _handleWindcave(
                                  context: context,
                                    orderId: order.uuid,
                                    storeId: order.store!.id,
                                    amount: order.amount,
                                );
                              },
                              child: Text(
                                  AppLocalizations.of(context)!
                                      .windcave!,
                                  style: textTheme.button!
                                      .copyWith(fontSize: 18)),
                            ),
                          )
                              : SizedBox.shrink()),
//                      Text(_supayCallBack),
                    ],
                  ),
                ),
              );
            } else if (snapshot.hasError) {
              return Text("${snapshot.error}");
            }
            // By default, show a loading spinner.
            return Center(
//              widthFactor: 9.5,
//              heightFactor: 9.5,
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
      ),
      onWillPop: _handleBack,
    );
  }
}



class _BottomSheetBankTransferDetail extends StatelessWidget {
  final String? orderId;
  final String? storeId;
  final int? amount;
  final BuildContext? context;

  _BottomSheetBankTransferDetail({
    Key? key,
    this.orderId,
    this.storeId,
    this.amount,
    this.context,
  }) : super(key: key);

  void _handleBankTransfer({String? orderId, String? storeId, int? amount}) {
    initBankTransferTransacton(
      context: context,
      orderId: orderId,
      storeId: storeId,
      amount: amount,
    );
  }

  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<CartModel>(context, listen: false);
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
//      color: Colors.grey[50],
      padding: EdgeInsets.all(20),
      height: 360,
      child: Column(
        children: <Widget>[
          Text(
            'Bank Transfer Detail',
            style: textTheme.subtitle1,
          ),
          SizedBox(
            height: 10.0,
          ),
          Divider(),
          Padding(
            padding: EdgeInsets.symmetric(vertical: 10.0),
            child: Row(
              children: <Widget>[
                Text('Account name:',
                    style: Theme.of(context).textTheme.bodyText2),
                Expanded(
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: Text(
                        cart.storeDetail!.bankTransferStoreConfig!
                                .accountName ??
                            '',
                        style: Theme.of(context).textTheme.bodyText2),
                  ),
                ),
              ],
            ),
          ),
          Divider(),
          Padding(
            padding: EdgeInsets.symmetric(vertical: 10.0),
            child: Row(
              children: <Widget>[
                Text('BSB:', style: Theme.of(context).textTheme.bodyText2),
                Expanded(
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: Text(
                        cart.storeDetail!.bankTransferStoreConfig!.bsb ?? '',
                        style: Theme.of(context).textTheme.bodyText2),
                  ),
                ),
              ],
            ),
          ),
          Divider(),
          Padding(
            padding: EdgeInsets.symmetric(vertical: 10.0),
            child: Row(
              children: <Widget>[
                Text('Account No.:',
                    style: Theme.of(context).textTheme.bodyText2),
                Expanded(
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: Text(
                        cart.storeDetail!.bankTransferStoreConfig!.accountNo ??
                            '',
                        style: Theme.of(context).textTheme.bodyText2),
                  ),
                ),
              ],
            ),
          ),
          Divider(),
          Padding(
            padding: EdgeInsets.symmetric(vertical: 10.0),
            child: Row(
              children: <Widget>[
                Text('Pay Id:', style: Theme.of(context).textTheme.bodyText2),
                Expanded(
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: Text(
                        cart.storeDetail!.bankTransferStoreConfig!.payId ?? '',
                        style: Theme.of(context).textTheme.bodyText2),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(
            height: 20,
          ),
          Expanded(
            child: SizedBox(
                width: 200.0,
                child: TextButton(
                  style: TextButton.styleFrom(
                      backgroundColor: colorScheme.primary),
                  onPressed: () {
                    _handleBankTransfer(
                        orderId: orderId, storeId: storeId, amount: amount);
                  },
                  child: Text(
                    AppLocalizations.of(context)!.uploadScreenshot!,
                    style: textTheme.button!.copyWith(color: Colors.white),
                  ),
                )),
          )
        ],
      ),
    );
  }
}


// class WebViewScreen extends StatelessWidget {
//   final String url;
//
//   WebViewScreen({required this.url});
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('WebView'),
//       ),
//       body: Center(
//         child: Text('Redirecting to: $url'),
//         // Replace the above line with a WebView widget to load the URL
//       ),
//     );
//   }
// }
