import 'dart:async';

import 'package:eva_icons_flutter/eva_icons_flutter.dart';
import 'package:flutter/material.dart';

// import 'package:package_info/package_info.dart';
import 'package:provider/provider.dart';

import 'package:linkeat/l10n/localizations.dart';
import 'package:linkeat/utils/SharedPreferences_util.dart';
import 'package:linkeat/states/app.dart';
import 'package:linkeat/routes/signIn/login.dart';

class Account extends StatefulWidget {
  Account({Key? key}) : super(key: key);

  @override
  _AccountState createState() => _AccountState();
}

class _AccountState extends State<Account> {
  bool isLogin = false;
  String? showName;
  String? showMobile;
  // PackageInfo _packageInfo = PackageInfo(
  //   appName: 'Unknown',
  //   packageName: 'Unknown',
  //   version: 'Unknown',
  //   buildNumber: 'Unknown',
  // );

  @override
  void initState() {
    super.initState();
    _initPackageInfo();
    _initLoginStatus();
  }

  Future<void> _initPackageInfo() async {
    // final PackageInfo info = await PackageInfo.fromPlatform();

    // setState(() {
    //   _packageInfo = info;
    // });
  }

  Future<void> _initLoginStatus() async {
    final String? accessToken =
        await SharedPreferencesUtil.getStringItem(SharedType.TOKEN);
    final String? name =
        await SharedPreferencesUtil.getStringItem(SharedType.NAME);
    final String? mobile =
        await SharedPreferencesUtil.getStringItem(SharedType.MOBILE);
    setState(() {
      isLogin = accessToken == null ? false : true;
      showName = name;
      showMobile = mobile;

    });
  }

  void _login() {
    Navigator.of(context)
        .push(new MaterialPageRoute<String>(builder: (context) => Login()))
        .then((String? value) {
      _initLoginStatus();
    });
  }

  void _logout() {
    SharedPreferencesUtil.clear();
    setState(() {
      isLogin = false;
    });
  }

  void _membership(){

  }

  Future<void> _showMyDialog() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
//          title: Text('AlertDialog Title'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('Would you like to log out?'),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              // textColor: Theme.of(context).colorScheme.primary,
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              // textColor: Theme.of(context).colorScheme.primary,
              child: Text('Confirm'),
              onPressed: () {
                Navigator.of(context).pop();
                _logout();
              },
            ),
          ],
        );
      },
    );
  }

  void _selectLanguage(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      builder: (context) {
        return _BottomSheetChangeLanguage();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Container(
      color: Colors.white,
      child: Padding(
        padding: EdgeInsets.all(20.0),
        child: Column(
          children: <Widget>[
            Padding(
              padding: EdgeInsets.symmetric(vertical: 50.0),
              child: Center(
                child: Column(
                  children: <Widget>[
                    Icon(
                      EvaIcons.personOutline,
                      size: 100.0,
                      color: Colors.grey[300],
                    ),
                    SizedBox(
                      height: 10.0,
                    ),
                    Container(
                      child: isLogin
                          ? Column(
                        children: [
                          Text(showName!),
                          Text(showMobile!),
                        ],
                      )
                          : SizedBox(
                              width: 150,
                              height: 45,
                              child: OutlinedButton(
                                // highlightedBorderColor: Colors.grey[400],
                                // highlightColor: Colors.grey[200],
                                // shape: RoundedRectangleBorder(
                                //     borderRadius: BorderRadius.circular(30.0)),
                                child: Text(
                                  AppLocalizations.of(context)!.login!,
                                  style: textTheme.button,
                                ),
                                onPressed: () {
                                  _login();
                                },
                              ),
                            ),
                    ),
                  ],
                ),
              ),
            ),
            Divider(),
            Container(
              child: InkWell(
                onTap: () {
                  _selectLanguage(context);
                },
                child: Container(
//                  color: Colors.grey[50],
                  height: 40,
                  child: Row(
                    children: <Widget>[
                      Icon(
                        EvaIcons.globe2Outline,
                        size: 30.0,
                        color: Colors.grey[400],
                      ),
                      SizedBox(
                        width: 15.0,
                      ),
                      Text(AppLocalizations.of(context)!.language!),
                    ],
                  ),
                ),
              ),
            ),
            Divider(),
            Container(
                child: isLogin
                    ? InkWell(
                        onTap: () {
                          _showMyDialog();
                        },
                        child: Container(
//                    color: Colors.,
                          height: 40,
                          child: Row(
                            children: <Widget>[
                              Icon(
                                EvaIcons.logOutOutline,
                                size: 30.0,
                                color: Colors.grey[400],
                              ),
                              SizedBox(
                                width: 15.0,
                              ),
                              Text(AppLocalizations.of(context)!.logout!),
                            ],
                          ),
                        ),
                      )
                    : SizedBox.shrink()),
            Container(
              child: isLogin ? Divider() : SizedBox.shrink(),
            ),
            SizedBox(
              height: 10.0,
            ),
            Center(
              child: Text('Ver.', style: textTheme.caption),
              // Text('Ver.${_packageInfo.version}', style: textTheme.caption),
            ),
          ],
        ),
      ),
    );
  }
}

class _BottomSheetChangeLanguage extends StatelessWidget {
  final List<String> supportLanguages = ['en', 'zh'];

  @override
  Widget build(BuildContext context) {
    var app = Provider.of<AppModel>(context);
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      color: Colors.grey[50],
      height: 210,
      child: Column(
        children: [
          Container(
            height: 60,
            child: Center(
              child: Text(
                AppLocalizations.of(context)!.selectLanguage!,
                textAlign: TextAlign.center,
                style: textTheme.subtitle2,
              ),
            ),
          ),
          const Divider(thickness: 1),
          Expanded(
            child: Padding(
              padding: EdgeInsets.all(10.0),
              child: Column(
                children: <Widget>[
                  GestureDetector(
                    onTap: () {
                      Navigator.of(context).pop();
                      app.setLocale(Locale('en', ''));
                      SharedPreferencesUtil.setStringItem('locale', 'en');
                    },
                    child: Container(
                      color: Colors.grey[50],
                      height: 40.0,
                      child: Row(
                        children: <Widget>[
                          Text('English'),
                          Expanded(
                            child: Align(
                              alignment: Alignment.centerRight,
                              child: app.locale == Locale('en', '')
                                  ? Icon(
                                      EvaIcons.checkmarkCircle2Outline,
                                      color: colorScheme.primary,
                                      size: 24.0,
                                    )
                                  : SizedBox.shrink(),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Divider(
                    color: Colors.grey[400],
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.of(context).pop();
                      app.setLocale(Locale.fromSubtags(languageCode: 'zh'));
                      SharedPreferencesUtil.setStringItem('locale', 'zh');
                    },
                    child: Container(
                      height: 40.0,
                      color: Colors.grey[50],
                      child: Row(
                        children: <Widget>[
                          Text('简体中文'),
                          Expanded(
                            child: Align(
                              alignment: Alignment.centerRight,
                              child: app.locale ==
                                      Locale.fromSubtags(languageCode: 'zh')
                                  ? Icon(
                                      EvaIcons.checkmarkCircle2Outline,
                                      color: colorScheme.primary,
                                      size: 24.0,
                                    )
                                  : SizedBox.shrink(),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
