

import 'package:shared_preferences/shared_preferences.dart';

class SharedType {
  static const String STORE_ID = 'storeId';
  static const String TOKEN = 'accessToken';
  static const String NAME = 'fullName';
  static const String MOBILE = 'mobile';
  static const String LOGO = 'logoImgUrl';
  static const String TransactionId = 'transactionid';
}

class SharedPreferencesUtil {
  static Future<String?> getStringItem(String label) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? value = prefs.getString(label);
    return value;
  }

  static Future<void> setStringItem(String label, String value) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString(label, value);
  }

  static Future<bool?> getBoolItem(String label) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final bool? value = prefs.getBool(label);
    return value;
  }

  static Future<void> setBoolItem(String label, bool value) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool(label, value);
  }

  static Future<void> removeByLabel(String label) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.remove(label);
  }

  static Future<void> clear() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.clear();
  }
}
