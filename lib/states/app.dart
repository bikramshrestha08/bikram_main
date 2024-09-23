import 'package:linkeat/service/request.dart';
import 'package:linkeat/utils/sputil.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';

class AppModel extends ChangeNotifier {
  Locale? locale = Locale('en', '');
  String? fcmToken;
  String? accessToken;

  AppModel({this.locale, this.fcmToken});

  void setLocale(Locale newLocale) {
    locale = newLocale;
    notifyListeners();
  }

  void updateFcmToken(String token, BuildContext context) {
    if (token != fcmToken && token != null) {
      fcmToken = token;
      if (accessToken != null) {
        _subscribeFCMToken(context);
      }
    }
  }

  void updateAccessToken(String token, BuildContext context) {
    if (token != accessToken && token != null) {
      accessToken = token;
      if (fcmToken != null) {
        _subscribeFCMToken(context);
      }
    }
  }

  Future<void> _subscribeFCMToken(BuildContext context) async {
    print("userToken: $accessToken");
    print("fcmToken: $fcmToken");
    await Services.asyncRequest(
        'POST', '/store/v3/notification/subscription', context,
        payload: {
          'token': fcmToken,
        });
  }

  String getLanguageCode() {
    if (locale == Locale.fromSubtags(languageCode: 'zh')) return 'ZH_CN';
    return 'EN_US';
  }
}
