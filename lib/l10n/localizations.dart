import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class AppLocalizations {
  AppLocalizations(this.locale);

  final Locale locale;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static Map<String, Map<String, String>> _localizedValues = {
    'en': {
      'popularInTown': 'Popular In Town',
      'home': 'Home',
      'search': 'Search',
      'order': 'Order',
      'account': 'Account',
      'takeaway': 'Pick Up',
      'booking' : 'Booking',
      'delivery': 'Delivery',
      'viewCart': 'View Cart',
      'username': 'Username',
      'mobile': 'Mobile Number',
      'password': 'Password',
      'confirmPassword': 'Confirm Password',
      'submit': 'Submit',
      'forgotPassword': 'Forgot Password',
      'login': 'Login',
      'signUp': 'Sign Up',
      'verifyCode': 'Verify Code',
      'sendVerifyCode': 'Send Verify Code',
      'optionPick': 'Pick',
      'optionItem': 'Item(s)',
      'addToCart': 'Add to Cart',
      'payment': 'Payment',
      'total': 'Total',
      'payOnDelivery': 'Pay On Delivery',
      'bankTransfer': 'Bank Transfer',
      'windcave': 'WindCave Payment',
      'uploadScreenshot': 'Upload Screenshot',
      'myOrders': 'My Orders',
      'orderStatus': 'Order Status',
      'orderComplete': 'Order Complete',
      'checkout': 'Checkout',
      'cart': 'Cart',
      'submitOrder': 'Submit Order',
      'deliveryFee': 'Delivery Fee',
      'city': 'City',
      'address': 'Address',
      'name': 'Name',
      'postCode': 'postCode',
      'logout': 'Log Out',
      'backToHome': 'Back To Home',
      'language': 'Language',
      'selectLanguage': 'Select Language',
      'storeClosed': 'CLOSED',
      'noData': 'No More Data',
      'storeMap': 'Store Address',
      'pickupNotAvailable': 'Oops! Pick-up is not available right now.',
      'deliveryNotAvailable': 'Oops! Delivery is not available right now.',
      'postCodeNotAvailable': 'Oops! PostCode is not available.',
      'deliveryMinOrderError': 'Oops! Not meet minimal order amount.',
      'tapBackAgainForExit': 'Tap back again to exit app',
      'fullName': 'Full Name',
      'createAccount': 'Create Account',
      'tc': 'Terms and Conditions',
      'orderAgain': 'Order Again',
      'itemModified': 'Information of some items have been modified, please add them to cart again.',
      'storeNotFound': 'Store not found.',
      'confirm': 'Confirm',
      'notification': 'Notification',
      // PENDING, PROCESSING, COMPLETED, DISPATCHED, DELIVERED, DECLINED, CANCELLED
      'PENDING': 'Await confirmation',
      'PROCESSING': 'Processing',
      'COMPLETED': 'Ready for pick up', // only for takeaway
      'DISPATCHED': 'Dispatched',
      'DELIVERED': 'Delivered',
      'DECLINED': 'Declined',
      'CANCELLED': 'Cancelled',
      'PICKUP': 'Pick Up',
      'COLLECTED': 'Order completed',
    },
    'zh': {
      'popularInTown': '热门店铺',
      'home': '首页',
      'search': '搜索',
      'order': '订单',
      'account': '账户',
      'takeaway': '自取',
      'delivery': '送餐',
      'viewCart': '购物车',
      'username': '用户名',
      'mobile': '手机号码',
      'password': '密码',
      'confirmPassword': '确认密码',
      'submit': '提交',
      'forgotPassword': '忘记密码',
      'login': '登录',
      'signUp': '注册',
      'verifyCode': '验证码',
      'sendVerifyCode': '发送验证码',
      'optionPick': '选择',
      'optionItem': '项',
      'addToCart': '添加至购物车',
      'payment': '支付',
      'total': '合计',
      'payOnDelivery': '货到付款',
      'bankTransfer': '银行转账',
      'windcave': 'Windcave支付',
      'uploadScreenshot': '上传转账截图',
      'myOrders': '我的订单',
      'orderStatus': '订单状态',
      'orderComplete': '订单成功',
      'checkout': '结算',
      'cart': '购物车',
      'booking': '预定',
      'submitOrder': '提交订单',
      'deliveryFee': '快递费',
      'city': '城市',
      'address': '地址',
      'name': '姓名',
      'postCode': '邮编',
      'logout': '退出登录',
      'backToHome': '返回首页',
      'language': '语言',
      'selectLanguage': '选择语言',
      'storeClosed': '已关店',
      'noData': 'No More Data',
      'storeMap': '地址',
      'pickupNotAvailable': 'Oops! 自取服务暂时不能使用.',
      'deliveryNotAvailable': 'Oops! 送餐服务暂时不能使用.',
      'postCodeNotAvailable': 'Oops! PostCode暂时不能使用.',
      'deliveryMinOrderError': 'Oops! 为达到最新最小订单金额.',
      'tapBackAgainForExit': '再次后退关闭app',
      'fullName': '姓名',
      'createAccount': '创建新的账户',
      'tc': 'Terms and Conditions',
      'orderAgain': '再来一单',
      'itemModified': '部分商品信息已变更，需重新加入购物车.',
      'storeNotFound': '未找到该店铺.',
      'confirm': '确认',
      'notification': '提示',
      // PENDING, PROCESSING, COMPLETED, DISPATCHED, DELIVERED, DECLINED, CANCELLED
      'PENDING': '等待接单',
      'PROCESSING': '努力备餐中',
      'COMPLETED': '请尽快取餐', // only for takeaway
      'DISPATCHED': '派送中',
      'DELIVERED': '已送达',
      'DECLINED': '已拒绝',
      'CANCELLED': '已取消',
      'PICKUP': '取餐',
      'COLLECTED': '订单已完成'
    },
  };

  String? get popularInTown {
    return _localizedValues[locale.languageCode]!['popularInTown'];
  }

  String? get home {
    return _localizedValues[locale.languageCode]!['home'];
  }

  String? get search {
    return _localizedValues[locale.languageCode]!['search'];
  }

  String? get order {
    return _localizedValues[locale.languageCode]!['order'];
  }

  String? get account {
    return _localizedValues[locale.languageCode]!['account'];
  }

  String? get takeaway {
    return _localizedValues[locale.languageCode]!['takeaway'];
  }

  String? get delivery {
    return _localizedValues[locale.languageCode]!['delivery'];
  }

  String? get viewCart {
    return _localizedValues[locale.languageCode]!['viewCart'];
  }

  String? get username {
    return _localizedValues[locale.languageCode]!['username'];
  }

  String? get mobile {
    return _localizedValues[locale.languageCode]!['mobile'];
  }

  String? get password {
    return _localizedValues[locale.languageCode]!['password'];
  }

  String? get confirmPassword {
    return _localizedValues[locale.languageCode]!['confirmPassword'];
  }

String? get windcave {
  return _localizedValues[locale.languageCode]!['windcave'];
}

  String? get submit {
    return _localizedValues[locale.languageCode]!['submit'];
  }

  String? get forgotPassword {
    return _localizedValues[locale.languageCode]!['forgotPassword'];
  }

  String? get login {
    return _localizedValues[locale.languageCode]!['login'];
  }

  String? get signUp {
    return _localizedValues[locale.languageCode]!['signUp'];
  }

  String? get verifyCode {
    return _localizedValues[locale.languageCode]!['verifyCode'];
  }

  String? get sendVerifyCode {
    return _localizedValues[locale.languageCode]!['sendVerifyCode'];
  }

  String? get optionPick {
    return _localizedValues[locale.languageCode]!['optionPick'];
  }

  String? get optionItem {
    return _localizedValues[locale.languageCode]!['optionItem'];
  }

  String? get addToCart {
    return _localizedValues[locale.languageCode]!['addToCart'];
  }

  String? get payment {
    return _localizedValues[locale.languageCode]!['payment'];
  }

  String? get total {
    return _localizedValues[locale.languageCode]!['total'];
  }

  String? get bankTransfer {
    return _localizedValues[locale.languageCode]!['bankTransfer'];
  }

  String? get payOnDelivery {
    return _localizedValues[locale.languageCode]!['payOnDelivery'];
  }

  String? get uploadScreenshot {
    return _localizedValues[locale.languageCode]!['uploadScreenshot'];
  }

  String? get myOrders {
    return _localizedValues[locale.languageCode]!['myOrders'];
  }

  String? get orderStatus {
    return _localizedValues[locale.languageCode]!['orderStatus'];
  }

  String? get orderComplete {
    return _localizedValues[locale.languageCode]!['orderComplete'];
  }

  String? get checkout {
    return _localizedValues[locale.languageCode]!['checkout'];
  }

  String? get cart {
    return _localizedValues[locale.languageCode]!['cart'];
  }

  String? get submitOrder {
    return _localizedValues[locale.languageCode]!['submitOrder'];
  }

  String? get deliveryFee {
    return _localizedValues[locale.languageCode]!['deliveryFee'];
  }

  String? get city {
    return _localizedValues[locale.languageCode]!['city'];
  }

  String? get address {
    return _localizedValues[locale.languageCode]!['address'];
  }

  String? get name {
    return _localizedValues[locale.languageCode]!['name'];
  }

  String? get postCode {
    return _localizedValues[locale.languageCode]!['postCode'];
  }

  String? get logout {
    return _localizedValues[locale.languageCode]!['logout'];
  }

  String? get backToHome {
    return _localizedValues[locale.languageCode]!['backToHome'];
  }

  String? get language {
    return _localizedValues[locale.languageCode]!['language'];
  }

  String? get selectLanguage {
    return _localizedValues[locale.languageCode]!['selectLanguage'];
  }

  String? get storeClosed {
    return _localizedValues[locale.languageCode]!['storeClosed'];
  }

  String? get noData {
    return _localizedValues[locale.languageCode]!['noData'];
  }

  String? get storeMap {
    return _localizedValues[locale.languageCode]!['storeMap'];
  }

  String? get pickupNotAvailable {
    return _localizedValues[locale.languageCode]!['pickupNotAvailable'];
  }

  String? get deliveryNotAvailable {
    return _localizedValues[locale.languageCode]!['deliveryNotAvailable'];
  }

  String? get postCodeNotAvailable {
    return _localizedValues[locale.languageCode]!['postCodeNotAvailable'];
  }

  String? get deliveryMinOrderError {
    return _localizedValues[locale.languageCode]!['deliveryMinOrderError'];
  }

  String? get tapBackAgainForExit {
    return _localizedValues[locale.languageCode]!['tapBackAgainForExit'];
  }

  String? get fullName {
    return _localizedValues[locale.languageCode]!['fullName'];
  }

  String? get booking {
    return _localizedValues[locale.languageCode]!['booking'];
  }

  String? get createAccount {
    return _localizedValues[locale.languageCode]!['createAccount'];
  }

  String? get tc {
    return _localizedValues[locale.languageCode]!['tc'];
  }

  String? getByKey(String key) {
    return _localizedValues[locale.languageCode]![key];
  }

  String? get pick {
    return _localizedValues[locale.languageCode]!['PICKUP'];
  }

  String? get orderAgain {
    return _localizedValues[locale.languageCode]!['orderAgain'];
  }

  String? get itemModified {
    return _localizedValues[locale.languageCode]!['itemModified'];
  }

  String? get storeNotFound {
    return _localizedValues[locale.languageCode]!['storeNotFound'];
  }

  String? get confirm {
    return _localizedValues[locale.languageCode]!['confirm'];
  }

  String? get notification {
    return _localizedValues[locale.languageCode]!['notification'];
  }

}

class AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => ['en', 'zh'].contains(locale.languageCode);

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(AppLocalizations(locale));
  }

  @override
  bool shouldReload(AppLocalizationsDelegate old) => false;
}
