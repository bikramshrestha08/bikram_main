import 'dart:convert';

import 'package:linkeat/service/request.dart';
import 'package:linkeat/config.dart';
import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
//import 'package:stripe_payment/stripe_payment.dart';

class StripePay extends StatefulWidget {
  final GlobalKey<ScaffoldState> scaffoldKey;
  final int? amount;
  final String? orderId;
  final String? storeId;
  final String? merchantId;

  StripePay({
    Key? key,
    required this.scaffoldKey,
    required this.amount,
    required this.orderId,
    required this.storeId,
    required this.merchantId,
  }) : super(key: key);

  @override
  _StripePayState createState() => new _StripePayState();
}

class _StripePayState extends State<StripePay> {
  PaymentMethod? _paymentMethod;
  String? _currentSecret;
  //Token _paymentToken;

  @override
  initState() {
    super.initState();
    Stripe.publishableKey = 'pk_live_VTVHCl7qtgvtEw5Wa8TDMLjJ00ubd9akfO';
    Stripe.merchantIdentifier = widget.merchantId;
    Stripe.stripeAccountId = widget.merchantId;
    // TO DELETE: for stripe_payment
    // StripePayment.setOptions(StripeOptions(
    //     publishableKey: Constants.STRIPE_KEY,
    //     merchantId: widget.merchantId,
    //     androidPayMode: Constants.STRIPE_MODE));
    // StripePayment.setStripeAccount(widget.merchantId);
  }

  void setError(dynamic error) {
//    print(error.toString());
    // widget.scaffoldKey.currentState
    //     .showSnackBar(SnackBar(content: Text(error.toString())));
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(error.toString())));
  }

  /*  
  Future<void> startGooglePay() async {
    final dynamic response = await Services.asyncRequest(
      'POST', '/store/v2/${widget.storeId}/transaction', context,
      payload: {
        'storeId': widget.storeId,
        'orderId': widget.orderId,
        'paymentMethod': 'STRIPE',
        'currency': 'AUD',
        'amount': widget.amount,
        'device': 'UNKNOWN', // FIXME
        'merchantId': widget.storeId,
      });
    var data = json.decode(response.toString());

        final response = await fetchPaymentIntentClientSecret();
        final clientSecret = response['clientSecret'];

        // 2.present google pay sheet
        await Stripe.instance.initGooglePay(GooglePayInitParams(
            testEnv: true,
            merchantName: "Example Merchant Name",
            countryCode: 'us'));

        await Stripe.instance.presentGooglePay(
          PresentGooglePayParams(clientSecret: clientSecret),
        );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Google pay is not supported on this device')),
      );
    }
  }*/

  /* Credit card */
  Future<void> initPaymentSheet() async {
    final dynamic response = await Services.asyncRequest(
        'POST', '/store/v2/${widget.storeId}/transaction', context,
        payload: {
          'storeId': widget.storeId,
          'orderId': widget.orderId,
          'paymentMethod': 'STRIPE',
          'currency': 'AUD',
          'amount': widget.amount,
          'device': 'UNKNOWN', // FIXME
          'merchantId': widget.storeId,
        });
    var data = json.decode(response.toString());

    // initialize the payment sheet
    await Stripe.instance
        .initPaymentSheet(
          paymentSheetParameters: SetupPaymentSheetParameters(
            paymentIntentClientSecret: data['secret'],
            merchantDisplayName: "test",
            applePay: true,
            googlePay: true,
            merchantCountryCode: 'AU',
          ),
        )
        .catchError(setError);

    displayPaymentSheet();
  }

  Future<void> displayPaymentSheet() async {
    await Stripe.instance.presentPaymentSheet().then((value) {
      Navigator.pushNamed(
        context,
        '/orderComplete',
      );
    }).catchError(setError);
  }

  // TO DELETE: for stripe_payment
  /*
  Future<void> _initTransacton() async {
    final dynamic response = await Services.asyncRequest(
        'POST', '/store/v2/${widget.storeId}/transaction', context,
        payload: {
          'storeId': widget.storeId,
          'orderId': widget.orderId,
          'paymentMethod': 'STRIPE',
          'currency': 'AUD',
          'amount': widget.amount,
          'device': 'UNKNOWN', // FIXME
          'merchantId': widget.storeId,
        });
    var data = json.decode(response.toString());
    var secret = data["secret"];
    setState(() {
      _currentSecret = secret;
    });
    _confirmPayment();
  }

  _confirmPayment() {
    if (_paymentMethod == null && _paymentToken == null) return null;
    if (_paymentMethod == null) {
      StripePayment.createPaymentMethod(
        PaymentMethodRequest(
          card: CreditCard(
            token: _paymentToken.tokenId,
          ),
        ),
      ).then((paymentMethod) {
        setState(() {
          _paymentMethod = paymentMethod;
        });
      }).catchError(setError);
    }

    StripePayment.confirmPaymentIntent(
      PaymentIntent(
        clientSecret: _currentSecret,
        paymentMethodId: _paymentMethod.id,
      ),
    ).then((paymentIntent) {
      widget.scaffoldKey.currentState.showSnackBar(SnackBar(
          content: Text('Confirm Received ${paymentIntent.paymentIntentId}')));
      Navigator.pushNamed(
        context,
        '/orderComplete',
      );
    }).catchError(setError);
  }*/

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        SizedBox(
          height: 55.0,
          child: OutlinedButton(
            // highlightedBorderColor: Colors.grey[400],
            // highlightColor: Colors.grey[200],
            // shape: RoundedRectangleBorder(
            //     borderRadius: BorderRadius.circular(30.0)),
            onPressed: () {
              initPaymentSheet();

              //TO DELETE: for stripe_payment
              /*
              StripePayment.paymentRequestWithCardForm(CardFormPaymentRequest())
                  .then((paymentMethod) {
//                widget.scaffoldKey.currentState.showSnackBar(SnackBar(content: Text('Received ${paymentMethod.id}')));
                setState(() {
                  _paymentMethod = paymentMethod;
                });
                _initTransacton();
              }).catchError(setError);*/
            },
            child: Padding(
              padding: EdgeInsets.fromLTRB(15.0, 10.0, 15.0, 10.0),
              child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Text(
                      'Credit Card',
                      style: TextStyle(fontSize: 18, color: Colors.black),
                    ),
                  ]),
            ),
          ),
        ),
        SizedBox(
          height: 10,
        ),
        SizedBox(
          height: 55.0,
          child: OutlinedButton(
            // highlightedBorderColor: Colors.grey[400],
            // highlightColor: Colors.grey[200],
            // shape: RoundedRectangleBorder(
            //     borderRadius: BorderRadius.circular(30.0)),
            onPressed: () {
              //TO DELETE: for stripe_payment
              /*
              StripePayment.paymentRequestWithNativePay(
                androidPayOptions: AndroidPayPaymentRequest(
                  totalPrice: (widget.amount / 100).toString(),
                  currencyCode: "AUD",
                ),
                applePayOptions: ApplePayPaymentOptions(
                  countryCode: 'AU',
                  currencyCode: 'AUD',
                  items: [
                    ApplePayItem(
                      label: widget.orderId,
                      amount: (widget.amount / 100).toString(),
                    )
                  ],
                ),
              ).then((token) {
                setState(() {
                  _paymentToken = token;
                });
                _initTransacton();
              }).catchError(setError);*/
            },
            child: Padding(
              padding: EdgeInsets.fromLTRB(15.0, 10.0, 15.0, 10.0),
              child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Text(
                      'Native Pay',
                      style: TextStyle(fontSize: 18, color: Colors.black),
                    ),
                  ]),
            ),
          ),
        ),
      ],
    );
  }
}
