

import 'package:shared_preferences/shared_preferences.dart';
// import 'package:package_info/package_info.dart';

class SpUtil {
  static late SharedPreferences preferences;
  // static PackageInfo packageInfo;
  static Future<bool> getInstance() async {
    preferences = await SharedPreferences.getInstance();
    // packageInfo = await PackageInfo.fromPlatform();
    return true;
  }
}
