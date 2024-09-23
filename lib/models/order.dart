import 'package:enum_to_string/enum_to_string.dart';

import 'package:linkeat/models/store.dart';

class Order {
  final String? uuid;
  final OrderType? type;
  final int? createdAt;
  final int? amount;
  final int? subtotal;
  final int? orderNumber;
  final PaymentStatus? paymentStatus;
  final int? gsmAmount;
  final int? deliveryFee;
  DeliveryDetail? deliveryDetail;
  TakeAwayDetail? takeAwayDetail;
  final OrderStatus? status;
  final List<OrderItem>? items;
  final StoreThumbnail? store;
  DelilverySummary? deliverySummary;

  Order({
    this.uuid,
    this.type,
    this.createdAt,
    this.amount,
    this.subtotal,
    this.orderNumber,
    this.paymentStatus,
    this.gsmAmount,
    this.deliveryFee,
    this.deliveryDetail,
    this.takeAwayDetail,
    this.status,
    this.items,
    this.store,
    this.deliverySummary,
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    OrderType? type = EnumToString.fromString(OrderType.values, json['type']);
    Order order = Order(
        uuid: json['uuid'],
        type: type,
        createdAt: json['createdAt'],
        amount: json['amount'],
        subtotal: json['subtotal'],
        orderNumber: json['orderNumber'],
        paymentStatus: EnumToString.fromString(
            PaymentStatus.values, json['paymentStatus']),
        deliveryFee: json['deliveryFee'],
        status: EnumToString.fromString(OrderStatus.values, json['status']),
        items: new List<dynamic>.from(json['items'])
            .map((item) => OrderItem.fromJson(item))
            .toList(),
        store: StoreThumbnail.fromJson(json['store']));
    if (type == OrderType.DELIVERY) {
      order.deliveryDetail = DeliveryDetail.fromJson(json['deliveryDetail']);
      if (json['deliverySummary'] != null) {
        order.deliverySummary =
            DelilverySummary.fromJson(json['deliverySummary']);
      }
    }
    if (type == OrderType.TAKEAWAY) {
      order.takeAwayDetail = TakeAwayDetail.fromJson(json['takeAwayDetail']);
    }

    return order;
  }
  String getFriendlyStatus() {
    // takeaway
    if (type == OrderType.TAKEAWAY) return EnumToString.parse(status);

    // delivery
    String friendlyStatus = EnumToString.parse(status);
    if (status == OrderStatus.COMPLETED)
      friendlyStatus = EnumToString.parse(OrderStatus.PROCESSING);
    if (deliverySummary != null) {
      switch (deliverySummary!.deliveryStatus) {
        case DeliveryStatus.COLLECTED:
          friendlyStatus = 'DISPATCHED';
          break;
        case DeliveryStatus.COMPLETED:
          friendlyStatus = 'DELIVERED';
          break;
        default:
      }
    }
    // TAKEAWAY: PENDING, PROCESSING, COMPLETED, DECLINED, CANCELLED
    // DELIVERY: PENDING, PROCESSING, DISPATCHED, DELIVERED, DECLINED, CANCELLED
    return friendlyStatus;
  }
}

class OrderItem {
  int? quantity;
  int? unitPrice;
  ProductSnapshot? product;
  List<OrderItemSelectionSnapshot>? options;

  OrderItem({this.quantity, this.unitPrice, this.product, this.options});

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    return OrderItem(
      quantity: json['quantity'],
      unitPrice: json['unitPrice'],
      product: ProductSnapshot.fromJson(json['product']),
      options: new List<dynamic>.from(json['options'])
          .map((item) => OrderItemSelectionSnapshot.fromJson(item))
          .toList(),
    );
  }
}

class ProductSnapshot {
  String? id;
  String? name;
  String? abbreviation;
  String? imgUrl;
  String? discount;
  int? price;
  String? type;
  List<TranslationSnapshot>? translations;

  ProductSnapshot(
      {this.id,
      this.name,
      this.abbreviation,
      this.imgUrl,
      this.discount,
      this.price,
      this.type,
      this.translations});

  factory ProductSnapshot.fromJson(Map<String, dynamic> json) {
    return ProductSnapshot(
      id: json['uuid'],
      name: json['name'],
      abbreviation: json['abbreviation'],
      imgUrl: json['imgUrl'],
      discount: json['discount'],
      price: json['price'],
      type: json['type'],
      translations: new List<dynamic>.from(json['translations'])
          .map((item) => TranslationSnapshot.fromJson(item))
          .toList(),
    );
  }
}

class OrderItemSelectionSnapshot {
  String? name;
  String? code;
  List<OrderItemSelectionValueSnapshot>? selections;
  List<TranslationSnapshot>? translations;

  OrderItemSelectionSnapshot({
    this.name,
    this.code,
    this.selections,
    this.translations,
  });

  factory OrderItemSelectionSnapshot.fromJson(Map<String, dynamic> json) {
    return OrderItemSelectionSnapshot(
      name: json['name'],
      code: json['code'],
      selections: new List<dynamic>.from(json['selections'])
          .map((item) => OrderItemSelectionValueSnapshot.fromJson(item))
          .toList(),
      translations: new List<dynamic>.from(json['translations'])
          .map((item) => TranslationSnapshot.fromJson(item))
          .toList(),
    );
  }
}

class OrderItemSelectionValueSnapshot {
  String? name;
  int? price;
  int? quantity;
  String? value;
  List<TranslationSnapshot>? translations;

  OrderItemSelectionValueSnapshot({
    this.name,
    this.price,
    this.quantity,
    this.value,
    this.translations,
  });

  factory OrderItemSelectionValueSnapshot.fromJson(Map<String, dynamic> json) {
    return OrderItemSelectionValueSnapshot(
      name: json['name'],
      price: json['price'],
      quantity: json['quantity'],
      value: json['value'],
      translations: new List<dynamic>.from(json['translations'])
          .map((item) => TranslationSnapshot.fromJson(item))
          .toList(),
    );
  }
}

class TranslationSnapshot {
  String? description;
  String? languageCode;
  String? languageId;
  String? name;

  TranslationSnapshot({
    this.description,
    this.languageCode,
    this.languageId,
    this.name,
  });

  factory TranslationSnapshot.fromJson(Map<String, dynamic> json) {
    return TranslationSnapshot(
      description: json['description'],
      languageCode: json['languageCode'],
      languageId: json['languageId'],
      name: json['name'],
    );
  }
}

class StoreThumbnail {
  String? id;
  String? logoImgUrl;
  String? name;
  String? phone;

  StoreThumbnail({
    this.id,
    this.logoImgUrl,
    this.name,
    this.phone,
  });

  factory StoreThumbnail.fromJson(Map<String, dynamic> json) {
    return StoreThumbnail(
      name: json['name'],
      id: json['id'],
      logoImgUrl: json['logoImgUrl'],
      phone: json['phone'],
    );
  }
}

class DelilverySummary {
  String? driverName;
  String? driverPhoneNumber;
  DeliveryStatus? deliveryStatus;

  DelilverySummary({
    this.driverName,
    this.driverPhoneNumber,
    this.deliveryStatus,
  });

  factory DelilverySummary.fromJson(Map<String, dynamic> json) {
    return DelilverySummary(
        driverName: json['driverName'],
        driverPhoneNumber: json['driverPhoneNumber'],
        deliveryStatus: EnumToString.fromString(
            DeliveryStatus.values, json['deliveryStatus']));
  }
}

enum OrderStatus {
  PENDING,
  PROCESSING,
  DECLINED,
  CANCELLED,
  COMPLETED,
  COLLECTED
}

enum PaymentStatus { UNPAID, PARTIALLYPAID, OVERPAID, PAID, REFUNDED }

enum OrderType { TAKEAWAY, DELIVERY }

enum DeliveryStatus {
  PENDING,
  ACCEPTED,
  READY,
  COLLECTED,
  DEPARTED,
  ARRIVED,
  COMPLETED,
  CANCELLED,
  ERROR
}
