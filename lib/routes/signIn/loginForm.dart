import 'dart:convert';

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

class LoginForm extends StatefulWidget {
  final bool resetToHome;
  final String storeId;
  const LoginForm({Key? key, required this.resetToHome, required this.storeId}) : super(key: key);

  @override
  _LoginFormState createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  String? username;
  String? password;

  void showInSnackBar(String value) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(value),
    ));
  }

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  void _handleSubmitted() {
    final form = _formKey.currentState!;
    if (!form.validate()) {
      showInSnackBar('Oops! can not submit.');
    } else {
      form.save();
      _login(widget.storeId);
    }
  }

  String? _validateUsername(String? value) {
    if (value!.isEmpty) {
      return 'Please enter username';
    }
    return null;
  }

  String? _validatePassword(String? value) {
    if (value!.isEmpty) {
      return 'Please enter password';
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

  Future<bool> isMemberOfCurrentStore(String storeId, String mobile) async {
    try {
      final dynamic validationResult =
      await Services.asyncRequest(
          'GET', '/store/v2/$storeId/member/mobile', context,
          params: {
            'mobile': mobile,
            'storeId': storeId,
          });
      if (json.decode(validationResult.toString())['member'] != null) {
        return true;
      }
      return false;
    }
    catch(e) {
    return false;

    }
  }



  Future<void> _login(String storeId) async {
    final dynamic response = await Services.asyncRequest('POST', '/account/login/username', context, payload: {
      'username': '+61${username}',
      'password': password,
      'principle': 'MOBILE',
    });

    final String accessToken = json.decode(response.toString())['accessToken'];
    SharedPreferencesUtil.setStringItem('accessToken', accessToken);
    SharedPreferencesUtil.setStringItem('STORE_ID', storeId);
    var app = Provider.of<AppModel>(context, listen: false);
    app.updateAccessToken(accessToken, context);

    final dynamic profileRes = await Services.asyncRequest('GET', '/account/', context);
    final String fullName = json.decode(profileRes.toString())['fullName'];
    final String mobile = json.decode(profileRes.toString())['mobile'];
    final String email = json.decode(profileRes.toString()) != null ? json.decode(profileRes.toString())['email'] ?? "default@email.com" : "default@email.com";
    final String userId = json.decode(profileRes.toString())['uuid'];

    SharedPreferencesUtil.setStringItem('fullName', fullName);
    SharedPreferencesUtil.setStringItem('mobile', mobile);

    if (accessToken != null) {
      bool isMember = await isMemberOfCurrentStore(storeId, mobile);
      if (isMember) {
        showInSnackBar('You are a member of the current store!');
      } else {
        await registerMembership(storeId, userId, fullName, mobile, email, username!);
        showInSnackBar('You are now a member of the current store!');
      }
    } else {
      showInSnackBar('Login failed. Please try again.');
    }
    if (widget.resetToHome) {
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

  @override
  Widget build(BuildContext context) {
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
                  onSaved: (value) {
                    username = value;
                  },
                  validator: _validateUsername,
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                ),
                sizedBoxSpace,
                TextFormField(
                  obscureText: true,
                  textCapitalization: TextCapitalization.words,
                  cursorColor: cursorColor,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.white,
                    icon: Icon(EvaIcons.lockOutline),
                    labelText: AppLocalizations.of(context)!.password,
                  ),
                  onSaved: (value) {
                    password = value;
                  },
                  validator: _validatePassword,
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                ),
                sizedBoxSpace,
                sizedBoxSpace,
                Center(
                  child: SizedBox(
                    width: 200.0,
                    height: 45,
                    child: TextButton(
                      child: Text(AppLocalizations.of(context)!.login!, style: textTheme.button!.copyWith(color: Colors.black)),
                      onPressed: _handleSubmitted,
                    ),
                  ),
                ),
                sizedBoxSpace,
                Center(
                  child: TextButton(
                    child: Text(AppLocalizations.of(context)!.forgotPassword!, style: textTheme.bodyText2!.copyWith(color: Colors.grey[600])),
                    onPressed: () {
                      Navigator.pushNamed(context, '/forgotPassword');
                    },
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
