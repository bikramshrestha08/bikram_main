import 'package:linkeat/utils/sputil.dart';
import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart' show DragStartBehavior;
import 'package:flutter/services.dart';

import 'package:provider/provider.dart';
// import 'package:progress_dialog/progress_dialog.dart';
import 'package:sn_progress_dialog/sn_progress_dialog.dart';

import 'package:linkeat/models/store.dart';
import 'package:linkeat/l10n/localizations.dart';
import 'package:linkeat/states/cart.dart';
import 'package:linkeat/utils/store.dart';
import 'package:linkeat/utils/SharedPreferences_util.dart';

class TakeAwayForm extends StatefulWidget {
  static const routeName = '/checkoutTakeaway';
  const TakeAwayForm({Key? key}) : super(key: key);

  @override
  _TakeAwayFormState createState() => _TakeAwayFormState();
}

class _TakeAwayFormState extends State<TakeAwayForm> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  TakeAwayDetail takeawayDetail = TakeAwayDetail();
  List<TakeawayTimeOption> pickupTimeOptions = [];
  TakeawayTimeOption? selectedPickupTimeOptions;

  @override
  void initState() {
    super.initState();
    String? fullName = SpUtil.preferences.getString('fullName');
    if (fullName != null) {
      takeawayDetail.customerName = fullName;
    }
    String? mobile = SpUtil.preferences.getString('mobile');
    if (mobile != null) {
      takeawayDetail.phone =
          mobile.length > 10 ? mobile.substring(mobile.length - 10) : mobile;
    }
    String? phone = SpUtil.preferences.getString('checkoutMobile');
    if (phone != null) {
      takeawayDetail.phone = phone;
    }
    String? customerName = SpUtil.preferences.getString('checkoutName');
    if (customerName != null) {
      takeawayDetail.customerName = customerName;
    }
    WidgetsBinding.instance
        .addPostFrameCallback((_) => _getPickupTimeOptions());
  }

  void showInSnackBar(String value) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(value),
    ));
  }

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();


  Future<void> _handleSubmitted() async {
    final form = _formKey.currentState!;
    if (!form.validate() || selectedPickupTimeOptions == null) {
      showInSnackBar(
        'Oops! can not submit order.',
      );
    } else {
      form.save();
      final ProgressDialog pr = ProgressDialog(context: context);
      var cart = Provider.of<CartModel>(context, listen: false);
      cart.createOrder(context, takeawayDetail: takeawayDetail);
      await pr.show(
        msg: 'Submitting...',
        borderRadius: 10.0,
        backgroundColor: Colors.white,
        elevation: 10.0,
      );

      // save form info
      SharedPreferencesUtil.setStringItem(
          'checkoutName', takeawayDetail.customerName!);
      SharedPreferencesUtil.setStringItem(
          'checkoutMobile', takeawayDetail.phone!);
    }
  }

  String? _validateName(String? value) {
    if (value!.isEmpty) {
      return 'Please enter name';
    }
    return null;
  }

  String? _validatePhoneNumber(String? value) {
    final phoneExp = RegExp(r'^\d\d\d\d\d\d\d\d\d\d$');
    if (!phoneExp.hasMatch(value!)) {
      return 'invalid phone number';
    }
    return null;
  }

  void _getPickupTimeOptions() {
    var cart = Provider.of<CartModel>(context, listen: false);
    // validate delivery range

    var _pickupTimeOptions =
        getTakeAwayTimeOptions(cart.storeDetail!.businessHour!);
    if (_pickupTimeOptions != null) {
      setState(() {
        pickupTimeOptions = _pickupTimeOptions;
        selectedPickupTimeOptions = _pickupTimeOptions[0];
        takeawayDetail.pickUpTime = _pickupTimeOptions[0].pickUpTime;
      });
    } else {
      showInSnackBar(
        'Oops! Pick-up is not available right now.',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // final cursorColor = Theme.of(context).cursorColor;
    final cursorColor = Theme.of(context).primaryColor;
    const sizedBoxSpace = SizedBox(height: 24);
    final textTheme = Theme.of(context).textTheme;
    var cart = Provider.of<CartModel>(context, listen: false);
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
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                sizedBoxSpace,
                Text(
                  '* Select pick-up time',
                  style: textTheme.caption,
                ),
                SizedBox(
                  height: 10,
                ),
                Container(
                    child: pickupTimeOptions.length > 0
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
                                child: DropdownButton<TakeawayTimeOption>(
                                  value: selectedPickupTimeOptions,
                                  iconSize: 24,
                                  underline: Container(
                                    height: 1,
                                    color: Colors.black54,
                                  ),
                                  onChanged: (TakeawayTimeOption? newValue) {
                                    setState(() {
                                      selectedPickupTimeOptions = newValue;
                                      takeawayDetail.pickUpTime =
                                          newValue!.pickUpTime;
                                    });
                                  },
                                  items: pickupTimeOptions.map<
                                          DropdownMenuItem<TakeawayTimeOption>>(
                                      (TakeawayTimeOption item) {
                                    return DropdownMenuItem<TakeawayTimeOption>(
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
                  initialValue: takeawayDetail.customerName,
                  textCapitalization: TextCapitalization.words,
                  cursorColor: cursorColor,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.white,
                    icon: const Icon(Icons.person),
                    labelText: AppLocalizations.of(context)!.name,
                  ),
                  onSaved: (value) {
                    takeawayDetail.customerName = value;
                  },
                  validator: _validateName,
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                ),
                sizedBoxSpace,
                TextFormField(
                  initialValue: takeawayDetail.phone,
                  cursorColor: cursorColor,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.white,
                    icon: const Icon(Icons.phone),
                    labelText: AppLocalizations.of(context)!.mobile,
                  ),
                  keyboardType: TextInputType.phone,
                  onSaved: (value) {
                    takeawayDetail.phone = value;
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
                        style: Theme.of(context)
                            .textTheme
                            .subtitle2!
                            .copyWith(fontSize: 16)),
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
                  style: textTheme.subtitle2!
                      .copyWith(color: Colors.white, fontSize: 18),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
