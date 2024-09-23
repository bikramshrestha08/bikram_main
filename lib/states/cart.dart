import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';

import 'package:enum_to_string/enum_to_string.dart';

import 'package:linkeat/models/routeArguments.dart';
import 'package:linkeat/service/request.dart';
import 'package:linkeat/models/store.dart' as StoreDTO;
import 'package:linkeat/models/order.dart';

class CartModel extends ChangeNotifier {
  StoreDTO.StoreDetail? _storeDetail;
  List<StoreDTO.Category>? _categories;
  List<StoreDTO.Record>? _record;
  List<CartItem> _cartItems = [];
  OrderType? _type;

  CartModel();

  StoreDTO.StoreDetail? get storeDetail => _storeDetail;
  List<StoreDTO.Category>? get categories => _categories;
  List<StoreDTO.Record>? get record => _record;
  OrderType? get type => _type;

  List<CartItem> get cartItems => _cartItems;

  Future<StoreDTO.StoreDetail?> fetchStoreDetail(
      String? uuid, String languageCode, BuildContext context) async {
    final dynamic response = await Services.asyncRequest(
        'GET', '/store/profile/${uuid}/menu', context);
    var data = json.decode(response.toString());
//    var newStore = StoreDTO.Store.fromJson(data);
    _storeDetail = StoreDTO.StoreDetail.fromJson(data['storeSummary']);
//    _categories = newStore.categories;

//    final dynamic menuRes = await Services.asyncRequest('GET',
//        '/store/v1/profile/${uuid}/menu?language=${languageCode}', context);
//    var menuData = json.decode(menuRes.toString());
//    _categories = new List<dynamic>.from(menuData['categories'])
//        .map((item) => StoreDTO.Category.fromJson(item))
//        .toList();

    return _storeDetail;
  }

  Future<List<StoreDTO.Category>?> fetchStoreMenu(
      String? uuid, String languageCode, BuildContext context) async {
    final dynamic menuRes = await Services.asyncRequest('GET',
        '/store/v1/profile/${uuid}/menu?language=${languageCode}', context);
    var menuData = json.decode(menuRes.toString());
    _categories = new List<dynamic>.from(menuData['categories'])
        .map((item) => StoreDTO.Category.fromJson(item))
        .toList();

    return _categories;
  }

  Future<List<StoreDTO.Record>> fetchSpecialTags(
      String uuid, BuildContext context) async {
    List<StoreDTO.Record> _record = []; // Initialize as empty list

    try {
      final String url =
          '/store/v3/$uuid/product/tag?pageIdx=0&pageSize=50&status=ACTIVE';
      final dynamic response = await Services.asyncRequest('GET', url, context);
      var data = json.decode(response.toString());

      // Check if 'records' is not null and then extract each item's 'name' property
      if (data['records'] != null) {
        _record = List<dynamic>.from(data['records'])
            .map((item) => StoreDTO.Record.fromJson(item))
            .toList();
      }
    } catch (e) {
      print("Error fetching special tags: $e");
      // Already initialized _record as an empty list, so we can just return it
    }

    return _record; // _record is guaranteed to be non-null here
  }

  Future<void> createOrder(BuildContext context,
      {StoreDTO.DeliveryDetail? deliveryDetail,
      StoreDTO.TakeAwayDetail? takeawayDetail}) async {
    var storeId = _storeDetail!.uuid;
    List<CartItem> newCartItems = [];
    _cartItems.forEach((cartItem) {
      if (cartItem.quantity == 1) {
        newCartItems.add(cartItem);
      } else if (cartItem.quantity! > 1) {
        for (var i = 0; i < cartItem.quantity!; i++) {
          newCartItems.add(CartItem(
              product: cartItem.product,
              options: cartItem.options,
              quantity: 1));
        }
      }
    });
    List<Map> items = newCartItems.map((i) => i.toJson()).toList();
//    List<Map> items =
//    _cartItems != null ? _cartItems.map((i) => i.toJson()).toList() : null;
    Map<String, dynamic> body = {
      'storeId': storeId,
      'type': EnumToString.parse(_type),
      'items': items,
      'note': '',
      'orderClient': 'WXAPP',
      'app': 'LINKEAT',
    };
    print("*************************************");
    print(body);
    print("*************************************");
    // delivery order
    Map? deliveryDetailJson = deliveryDetail != null
        ? deliveryDetail.toJson(_storeDetail!.address!.state)
        : null;
    if (_type == OrderType.DELIVERY) {
      body['deliveryDetail'] = deliveryDetailJson;
    }
    // takeaway order
    if (_type == OrderType.TAKEAWAY) {
      body['takeawayDetail'] = takeawayDetail!.toJson();
    }
    print(storeId);

    final dynamic response = await Services.asyncRequest(
      'POST',
      '/store/v2/${storeId}/order',
      context,
      payload: body,
    );
    var data = json.decode(response.toString());
    emptyCart();
    Navigator.pushNamed(
      context,
      '/payment',
      arguments: OrderPaymentArguments(
        data['uuid'],
      ),
    );
  }

  int get cartTotalQuantity =>
      _cartItems.fold(0, (total, current) => total + current.quantity!);

  int get cartTotal => _cartItems.fold(
      0,
      (total, current) =>
          total +
          (current.product!.price! * current.quantity! +
              current.options!.fold(
                  0,
                  ((optionTotal, currentOption) =>
                          optionTotal + currentOption.optionTotalPrice() as int)
                      as int Function(int, OptionState))));

  void addToCart(
      StoreDTO.Product product, int? quantity, List<OptionState> options) {
    // filter options
    List<OptionState> filterOptions1 =
        options.where((option) => option.quantity > 0).toList();
    List<OptionState> filterOptions2 = filterOptions1
        .map((optionState) => OptionState(
            option: optionState.option,
            optionValuesState: optionState.optionValuesState!
                .where((optionValue) => optionValue.quantity! > 0)
                .toList()))
        .toList();
    var cartItem =
        CartItem(product: product, quantity: quantity, options: filterOptions2);
    _cartItems.add(cartItem);
    notifyListeners();
  }

  void removeFromCart(int index) {
    _cartItems.remove(_cartItems[index]); // should use where
    notifyListeners();
  }

  void emptyCart() {
    _cartItems = [];
    _type = null;
    notifyListeners();
  }

  void setOrderType(OrderType? orderType) {
    _type = orderType;
//    notifyListeners();
  }
}

class CartItem {
  StoreDTO.Product? product;
  List<OptionState>? options;
  int? quantity;

  CartItem({
    this.product,
    this.quantity,
    this.options,
  });

  Map toJson() => {
        'productId': product!.id,
        'price': product!.price! +
            options!.fold(
                0, (total, current) => total + current.optionTotalPrice()),
        'quantity': quantity,
        'options': options!.map((i) => i.toJson()).toList(),
        'note': '',
        'pagerNum': '',
      };
}

class OptionState {
  List<OptionValueState>? optionValuesState;
  StoreDTO.Option? option;
  int quantity;
  bool reachMaxLimit;

  OptionState(
      {this.optionValuesState,
      this.option,
      this.quantity = 0,
      this.reachMaxLimit = false});

  Map toJson() => {
        'code': option!.code,
        'optionValues': optionValuesState!.map((i) => i.toJson()).toList(),
      };

  int optionTotalPrice() {
    return optionValuesState!.fold(
        0,
        (total, current) =>
            total + current.quantity! * current.optionValue!.price!);
  }
}

class OptionValueState {
  StoreDTO.OptionValue? optionValue;
  int? quantity;

  OptionValueState({this.optionValue, this.quantity = 0});

  Map toJson() => {
        'value': optionValue!.value,
        'quantity': quantity,
      };
}
