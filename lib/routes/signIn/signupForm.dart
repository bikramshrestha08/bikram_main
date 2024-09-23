import 'dart:convert';
import 'dart:async';

import 'package:linkeat/states/app.dart';
import 'package:eva_icons_flutter/eva_icons_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/gestures.dart' show DragStartBehavior;

import 'package:linkeat/l10n/localizations.dart';
import 'package:linkeat/service/request.dart';
import 'package:linkeat/utils/SharedPreferences_util.dart';
import 'package:provider/provider.dart';

import '../../models/routeArguments.dart';

class SignupForm extends StatefulWidget {
  final bool resetToHome;
  final String storeId;
  const SignupForm({Key? key, required this.resetToHome,required this.storeId}) : super(key: key);

  @override
  _SignupFormState createState() => _SignupFormState();
}

class _SignupFormState extends State<SignupForm> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  String? full_name;
  String? mobile_number;
  String? password;
  String? confirmPassword;
  String? otp;
  int count = 0;

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

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  Future<void> _handleSubmitted() async {
    final form = _formKey.currentState!;
    if (!form.validate()) {
      showInSnackBar(
        'Oops! Please check your input.',
      );
    } else {
      form.save();
      print(1);
      final dynamic response = await Services.asyncRequest(
          'POST', '/account/validateCode', context,
          payload: {
            "mobile_number": mobile_number,
          },
          otp: otp);
      var data = json.decode(response.toString());
      // print(data);
      if (password != confirmPassword) {
        showInSnackBar(
          'Oops! Please check password',
        );
      } else if (response == null) {
        showInSnackBar(
          'Code error',
        );
      } else {
        // print("sign up beginning");
        _signup(widget.storeId);
      }


//      var store = Provider.of<StoreModel>(context, listen: false);
//      store.createOrder(context, takeawayDetail: takeawayDetail);
    }
  }

  String? _validateUsername(String? value) {
    if (value!.isEmpty) {
      return 'Please enter username';
    }
    return null;
  }

  void _sentOtp() {
    if (mobile_number == null || mobile_number!.length != 10) {
      showInSnackBar(
        'Oops! Please check your mobile.',
      );
      return;
    }
    _sendOtpRequest(mobile_number);
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
  Future<void> _sendOtpRequest(String? mobile) async {
    await Services.asyncRequest(
        'POST', '/account/sendVerificationCode', context,
        payload: {
          'mobile_number': mobile,
        });
    showInSnackBar(
      'Sent verfiy code sucessfully.',
    );
  }
  String? _validateOtp(String? value) {
    if (value!.isEmpty) {
      return 'Please enter verify code';
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

  String? _validatePassword(String? value) {
    if (value!.isEmpty) {
      return 'Please enter password';
    }
    return null;
  }

  String? _validateConfirmPassword(String? value) {
    if (value!.isEmpty) {
      return 'Please enter confirm password';
    }
    return null;
  }
  Future<void> registerMembership(String storeId, String userId, String fullName, String mobile, String email, String name) async {
    await Services.asyncRequest('POST', '/store/v2/$storeId/member', context, payload: {
      'lastName': fullName,
      'firstName': name,
      'userId': userId,
      'mobile': mobile,
      'email': email,
      'store': storeId,
      'address': {
        'address1': '',
        'address2': '',
        'city': '',
        'postCode': '',
        'state': '',
      },
    });

  }
  Future<void> _signup(String storeId) async {
    // print("account register");
    await Services.asyncRequest('POST', '/account/register', context, payload: {
      'full_name': full_name,
      'password': password,
      'mobile_number': '+61${mobile_number}',
    });
    // print("account login");
    final dynamic response = await Services.asyncRequest(
        'POST', '/account/login/username', context,
        payload: {
          'username': '+61${mobile_number}',
          'password': password,
          'principle': 'MOBILE',
        });

    final String accessToken = json.decode(response.toString())['accessToken'];
    SharedPreferencesUtil.setStringItem('accessToken', accessToken);
    SharedPreferencesUtil.setStringItem('STORE_ID', storeId);
    var app = Provider.of<AppModel>(context, listen: false);
    app.updateAccessToken(accessToken, context);
    final dynamic profileRes =
    await Services.asyncRequest('GET', '/account/', context);
    print("profile start setting");
    final String fullName = json.decode(profileRes.toString())['fullName'];
    final String mobile = json.decode(profileRes.toString())['mobile'];
    final String email = json.decode(profileRes.toString())['email'] ?? 'default@example.com';
    final String userId = json.decode(profileRes.toString())['uuid'];
    SharedPreferencesUtil.setStringItem('fullName', fullName);
    SharedPreferencesUtil.setStringItem('mobile', mobile);
    print("profile setting");

    if (accessToken != null){
      await registerMembership(storeId, userId, fullName, mobile, email, fullName!);
    }
    if (widget.resetToHome) {
      showInSnackBar('You are now a member of the current store!');
      Navigator.pushNamed(
        context,
        '/storeHome',
        arguments: StoreHomeArguments(
          widget.storeId,
        ),
      );
    } else {
      Navigator.of(context).pop();
    }
  }

  _openTC() {
    Navigator.push<void>(
      context,
      MaterialPageRoute(
        builder: (context) => _FullScreenDialogTC(),
        fullscreenDialog: true,
      ),
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                sizedBoxSpace,
                TextFormField(
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  textCapitalization: TextCapitalization.words,
                  cursorColor: cursorColor,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.white,
                    icon: Icon(EvaIcons.personOutline),
                    labelText: AppLocalizations.of(context)!.fullName,
                  ),
                  onChanged: (value) {
                    full_name = value;
                  },
                  validator: _validateUsername,
                ),
                sizedBoxSpace,
                TextFormField(
                  textCapitalization: TextCapitalization.words,
                  cursorColor: cursorColor,
                  maxLength: 10,
                  keyboardType: TextInputType.phone,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.white,
                    icon: const Icon(EvaIcons.phoneOutline),
                    labelText: AppLocalizations.of(context)!.mobile,
                  ),
                  onChanged: (value) {
                    mobile_number = value;
                  },
                  validator: _validatePhoneNumber,
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                ),
                sizedBoxSpace,
                Row(
                  children: <Widget>[
                    Expanded(
                      flex: 3, // Adjust the flex factor as needed for spacing
                      child: TextFormField(
                        textCapitalization: TextCapitalization.words,
                        cursorColor: cursorColor,
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: Colors.white,
                          icon: const Icon(EvaIcons.checkmark),
                          labelText: AppLocalizations.of(context)!.verifyCode,
                        ),
                        onSaved: (value) {
                          otp = value;
                        },
                        validator: _validateOtp,
                        autovalidateMode: AutovalidateMode.onUserInteraction,
                      ),
                    ),
                    SizedBox(width: 10), // Space between the text field and the button
                    Expanded(
                      flex: 2, // Adjust the flex factor as needed for spacing
                      child: count == 0
                          ? OutlinedButton(
                        child: Text(
                          AppLocalizations.of(context)!.sendVerifyCode!,
                          style: textTheme.bodyText2,
                        ),
                        onPressed: _sentOtp,
                      )
                          : ElevatedButton(
                        child: Text(count.toString()),
                        onPressed: null, // Consider disabling the button in a different way if needed
                      ),
                    ),
                  ],
                ),
                sizedBoxSpace,
                TextFormField(
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  obscureText: true,
                  textCapitalization: TextCapitalization.words,
                  cursorColor: cursorColor,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.white,
                    icon: const Icon(EvaIcons.lockOutline),
                    labelText: AppLocalizations.of(context)!.password,
                  ),
                  onSaved: (value) {
                    password = value;
                  },
                  validator: _validatePassword,
                ),
                sizedBoxSpace,
                TextFormField(
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  obscureText: true,
                  textCapitalization: TextCapitalization.words,
                  cursorColor: cursorColor,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.white,
                    icon: const Icon(EvaIcons.lockOutline),
                    labelText: AppLocalizations.of(context)!.confirmPassword,
                  ),
                  onSaved: (value) {
                    confirmPassword = value;
                  },
                  validator: _validateConfirmPassword,
                ),
                sizedBoxSpace,
                sizedBoxSpace,
                GestureDetector(
                  // When the child is tapped, show a snackbar.
                  onTap: _openTC,
                  // The custom button
                  child: Container(
                    padding: EdgeInsets.fromLTRB(20, 0, 20, 5),
                    child: Text(
                      'Terms and Conditions',
                      style: TextStyle(
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                ),
                Container(
                  padding: EdgeInsets.fromLTRB(20, 5, 20, 20),
                  child: Text(
                      'By tapping "Create Account" you agree to the terms and conditions.',
                      style: textTheme.caption),
                ),
                Center(
                  child: SizedBox(
                    width: 250.0,
                    height: 60,
                    child: TextButton(
                      style: TextButton.styleFrom(
                        backgroundColor: colorScheme.primary,
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding: EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: Text(
                        AppLocalizations.of(context)!.createAccount!,
                        style: textTheme.button!.copyWith(
                          color: Colors.white, // Set text color to white
                          fontSize: 20, // Increase font size
                        ),
                      ),
                      onPressed: _handleSubmitted,
                    ),
                  ),
                ),

              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _FullScreenDialogTC extends StatelessWidget {
  // const _FullScreenDialogStoreMap({
  //   this.mapContent,
  // });

  // final String mapContent;

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
          AppLocalizations.of(context)!.tc!,
          style: textTheme.headline5,
        ),
      ),
      body: Container(
        padding: EdgeInsets.all(15),
        child: Text('Terms and Conditions'),
      ),
    );
  }
}

