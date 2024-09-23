import 'package:linkeat/models/store.dart';

class StoreHomeArguments {
  final String? uuid;
  StoreHomeArguments(this.uuid);
}

// class bookingArguments {
//   final String? uuid;
//   bookingArguments(this.uuid);
// }



class StoreMenuArguments {
  final String? uuid;
  StoreMenuArguments(this.uuid);
}

class ProductDetailArguments {
  final Product product;
  final bool storeOpened;
  ProductDetailArguments(this.product, this.storeOpened);
}

class OrderPaymentArguments {
  final String? orderId;
  OrderPaymentArguments(this.orderId);
}

class OrderDetailArguments {
  final String orderId;
  OrderDetailArguments(this.orderId);
}

class LoginArguments {
  final bool resetToHome;
  LoginArguments(this.resetToHome);
}

class BookingArguments {
  final String? uuid;
  BookingArguments(this.uuid);
}