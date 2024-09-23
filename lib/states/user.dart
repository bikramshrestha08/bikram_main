

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';

class UserModel extends ChangeNotifier {
  String? _token;

  UserModel();

  void setToken(String token) {
    _token = token;
    notifyListeners();
  }

  String? getToken() {
    return _token;
  }
}
