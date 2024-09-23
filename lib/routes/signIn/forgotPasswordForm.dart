import 'dart:async';

import 'package:eva_icons_flutter/eva_icons_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/gestures.dart' show DragStartBehavior;

import 'package:linkeat/l10n/localizations.dart';
import 'package:linkeat/service/request.dart';

class ForgotPasswordForm extends StatefulWidget {
  const ForgotPasswordForm({Key? key}) : super(key: key);

  @override
  _ForgotPasswordFormState createState() => _ForgotPasswordFormState();
}

class _ForgotPasswordFormState extends State<ForgotPasswordForm> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  String? mobile;
  String? otp;
  int count = 0;

//  @override
//  void initState() {
//    super.initState();
//    _initPackageInfo();
//  }

  // void showInSnackBar(String value) {
  //   _scaffoldKey.currentState.hideCurrentSnackBar();
  //   _scaffoldKey.currentState.showSnackBar(SnackBar(
  //     content: Text(value),
  //   ));
  // }
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

  void _sentOtp() {
    if (mobile == null || mobile!.length != 10) {
      showInSnackBar(
        'Oops! Please check your mobile.',
      );
      return;
    }
    _sendOtpRequest(mobile);
    count = 5;
    new Timer.periodic(new Duration(seconds: 1), (time) {
      setState(() {
        count = count - 1;
      });
      if (count == 0) {
        time.cancel();
      }
    });
  }

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  void _handleSubmitted() {
    final form = _formKey.currentState!;
    if (!form.validate()) {
      showInSnackBar(
        'Oops! Please check your input.',
      );
    } else {
      form.save();
      _forgotPassword();
    }
  }

  String? _validatePhoneNumber(String? value) {
    final phoneExp = RegExp(r'^\d\d\d\d\d\d\d\d\d\d$');
    if (!phoneExp.hasMatch(value!)) {
      return 'invalid phone number';
    }
    return null;
  }

  String? _validateOtp(String? value) {
    if (value!.isEmpty) {
      return 'Please enter verify code';
    }
    return null;
  }

  Future<void> _forgotPassword() async {
    await Services.asyncRequest(
        'POST', '/account/manage/forget-password', context,
        payload: {
          'mobile': mobile,
        },
        otp: otp);
    showInSnackBar(
      'Sent password sucessfully.',
    );
    Navigator.of(context).pop();
  }

  Future<void> _sendOtpRequest(String? mobile) async {
    await Services.asyncRequest(
        'POST', '/account/manage/otp-request/mobile', context,
        payload: {
          'mobile': mobile,
        });
    showInSnackBar(
      'Sent verfiy code sucessfully.',
    );
  }

  @override
  Widget build(BuildContext context) {
    // final cursorColor = Theme.of(context).cursorColor;
    final cursorColor = Theme.of(context).primaryColor;
    const sizedBoxSpace = SizedBox(height: 24);
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;
    return Scaffold(
      backgroundColor: Colors.white,
      key: _scaffoldKey,
      body: Form(
        key: _formKey,
        child: Scrollbar(
          child: SingleChildScrollView(
            dragStartBehavior: DragStartBehavior.down,
            padding: const EdgeInsets.symmetric(horizontal: 30),
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 10.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  sizedBoxSpace,
                  sizedBoxSpace,
                  TextFormField(
                    textCapitalization: TextCapitalization.words,
                    cursorColor: cursorColor,
                    maxLength: 10,
                    keyboardType: TextInputType.phone,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.white,
                      icon: Icon(EvaIcons.phoneOutline),
                      labelText: AppLocalizations.of(context)!.mobile,
                    ),
                    onChanged: (value) {
                      mobile = value;
                    },
                    validator: _validatePhoneNumber,
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                  ),
                  sizedBoxSpace,
                  TextFormField(
                    textCapitalization: TextCapitalization.words,
                    cursorColor: cursorColor,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.white,
                      icon: const Icon(EvaIcons.lockOutline),
                      labelText: AppLocalizations.of(context)!.verifyCode,
                    ),
                    onSaved: (value) {
                      otp = value;
                    },
                    validator: _validateOtp,
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                  ),
                  sizedBoxSpace,
                  Container(
                    child: count == 0
                        ? Center(
                            child: OutlinedButton(
                              // highlightedBorderColor: Colors.grey[400],
                              // highlightColor: Colors.grey[200],
                              // shape: RoundedRectangleBorder(
                              //     borderRadius: BorderRadius.circular(30.0)),
                              child: Text(
                                AppLocalizations.of(context)!.sendVerifyCode!,
                                style: textTheme.bodyText2,
                              ),
                              onPressed: _sentOtp,
                            ),
                          )
                        : Center(
                            child: ElevatedButton(
                              child: Text(count.toString()),
                              onPressed: null,
                            ),
                          ),
                  ),
                  sizedBoxSpace,
                  Center(
                    child: SizedBox(
                      width: 200.0,
                      height: 45,
                      child: ElevatedButton(
                        // padding: EdgeInsets.all(10),
                        // color: colorScheme.primary,
                        child: Text(AppLocalizations.of(context)!.submit!,
                            style: textTheme.button!
                                .copyWith(color: Colors.white)),
                        onPressed: _handleSubmitted,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
