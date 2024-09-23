import 'package:linkeat/utils/sputil.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/gestures.dart' show DragStartBehavior;
import 'package:sn_progress_dialog/sn_progress_dialog.dart';

import 'package:provider/provider.dart';

import 'package:linkeat/states/cart.dart';
import 'package:linkeat/models/store.dart';
import 'package:linkeat/l10n/localizations.dart';
import 'package:linkeat/utils/store.dart';
import 'package:linkeat/utils/SharedPreferences_util.dart';
import 'package:linkeat/config.dart';

class DeliveryForm extends StatefulWidget {
  static const routeName = '/checkoutDelivery';

  const DeliveryForm({Key? key}) : super(key: key);

  @override
  _DeliveryFormState createState() => _DeliveryFormState();
}

class _DeliveryFormState extends State<DeliveryForm> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  DeliveryDetail deliveryDetail = DeliveryDetail(address: DeliveryAddress());
  List<DeliveryScheduleOption> deliveryTimeOptions = [];
  DeliveryScheduleOption? selectedDeliveryScheduleOption;
  int? deliveryFee;

  @override
  void initState() {
    super.initState();

    String? fullName = SpUtil.preferences.getString('fullName');
    if (fullName != null) {
      deliveryDetail.name = fullName;
    }
    String? mobile = SpUtil.preferences.getString('mobile');
    if (mobile != null) {
      deliveryDetail.phone =
          mobile.length > 10 ? mobile.substring(mobile.length - 10) : mobile;
    }
    String? phone = SpUtil.preferences.getString('checkoutMobile');
    if (phone != null) {
      deliveryDetail.phone = phone;
    }
    String? customerName = SpUtil.preferences.getString('checkoutName');
    if (customerName != null) {
      deliveryDetail.name = customerName;
    }
    String? checkoutAddress = SpUtil.preferences.getString('checkoutAddress');
    if (customerName != null) {
      deliveryDetail.address!.address1 = checkoutAddress;
    }
    deliveryDetail.address!.city = Constants.DELIVERY_CITY;
    deliveryDetail.address!.postCode = Constants.DELIVERY_POSTCODE;
    WidgetsBinding.instance.addPostFrameCallback(
        (_) => _getDeliveryTimeSlice(Constants.DELIVERY_POSTCODE));
  }

  void showInSnackBar(String value) {
    // _scaffoldKey.currentState.hideCurrentSnackBar();
    // _scaffoldKey.currentState.showSnackBar(SnackBar(
    //   content: Text(value),
    // ));
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(value),
    ));
  }

  // bool _autoValidate = false;

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

//  void _resetDeliverySchedule() {
//    setState(() {
//      deliveryTimeOptions = [];
//      selectedDeliveryScheduleOption = null;
//      deliveryDetail.expectArriveTime = null;
//      deliveryDetail.deliverySchedule = null;
//      deliveryFee = null;
//    });
//  }

  Future<void> _handleSubmitted() async {
    final form = _formKey.currentState!;
    if (!form.validate() || selectedDeliveryScheduleOption == null) {
      // _autoValidate = true; // Start validating on every change.
      showInSnackBar(
        'Oops! can not submit order.',
      );
    } else {
      form.save();
      final ProgressDialog pr = ProgressDialog(context: context);
      // pr.style(
      //     message: 'Submitting...',
      //     borderRadius: 10.0,
      //     backgroundColor: Colors.white,
      //     elevation: 10.0,
      //     insetAnimCurve: Curves.easeInOut,
      //     progress: 0.0,
      //     messageTextStyle: TextStyle(
      //         color: Colors.black,
      //         fontSize: 19.0,
      //         fontWeight: FontWeight.w600));
      await pr.show(
        msg: 'Submitting...',
        borderRadius: 10.0,
        backgroundColor: Colors.white,
        elevation: 10.0,
      );
      // await pr.show();
      var cart = Provider.of<CartModel>(context, listen: false);
      cart.createOrder(context, deliveryDetail: deliveryDetail);

      // save form info
      SharedPreferencesUtil.setStringItem('checkoutName', deliveryDetail.name!);
      SharedPreferencesUtil.setStringItem(
          'checkoutMobile', deliveryDetail.phone!);
      SharedPreferencesUtil.setStringItem(
          'checkoutAddress', deliveryDetail.address!.address1!);
    }
  }

  String? _validateName(String? value) {
    if (value!.isEmpty) {
      return 'Please enter name';
    }
    return null;
  }

  String? _validateAddress(String? value) {
    if (value!.isEmpty) {
      return 'Please enter address';
    }
    return null;
  }

//  String _validateCity(String value) {
//    if (value.isEmpty) {
//      return 'Please enter city';
//    }
//    return null;
//  }
//
//  String _validatePostCode(String value) {
//    if (value.isEmpty) {
//      return 'Please enter postcode';
//    }
//    return null;
//  }

  String? _validatePhoneNumber(String? value) {
    final phoneExp = RegExp(r'^\d\d\d\d\d\d\d\d\d\d$');
    if (!phoneExp.hasMatch(value!)) {
      return 'invalid phone number';
    }
    return null;
  }

  void _getDeliveryTimeSlice(String? postCode) {
    var cart = Provider.of<CartModel>(context, listen: false);
    // validate delivery range
    var validDeliveryRanges = cart.storeDetail!.deliveryCfg!.deliveryRanges!
        .where((deliveryRange) => deliveryRange.postCodes!.contains(postCode))
        .toList();
    if (validDeliveryRanges.length == 0) {
      FocusScope.of(context).requestFocus(new FocusNode());
      showInSnackBar(
        'Oops! postCode not available.',
      );
      return;
    }
    var deliveryRange = validDeliveryRanges[0];
    if (cart.cartTotal < deliveryRange.minimalOrderPrice!) {
      FocusScope.of(context).requestFocus(new FocusNode());
      showInSnackBar(
        'Oops! Minimal Order amount \$${(deliveryRange.minimalOrderPrice! / 100).toString()}.',
      );
      return;
    }

    var _deliveryTimeOptions = getDeliveryTimeOptions(postCode, deliveryRange);
    if (_deliveryTimeOptions != null) {
      setState(() {
        deliveryTimeOptions = _deliveryTimeOptions;
        selectedDeliveryScheduleOption = _deliveryTimeOptions[0];
        deliveryDetail.expectArriveTime =
            _deliveryTimeOptions[0].expectArriveTime;
        deliveryDetail.deliverySchedule =
            _deliveryTimeOptions[0].deliverySchedule;
        deliveryFee = deliveryRange.cost;
      });
    } else {
      FocusScope.of(context).requestFocus(new FocusNode());
      showInSnackBar(
        'Oops! delivery is not available right now.',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // final cursorColor = Theme.of(context).cursorColor;
    final cursorColor = Theme.of(context).primaryColor;
    const sizedBoxSpace = SizedBox(height: 24);
    final textTheme = Theme.of(context).textTheme;
    var cart = Provider.of<CartModel>(context);
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
          AppLocalizations.of(context)!.checkout!,
          style: textTheme.headline5,
        ),
      ),
      key: _scaffoldKey,
      body: Form(
        key: _formKey,
        child: Scrollbar(
          child: SingleChildScrollView(
            dragStartBehavior: DragStartBehavior.down,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                sizedBoxSpace,
                Text(
                  '* Get delivery detail by PostCode',
                  style: textTheme.caption,
                ),
                SizedBox(
                  height: 10,
                ),
                TextFormField(
                  initialValue: deliveryDetail.address!.postCode,
                  textCapitalization: TextCapitalization.words,
                  cursorColor: cursorColor,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.white,
                    icon: const Icon(Icons.my_location),
                    labelText: AppLocalizations.of(context)!.postCode,
                  ),
                  readOnly: true,
//                  onChanged: (value) {
//                    if (value.length == 4) {
//                      _getDeliveryTimeSlice(value);
//                    } else {
//                      _resetDeliverySchedule();
//                    }
//                  },
//                  onSaved: (value) {
//                    deliveryDetail.address.postCode = value;
//                  },
//                  keyboardType: TextInputType.number,
//                  validator: _validatePostCode,
//                  inputFormatters: <TextInputFormatter>[
//                    WhitelistingTextInputFormatter.digitsOnly,
//                  ],
                ),
                deliveryTimeOptions.length > 0
                    ? sizedBoxSpace
                    : SizedBox.shrink(),
                Container(
                    child: deliveryTimeOptions.length > 0
                        ? Row(
                            children: <Widget>[
                              Icon(
                                Icons.timer,
                                color: Colors.black45,
                              ),
                              SizedBox(
                                width: 20.0,
                              ),
                              Expanded(
                                child: DropdownButton<DeliveryScheduleOption>(
                                  value: selectedDeliveryScheduleOption,
                                  iconSize: 24,
                                  underline: Container(
                                    height: 1,
                                    color: Colors.black54,
                                  ),
                                  onChanged:
                                      (DeliveryScheduleOption? newValue) {
                                    setState(() {
                                      selectedDeliveryScheduleOption = newValue;
                                      deliveryDetail.expectArriveTime =
                                          newValue!.expectArriveTime;
                                      deliveryDetail.deliverySchedule =
                                          newValue.deliverySchedule;
                                    });
                                  },
                                  items: deliveryTimeOptions.map<
                                          DropdownMenuItem<
                                              DeliveryScheduleOption>>(
                                      (DeliveryScheduleOption item) {
                                    return DropdownMenuItem<
                                        DeliveryScheduleOption>(
                                      value: item,
                                      child: Text(item.showing!),
                                    );
                                  }).toList(),
                                ),
                              ),
                            ],
                          )
                        : SizedBox.shrink()),
                sizedBoxSpace,
                TextFormField(
                  initialValue: deliveryDetail.name,
                  textCapitalization: TextCapitalization.words,
                  cursorColor: cursorColor,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.white,
                    icon: const Icon(Icons.person),
                    labelText: AppLocalizations.of(context)!.name,
                  ),
                  onSaved: (value) {
                    deliveryDetail.name = value;
                  },
                  validator: _validateName,
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                ),
                sizedBoxSpace,
                TextFormField(
                  initialValue: deliveryDetail.phone,
                  cursorColor: cursorColor,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.white,
                    icon: const Icon(Icons.phone),
                    labelText: AppLocalizations.of(context)!.mobile,
                  ),
                  keyboardType: TextInputType.phone,
                  onSaved: (value) {
                    deliveryDetail.phone = value;
                  },
                  maxLength: 10,
                  // maxLengthEnforced: false,
                  validator: _validatePhoneNumber,
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  inputFormatters: <TextInputFormatter>[
                    FilteringTextInputFormatter.allow(RegExp(r'[0-9]'))
                  ],
                ),
                sizedBoxSpace,
                TextFormField(
                  initialValue: deliveryDetail.address!.address1,
                  textCapitalization: TextCapitalization.words,
                  cursorColor: cursorColor,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.white,
                    icon: const Icon(Icons.location_on),
                    labelText: AppLocalizations.of(context)!.address,
                  ),
                  onSaved: (value) {
                    deliveryDetail.address!.address1 = value;
                  },
                  validator: _validateAddress,
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                ),
                sizedBoxSpace,
                TextFormField(
                  initialValue: deliveryDetail.address!.city,
                  textCapitalization: TextCapitalization.words,
                  cursorColor: cursorColor,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.white,
                    icon: const Icon(Icons.location_city),
                    labelText: AppLocalizations.of(context)!.city,
                  ),
                  readOnly: true,
                ),
                sizedBoxSpace,
                // Text(
                //   '* indicates required field',
                //   style: Theme.of(context).textTheme.caption,
                // ),
                // sizedBoxSpace,
                Divider(),
                SizedBox(
                  height: 5,
                ),
                Row(
                  children: <Widget>[
                    Text('${AppLocalizations.of(context)!.total}：',
                        style: Theme.of(context).textTheme.subtitle2),
                    Expanded(
                      child: Align(
                        alignment: Alignment.centerRight,
                        child: Text('\$' + (cart.cartTotal / 100).toString(),
                            style: Theme.of(context)
                                .textTheme
                                .subtitle2!
                                .copyWith(fontSize: 16)),
                      ),
                    ),
                  ],
                ),
                SizedBox(
                  height: 5.0,
                ),
                Row(
                  children: <Widget>[
                    Text('${AppLocalizations.of(context)!.deliveryFee}：',
                        style: Theme.of(context).textTheme.caption),
                    Expanded(
                      child: Align(
                        alignment: Alignment.centerRight,
                        child: Text(
                            '\$' + ((deliveryFee ?? 0) / 100).toString(),
                            style: Theme.of(context).textTheme.caption),
                      ),
                    ),
                  ],
                ),
                SizedBox(
                  height: 15.0,
                ),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: _SubmitBar(submit: _handleSubmitted),
    );
  }
}

class _SubmitBar extends StatelessWidget {
  final Function submit;

  _SubmitBar({
    Key? key,
    required this.submit,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    var platform = Theme.of(context).platform;
    double paddingBottom = 0;
    if (platform == TargetPlatform.iOS &&
        MediaQuery.of(context).padding.bottom > 0) {
      paddingBottom = 20;
    }
    return Container(
      color: colorScheme.primary,
      child: SafeArea(
        minimum: EdgeInsets.only(bottom: paddingBottom),
        bottom: false,
        child: Container(
          child: TextButton(
            onPressed: submit as void Function()?,
            child: Container(
              height: 60.0,
              child: Center(
                child: Text(
                  AppLocalizations.of(context)!.submitOrder!,
                  style: textTheme.subtitle1!.copyWith(
                    color: Colors.white,
                    fontSize: 18,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
