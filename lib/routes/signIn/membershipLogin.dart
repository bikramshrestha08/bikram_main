import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:linkeat/routes/signIn/loginForm.dart';
import 'package:linkeat/routes/signIn/signupForm.dart';
import 'package:linkeat/utils/SharedPreferences_util.dart';
import '../../models/routeArguments.dart';
import '../../service/request.dart';

class MembershipLogin extends StatefulWidget {
  final bool resetToHome;
  final String storeId;

  static const routeName = '/membershipLogin';

  const MembershipLogin({
    Key? key,
    this.resetToHome = false,
    required this.storeId,
  }) : super(key: key);

  @override
  _MembershipLoginState createState() => _MembershipLoginState();
}

class _MembershipLoginState extends State<MembershipLogin> {
  bool _isLoading = true; // Loading state

  @override
  void initState() {
    super.initState();
    _checkTokenAndRedirect();
  }

  void showInSnackBar(String value) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(value),
    ));
  }

  Future<bool> isMemberOfCurrentStore(String storeId, String mobile) async {
    try {
      final dynamic validationResult = await Services.asyncRequest(
        'GET',
        '/store/v2/$storeId/member/mobile',
        context,
        params: {
          'mobile': mobile,
          'storeId': storeId,
        },
      );
      return json.decode(validationResult.toString())['member'] != null;
    } catch (e) {
      return false;
    }
  }

  Future<void> registerMembership(
      String storeId, String userId, String fullName, String mobile, String email, String name) async {
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

  Future<void> _checkTokenAndRedirect() async {
    String? accessToken = await SharedPreferencesUtil.getStringItem('accessToken');
    if (accessToken != null) {
      final dynamic profileRes = await Services.asyncRequest('GET', '/account/', context);
      final profileData = json.decode(profileRes.toString());
      final String fullName = profileData['fullName'];
      final String mobile = profileData['mobile'];
      final String email = profileData['email'] ?? 'default@email.com';
      final String userId = profileData['uuid'];
      SharedPreferencesUtil.setStringItem('STORE_ID', widget.storeId);

      bool isMember = await isMemberOfCurrentStore(widget.storeId, mobile);
      if (isMember) {
        showInSnackBar('You are a member of the current store!');
      } else {
        await registerMembership(widget.storeId, userId, fullName, mobile, email, fullName);
        showInSnackBar('You are now a member of the current store!');
      }
      Navigator.pushNamed(
        context,
        '/storeHome',
        arguments: StoreHomeArguments(widget.storeId),
      );
    } else {
      setState(() {
        _isLoading = false; // Set loading to false after the check is complete
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      // Display a loading indicator or a blank screen while checking the token
      return Scaffold(
        body: Center(
          child: CircularProgressIndicator(), // Or some other appropriate loader
        ),
      );
    }

    // Once loading is complete, show the actual UI
    final tabs = ['Login', 'Sign Up'];
    final textTheme = Theme.of(context).textTheme;

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          iconTheme: IconThemeData(color: Colors.black87),
          title: Text(
            'Account',
            style: textTheme.headline5,
          ),
          bottom: TabBar(
            labelColor: Colors.black87,
            isScrollable: true,
            tabs: [
              for (final tab in tabs)
                Tab(
                  child: Text(tab, style: textTheme.subtitle2),
                ),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            LoginForm(resetToHome: widget.resetToHome, storeId: widget.storeId),
            SignupForm(resetToHome: widget.resetToHome, storeId: widget.storeId),
          ],
        ),
      ),
    );
  }
}

