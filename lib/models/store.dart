import 'package:linkeat/models/order.dart';
import 'package:enum_to_string/enum_to_string.dart';
import 'package:intl/intl.dart';

import 'package:linkeat/config.dart';
import 'package:linkeat/utils/datetime_util.dart';

class StoreSummary {
  final String? uuid;
  final String? name;
  final List<String>? bannerUrls;
  final String? logoImgUrl;
  final List<String>? tags;
  final List<Translation>? translations;

  StoreSummary(
      {this.uuid,
      this.name,
      this.logoImgUrl,
      this.bannerUrls,
      this.tags,
      this.translations});

  factory StoreSummary.fromJson(Map<String, dynamic> json) {
    return StoreSummary(
      uuid: json['uuid'],
      name: json['name'],
      bannerUrls: new List<String>.from(json['bannerUrls']),
      logoImgUrl: json['logoImgUrl'],
      tags: new List<String>.from(json['tags']),
      translations: new List<dynamic>.from(json['translations'])
          .map((item) => Translation.fromJson(item))
          .toList(),
    );
  }

  factory StoreSummary.fromSearchJson(Map<String, dynamic> json) {
    return StoreSummary(
      uuid: json['id'],
      name: json['name'],
      bannerUrls: new List<String>.from(json['bannerUrl']),
      logoImgUrl: json['logoImgUrl'],
      tags: new List<String>.from(json['tags']),
      translations: new List<dynamic>.from(json['translations'])
          .map((item) => Translation.fromJson(item))
          .toList(),
    );
  }

  String? getTranslatedName(String languageCode) {
    LanguageCode? code =
        EnumToString.fromString(LanguageCode.values, languageCode);
    List<Translation> findTranslations = translations!
        .where((item) => (item.languageCode == code && item.name != ''))
        .toList();
    if (findTranslations.length == 0) return name;
    return findTranslations[0].name;
  }
}

class Store {
  final StoreDetail? storeDetail;
  final List<Category>? categories;

  Store({this.storeDetail, this.categories});

  factory Store.fromJson(Map<String, dynamic> json) {
    return Store(
      storeDetail: StoreDetail.fromJson(json['storeSummary']),
      categories: new List<dynamic>.from(json['categories'])
          .map((item) => Category.fromJson(item))
          .toList(),
    );
  }
}

class StoreDetail {
  final String? uuid;
  final String? name;
  final List<String>? bannerUrl;
  final String? logoImgUrl;
  final String? mapContent;
  final List<String>? tags;
  final Address? address;
  final String? phone;
  final String? description;
  final StoreConfig? storeConfig;
  final List<BusinessHourDay>? businessHour;
  final BankTransferStoreConfig? bankTransferStoreConfig;
  final DeliveryCfg? deliveryCfg;
  final StripeConfig? stripeConfig;
  final List<Translation>? translations;

  StoreDetail(
      {this.uuid,
      this.name,
      this.logoImgUrl,
      this.mapContent,
      this.bannerUrl,
      this.tags,
      this.address,
      this.phone,
      this.description,
      this.storeConfig,
      this.businessHour,
      this.bankTransferStoreConfig,
      this.deliveryCfg,
      this.translations,
      this.stripeConfig});

  factory StoreDetail.fromJson(Map<String, dynamic> json) {
    var businessHour =
        new List<Map<String, dynamic>>.from(json['businessHour']);
    return StoreDetail(
      uuid: json['id'],
      name: json['name'],
      bannerUrl: new List<String>.from(json['bannerUrl']),
      logoImgUrl: json['logoImgUrl'],
      mapContent: json['mapContent'],
      tags: new List<String>.from(json['tags']),
      address: Address.fromJson(json['location']['address']),
      phone: json['phone'],
      description: json['description'],
      storeConfig: StoreConfig.fromJson(json['storeConfig']),
      businessHour: businessHour
          .map((Map<String, dynamic> item) => BusinessHourDay.fromJson(item))
          .toList(),
      bankTransferStoreConfig: json['bankTransferStoreConfig'] != null
          ? BankTransferStoreConfig.fromJson(json['bankTransferStoreConfig'])
          : null,
      deliveryCfg: json['deliveryCfg'] != null
          ? DeliveryCfg.fromJson(json['deliveryCfg'])
          : null,
      stripeConfig: json['stripeConfig'] != null
          ? StripeConfig.fromJson(json['stripeConfig'])
          : null,
      translations: new List<dynamic>.from(json['translations'])
          .map((item) => Translation.fromJson(item))
          .toList(),
    );
  }

  bool isOpened() {
    var now = DateTime.now();
    var weekOfDay = now.weekday;
    List<BusinessHourDay> todayBusinessHours =
        businessHour!.where((item) => item.dayOfTheWeek == weekOfDay).toList();
    if (todayBusinessHours.length == 0) return false;
    var opened = false;
    var formatter = new DateFormat('yyyy-MM-dd');
    for (var i = 0; i < todayBusinessHours[0].openingHours!.length; i++) {
      var openingHour = todayBusinessHours[0].openingHours![i];
      var openingHourOpen = DateTime.parse(
          '${formatter.format(now)} ${DateTimeUtil.convertBusinessHourToTimeString(openingHour.open!)}');
      var openingHourClose = DateTime.parse(
          '${formatter.format(now)} ${DateTimeUtil.convertBusinessHourToTimeString(openingHour.close!)}');

      if (now.isAfter(openingHourOpen) && now.isBefore(openingHourClose)) {
        opened = true;
      }
    }
    return opened;
  }

  bool isOpenedForTakeaway() {
    var now = DateTime.now();
    var weekOfDay = now.weekday;
    List<BusinessHourDay> todayBusinessHours =
        businessHour!.where((item) => item.dayOfTheWeek == weekOfDay).toList();
    if (todayBusinessHours.length == 0) return false;
    var opened = false;
    var formatter = new DateFormat('yyyy-MM-dd');
    for (var i = 0; i < todayBusinessHours[0].openingHours!.length; i++) {
      var openingHour = todayBusinessHours[0].openingHours![i];
      var openingHourOpen = DateTime.parse(
          '${formatter.format(now)} ${DateTimeUtil.convertBusinessHourToTimeString(openingHour.open!)}');
      var openingHourClose = DateTime.parse(
          '${formatter.format(now)} ${DateTimeUtil.convertBusinessHourToTimeString(openingHour.close!)}');

      if (now.isAfter(openingHourOpen) && now.isBefore(openingHourClose)) {
        opened = true;
      }
    }
    return opened;
  }

  String? getTranslatedName(String languageCode) {
    LanguageCode? code =
        EnumToString.fromString(LanguageCode.values, languageCode);
    List<Translation> findTranslations = translations!
        .where((item) => (item.languageCode == code && item.name != ''))
        .toList();
    if (findTranslations.length == 0) return name;
    return findTranslations[0].name;
  }

  String? getTranslatedDescription(String languageCode) {
    LanguageCode? code =
        EnumToString.fromString(LanguageCode.values, languageCode);
    List<Translation> findTranslations = translations!
        .where((item) => (item.languageCode == code && item.description != ''))
        .toList();
    if (findTranslations.length == 0) return description;
    return findTranslations[0].description;
  }
}

class Address {
  final String? address1;
  final String? city;
  final String? postCode;
  final String? state;

  Address({this.address1, this.city, this.postCode, this.state});

  factory Address.fromJson(Map<String, dynamic> json) {
    return Address(
      address1: json['address1'],
      city: json['city'],
      postCode: json['postCode'],
      state: json['state'],
    );
  }
}

class BusinessHourDay {
  final int? dayOfTheWeek;
  final List<OpeningHour>? openingHours;

  BusinessHourDay({this.dayOfTheWeek, this.openingHours});

  factory BusinessHourDay.fromJson(Map<String, dynamic> json) {
    var openingHours =
        new List<Map<String, dynamic>>.from(json['openingHours']);
    return BusinessHourDay(
      dayOfTheWeek: json['dayOfTheWeek'],
      openingHours: openingHours
          .map((Map<String, dynamic> item) => OpeningHour.fromJson(item))
          .toList(),
    );
  }
}

class OpeningHour {
  final int? open;
  final int? close;

  OpeningHour({this.open, this.close});

  factory OpeningHour.fromJson(Map<String, dynamic> json) {
    return OpeningHour(
      open: json['open'],
      close: json['close'],
    );
  }

  String toString() {
    var openHours =
        (this.open! ~/ 2).toString() + (this.open! % 2 > 0 ? ':30' : ':00');
    var closeHours =
        (this.close! ~/ 2).toString() + (this.close! % 2 > 0 ? ':30' : ':00');
    return '${openHours} - ${closeHours}';
  }
}

class StoreConfig {
  final bool? acceptDelivery;
  final bool? acceptTakeaway;
  final bool? acceptStripeConnect;
  final bool? acceptPOD;
  final bool? acceptBankTransfer;
  final bool? acceptWxPayPayment;
  final bool? acceptSuperPayMiniPay;
  final bool? acceptWindcaveH5;
  final bool? acceptChinaPayAlipayH5;

  StoreConfig(
      {this.acceptDelivery,
      this.acceptTakeaway,
      this.acceptBankTransfer,
      this.acceptPOD,
      this.acceptStripeConnect,
        this.acceptWxPayPayment,
        this.acceptWindcaveH5,
        this.acceptChinaPayAlipayH5,
      this.acceptSuperPayMiniPay});

  factory StoreConfig.fromJson(Map<String, dynamic> json) {
    return StoreConfig(
      acceptDelivery: json['acceptDelivery'] == 'AVAILABLE' || false,
      acceptTakeaway: json['acceptTakeaway'] == 'AVAILABLE' || false,
      acceptStripeConnect: json['acceptStripeConnect'] == 'AVAILABLE' || false,
      acceptPOD: json['acceptPOD'] == 'AVAILABLE' || false,
      acceptBankTransfer: json['acceptBankTransfer'] == 'AVAILABLE' || false,
      acceptWxPayPayment: json['acceptWxPayPayment'] == 'AVAILABLE' || false,
      acceptWindcaveH5: json['acceptWindcaveH5'] == 'AVAILABLE' || false,
      acceptChinaPayAlipayH5: json['acceptChinaPayAlipayH5'] == 'AVAILABLE' || false,
      acceptSuperPayMiniPay:
          json['acceptSuperPayMiniPay'] == 'AVAILABLE' || false,
    );
  }
}

final Map<int, String> DayOfWeekMapping = {
  1: 'Monday',
  2: 'Tuesday',
  3: 'Wednesday',
  4: 'Thursday',
  5: 'Friday',
  6: 'Saturday',
  7: 'Sunday',
};

class BankTransferStoreConfig {
  final String? accountName;
  final String? accountNo;
  final String? bsb;
  final String? payId;

  BankTransferStoreConfig(
      {this.accountName, this.accountNo, this.bsb, this.payId});

  factory BankTransferStoreConfig.fromJson(Map<String, dynamic> json) {
    return BankTransferStoreConfig(
      accountName: json['accountName'],
      accountNo: json['accountNo'],
      bsb: json['bsb'],
      payId: json['payId'],
    );
  }
}

class StripeConfig {
  final String? accountId;
  final double? fee;

  StripeConfig({this.accountId, this.fee});

  factory StripeConfig.fromJson(Map<String, dynamic> json) {
    return StripeConfig(
      accountId: json['accountId'],
      fee: json['fee'],
    );
  }
}

class DeliveryCfg {
  final String? deliveryDescription;
  final List<DeliveryRange>? deliveryRanges;

  DeliveryCfg({this.deliveryDescription, this.deliveryRanges});

  factory DeliveryCfg.fromJson(Map<String, dynamic> json) {
    return DeliveryCfg(
      deliveryDescription: json['deliveryDescription'],
      deliveryRanges: new List<dynamic>.from(json['deliveryRanges'])
          .map((item) => DeliveryRange.fromJson(item))
          .toList(),
    );
  }
}

class DeliveryRange {
  final String? name;
  final String? mode;
  final int? minimalOrderPrice;
  final int? freeDeliveryThreshold;
  final int? cost;
  final List<String>? postCodes;
  final List<DeliveryScheduleDay>? schedules;

  DeliveryRange({
    this.name,
    this.mode,
    this.minimalOrderPrice,
    this.freeDeliveryThreshold,
    this.cost,
    this.postCodes,
    this.schedules,
  });

  factory DeliveryRange.fromJson(Map<String, dynamic> json) {
    // convert deliverySchedule model
//    List<DeliveryScheduleDay> deliveryScheduleDays = [];
//    var schedules = new List<dynamic>.from(json['schedules']);
//    List<DeliveryScheduleSplitDayOfWeek> schedulesWithDayofWeek = [];
//    for (var schedlue in schedules) {
//      var start = schedlue['start'];
//      var end = schedlue['end'];
//      var splitStartList = start.split("-");
//      // without day of week in start -> every day
//      if (splitStartList.length == 1) {
//        for (var i = 1; i < 8; i++) {
//          schedulesWithDayofWeek.add(DeliveryScheduleSplitDayOfWeek(
//              dayOfTheWeek: i,
//              start: start,
//              end: end,
//              originalSchedule:
//                  OriginalDeliverySchedule(start: start, end: end)));
//        }
//      }
//      // with day of week in start
//      if (splitStartList.length > 1) {
//        schedulesWithDayofWeek.add(DeliveryScheduleSplitDayOfWeek(
//            dayOfTheWeek: int.parse(splitStartList[0]),
//            start: splitStartList[1],
//            end: end,
//            originalSchedule:
//                OriginalDeliverySchedule(start: start, end: end)));
//      }
//    }
//
//    // group schedulesWithDayofWeek by dayOfWeek
//    var groupedSchedulesWithDayofWeek =
//        groupBy(schedulesWithDayofWeek, (obj) => obj.dayOfTheWeek);
//    for (var i = 1; i < 8; i++) {
//      if (groupedSchedulesWithDayofWeek[i] != null) {
//        deliveryScheduleDays.add(DeliveryScheduleDay(
//            dayOfTheWeek: i,
//            deliverySchedules: groupedSchedulesWithDayofWeek[i]
//                .map((item) => DeliverySchedule(
//                    start: item.start,
//                    end: item.end,
//                    originalSchedule: item.originalSchedule))
//                .toList()));
//      }
//    }
    var schedules = new List<dynamic>.from(json['schedules']);
    List<DeliveryScheduleDay> deliveryScheduleDays = schedules
        .map((schedule) => DeliveryScheduleDay(
            dayOfTheWeek: schedule['dayOfTheWeek'],
            deliverySchedules: List<dynamic>.from(schedule['timeRanges'])
                .map((item) => DeliverySchedule(
                    start: item['start'],
                    end: item['end'],
                    originalSchedule: OriginalDeliverySchedule(
                        dayOfTheWeek: schedule['dayOfTheWeek'],
                        timeRanges: List<dynamic>.from(schedule['timeRanges'])
                            .map((range) => DeliveryTimeRange(
                                start: range['start'], end: range['end']))
                            .toList())))
                .toList()))
        .toList();

    return DeliveryRange(
      name: json['name'],
      mode: json['mode'],
      minimalOrderPrice: json['minimalOrderPrice'],
      freeDeliveryThreshold: json['freeDeliveryThreshold'],
      cost: json['cost'],
      postCodes: new List<String>.from(json['postCodes']),
      schedules: deliveryScheduleDays,
    );
  }
}

class DeliveryScheduleDay {
  final int? dayOfTheWeek;
  final List<DeliverySchedule>? deliverySchedules;

  DeliveryScheduleDay({this.dayOfTheWeek, this.deliverySchedules});
}

class DeliverySchedule {
  final String? start;
  final String? end;
  final OriginalDeliverySchedule? originalSchedule;

  DeliverySchedule({this.start, this.end, this.originalSchedule});

//  factory DeliverySchedule.fromJson(Map<String, dynamic> json) {
//    return DeliverySchedule(
//      start: json['start'],
//      end: json['end'],
//    );
//  }
}

class DeliveryScheduleSplitDayOfWeek {
  final int? dayOfTheWeek;
  final String? start;
  final String? end;
  final OriginalDeliverySchedule? originalSchedule;

  DeliveryScheduleSplitDayOfWeek(
      {this.dayOfTheWeek, this.start, this.end, this.originalSchedule});
}

class DeliveryScheduleInt {
  final int? start;
  final int? end;

  DeliveryScheduleInt({this.start, this.end});
}

class OriginalDeliverySchedule {
  final int? dayOfTheWeek;
  final List<DeliveryTimeRange>? timeRanges;

  OriginalDeliverySchedule({this.dayOfTheWeek, this.timeRanges});

  Map toJson() {
    List<Map> items = timeRanges!.map((i) => i.toJson()).toList();
    Map json = {'dayOfTheWeek': dayOfTheWeek, 'timeRanges': items};
    return json;
  }
}

class DeliveryTimeRange {
  final String? start;
  final String? end;

  DeliveryTimeRange({this.start, this.end});

  Map toJson() => {
        'start': start,
        'end': end,
      };
}

//class StoreMenu {
//  final List<Category> categories;
//
//  StoreMenu({
//    this.categories,
//  });
//
//  factory StoreMenu.fromJson(Map<String, dynamic> json) {
//    return StoreMenu(
//      categories: new List<dynamic>.from(json['categories']).map((item) => Category.fromJson(item)).toList(),
//    );
//  }
//}

class Category {
  final String? name;
  final String? id;
  final int? sortOrder;
  final List<Product>? products;

  Category({this.name, this.id, this.sortOrder, this.products});

  factory Category.fromJson(Map<String, dynamic> json) {
    var items = new List<dynamic>.from(json['products'])
        .map((item) => Product.fromJson(item))
        .toList();
    items.sort((a, b) => b.sortOrder!.compareTo(a.sortOrder!));
    return Category(
      name: json['name'],
      id: json['id'],
      sortOrder: json['sortOrder'],
      products: items,
    );
  }

  List<Product> getItemsByType(OrderType? type) {
    if (type == OrderType.DELIVERY)
      return products!.where((item) => item.config!.acceptDelivery!).toList();
    if (type == OrderType.TAKEAWAY)
      return products!.where((item) => item.config!.acceptTakeaway!).toList();
    return [];
  }
}

class Record {
  final String? id;
  final String? name;
  final String? description;
  final int? sortOrder;
  final String? storeId;
  final List<Product>? products;

  Record({
    this.id,
    this.name,
    this.description,
    this.sortOrder,
    this.storeId,
    this.products,
  });

  factory Record.fromJson(Map<String, dynamic> json) {
    // Assuming 'products' is a list of maps, each representing a Product
    var items = new List<dynamic>.from(json['products'])
        .map((item) => Product.fromJson(item))
        .toList();
    items.sort((a, b) => b.sortOrder!.compareTo(a.sortOrder!));
    return Record(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      sortOrder: json['sortOrder'],
      storeId: json['storeId'],
      products: items,
    );
  }
}

class Product {
  final String? id;
  final String? name;
  final String? imgUrl;
  final String? description;
  final int? price;
  final int? originalPrice;
  final int? sortOrder;
  final String? type;
  final ProductConfig? config;
  final List<Option>? options;

  Product({
    this.id,
    this.name,
    this.imgUrl,
    this.description,
    this.price,
    this.originalPrice,
    this.sortOrder,
    this.type,
    this.config,
    this.options,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'imgUrl': imgUrl,
      'description': description,
      'price': price,
      'originalPrice': originalPrice,
      'sortOrder': sortOrder,
      'type': type,
      'config': config?.toJson(), // 确保 ProductConfig 有 toJson 方法
      'options': options
          ?.map((option) => option.toJson())
          .toList(), // 确保 Option 有 toJson 方法
    };
  }

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'],
      name: json['name'],
      imgUrl: json['imgUrl'] != '' ? json['imgUrl'] : null,
      description: json['description'],
      price: json['price'],
      originalPrice: json['originalPrice'],
      sortOrder: json['sortOrder'],
      type: json['type'],
      config: ProductConfig.fromJson(json['config']),
      options: new List<dynamic>.from(json['options'])
          .map((item) => Option.fromJson(item))
          .toList(),
    );
  }
}

class ProductConfig {
  final bool? acceptDelivery;
  final bool? acceptDineIn;
  final bool? acceptTakeaway;
  final bool? dynamicPrice;

  ProductConfig(
      {this.acceptDelivery,
      this.acceptDineIn,
      this.acceptTakeaway,
      this.dynamicPrice});

  factory ProductConfig.fromJson(Map<String, dynamic> json) {
    return ProductConfig(
      acceptDelivery: json['acceptDelivery'] == 'AVAILABLE' || false,
      acceptTakeaway: json['acceptTakeaway'] == 'AVAILABLE' || false,
      acceptDineIn: json['acceptDineIn'] == 'AVAILABLE' || false,
      dynamicPrice: json['dynamicPrice'] == 'AVAILABLE' || false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'acceptDelivery': acceptDelivery == true ? 'AVAILABLE' : 'NOT_AVAILABLE',
      'acceptTakeaway': acceptTakeaway == true ? 'AVAILABLE' : 'NOT_AVAILABLE',
      'acceptDineIn': acceptDineIn == true ? 'AVAILABLE' : 'NOT_AVAILABLE',
      'dynamicPrice': dynamicPrice == true ? 'AVAILABLE' : 'NOT_AVAILABLE',
    };
  }
}

class Option {
  final String? name;
  final String? description;
  final int? min;
  final int? max;
  final int? sortOrder;
  final String? code;
  final List<OptionValue>? optionValues;

  Option({
    this.name,
    this.description,
    this.min,
    this.max,
    this.sortOrder,
    this.code,
    this.optionValues,
  });

  factory Option.fromJson(Map<String, dynamic> json) {
    return Option(
      name: json['name'],
      description: json['description'],
      min: json['min'],
      max: json['max'],
      sortOrder: json['sortOrder'],
      code: json['code'],
      optionValues: new List<dynamic>.from(json['optionValues'])
          .map((item) => OptionValue.fromJson(item))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'description': description,
      'min': min,
      'max': max,
      'sortOrder': sortOrder,
      'code': code,
      'optionValues': optionValues?.map((ov) => ov.toJson()).toList(),
    };
  }
}

class OptionValue {
  final String? name;
  final String? description;
  final int? min;
  final int? max;
  final int? price;
  final int? sortOrder;
  final String? value;

  OptionValue(
      {this.name,
      this.description,
      this.min,
      this.max,
      this.price,
      this.sortOrder,
      this.value});

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'description': description,
      'min': min,
      'max': max,
      'price': price,
      'sortOrder': sortOrder,
      'value': value,
    };
  }

  factory OptionValue.fromJson(Map<String, dynamic> json) {
    return OptionValue(
      name: json['name'],
      description: json['description'],
      min: json['min'],
      max: json['max'],
      price: json['price'],
      sortOrder: json['sortOrder'],
      value: json['value'],
    );
  }
}

class DeliveryDetail {
  String? name = '';
  String? phone = '';
  int? expectArriveTime;
  DeliveryAddress? address;
  DeliverySchedule? deliverySchedule;

  DeliveryDetail(
      {this.name,
      this.phone,
      this.address,
      this.expectArriveTime,
      this.deliverySchedule});

  factory DeliveryDetail.fromJson(Map<String, dynamic> json) {
    return DeliveryDetail(
      name: json['name'],
      phone: json['phone'],
      expectArriveTime: json['expectArriveTime'],
      address: DeliveryAddress.fromJson(json['address']),
    );
  }

  Map toJson(String? storeState) {
    Map? address =
        this.address != null ? this.address!.toJson(storeState) : null;
    Map json = {
      'name': name,
      'phone': phone,
      'expectArriveTime': expectArriveTime,
      'address': address,
      'deliveredBy': Constants.FRANCHISE_ID,
      'deliverType': 'FRANCHISE',
    };
    if (deliverySchedule != null) {
      json['deliverySchedule'] = deliverySchedule!.originalSchedule!.toJson();
    }

    return json;
  }
}

class DeliveryAddress {
  String? address1 = '';
  String? city = '';
  String? postCode = '';
  String? state = '';

  DeliveryAddress({this.address1, this.city, this.postCode, this.state});

  factory DeliveryAddress.fromJson(Map<String, dynamic> json) {
    return DeliveryAddress(
      address1: json['address1'],
      city: json['city'],
      postCode: json['postCode'],
      state: json['state'],
    );
  }

  Map toJson(String? storeState) => {
        'address1': address1,
        'address2': '',
        'city': city,
        'postCode': postCode,
        'state': storeState,
      };
}

class DeliveryScheduleOption {
  DeliverySchedule? deliverySchedule;
  int? expectArriveTime;
  String? showing;

  DeliveryScheduleOption(
      {this.deliverySchedule, this.expectArriveTime, this.showing});
}

class TakeawayTimeOption {
  int? pickUpTime;
  String? showing;

  TakeawayTimeOption({this.pickUpTime, this.showing});
}

class TakeAwayDetail {
  String? customerName = '';
  String? phone = '';
  int? pickUpTime;

  TakeAwayDetail({this.customerName, this.phone, this.pickUpTime});

  factory TakeAwayDetail.fromJson(Map<String, dynamic> json) {
    return TakeAwayDetail(
      customerName: json['customerName'],
      phone: json['phone'],
      pickUpTime: json['pickUpTime'],
    );
  }

  Map toJson() {
    Map json = {
      'customerName': customerName,
      'phone': phone,
      'pickUpTime': pickUpTime,
    };
    return json;
  }
}

class Translation {
  String? description = '';
  String? name = '';
  String? languageId = '';
  LanguageCode? languageCode;

  Translation(
      {this.description, this.name, this.languageId, this.languageCode});

  factory Translation.fromJson(Map<String, dynamic> json) {
    return Translation(
        name: json['name'],
        description: json['description'],
        languageId: json['languageId'],
        languageCode: json['languageCode'] == null
            ? null
            : EnumToString.fromString(
                LanguageCode.values, json['languageCode']));
  }
}

enum LanguageCode {
  ZH_CN,
  EN_US,
  ZH_TC,
  JA,
  KO,
  HI,
  NE,
  VI,
  TH,
  FR,
  DE,
  EL,
  AR
}
