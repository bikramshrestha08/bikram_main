import 'dart:convert';

import 'package:linkeat/models/store.dart';
import 'package:flutter/material.dart';
import 'package:another_flushbar/flushbar.dart';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:enum_to_string/enum_to_string.dart';

import 'package:linkeat/states/cart.dart';
import 'package:linkeat/states/app.dart';

import 'package:linkeat/models/routeArguments.dart';
import 'package:linkeat/models/order.dart';
import 'package:linkeat/l10n/localizations.dart';
import 'package:linkeat/utils/datetime_util.dart';

import 'package:provider/provider.dart';

import '../../service/request.dart';
import '../../utils/sputil.dart';

String? getTranslatedName(
    String languageCode, List<TranslationSnapshot>? translationSnapshots) {
  if (translationSnapshots != null) {
    for (var translation in translationSnapshots) {
      if (translation.languageCode == languageCode) return translation.name;
    }
  }
  return null;
}

class OrderCard extends StatelessWidget {
  final Order order;
  final Function? onRefresh;

  OrderCard({
    Key? key,
    required this.order,
    this.onRefresh,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final appModel = Provider.of<AppModel>(context, listen: false);
    final textTheme = Theme.of(context).textTheme;

    final Map<String, Color?> statusColor = {
      'PENDING': Theme.of(context).colorScheme.primary,
      'PROCESSING': Theme.of(context).colorScheme.primary,
      'COMPLETED': Colors.green[200], // only for takeaway
      'DISPATCHED': Theme.of(context).colorScheme.primary,
      'DELIVERED': Colors.green[200],
      'DECLINED': Colors.grey[350],
      'CANCELLED': Colors.grey[350],
      'COLLECTED': Colors.green[200]
    };

    Future<void> onPressed() async {
      String? token = SpUtil.preferences.getString('accessToken');
      if (token == null) {
        return;
      }
      final response = await Services.asyncRequest('PUT',
          '/store/v2/${order.store!.id}/order/${order.uuid}/status', context,
          payload: {
            "action": "COLLECTED",
            "reason": "string",
            "note": "string"
          });
      // var data = json.decode(response.toString());
      if (onRefresh != null) await onRefresh!();
    }

    Product? getProductFromCategories(List<Category> categories, String? id) {
      for (Category category in categories) {
        for (Product product in category.products!) {
          if (product.id == id) return product;
        }
      }
      return null;
    }

    Option? getOptionFromProduct(
        Product product, OrderItemSelectionSnapshot optionSnapshot) {
      for (Option option in product.options!) {
        if (option.code == optionSnapshot.code) return option;
      }
      return null;
    }

    OptionValue? getOptionValueFromOption(Option option,
        OrderItemSelectionValueSnapshot optionSelectionSnapshot) {
      for (var optionValue in option.optionValues!) {
        var translatedName = getTranslatedName(appModel.getLanguageCode(),
                optionSelectionSnapshot.translations) ??
            optionSelectionSnapshot.name;
        print(translatedName);
        if (optionValue.name == translatedName) return optionValue;
      }
      return null;
    }

    Future<bool?> showWarningDialog(
        String? title, String? content, String? buttonText) {
      return showDialog<bool>(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text(title!),
            content: Text(content!),
            actions: <Widget>[
              TextButton(
                child: Text(buttonText!),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          );
        },
      );
    }

    List<OptionState>? mapOptionState(OrderItem item, Product? product) {
      List<OptionState> optionStates = [];
      for (OrderItemSelectionSnapshot optionSnapShot in item.options!) {
        Option? option = getOptionFromProduct(product!, optionSnapShot);
        if (option == null) {
          return null;
        }
        var optionState =
            OptionState(optionValuesState: [], quantity: 1, option: option);
        for (OrderItemSelectionValueSnapshot optionSelectionSnapshot
            in optionSnapShot.selections!) {
          var optionValue =
              getOptionValueFromOption(option, optionSelectionSnapshot);
          if (optionValue == null) {
            return null;
          }
          optionState.optionValuesState!.add(
            OptionValueState(
                optionValue: OptionValue(
                  name: optionValue.name,
                  price: optionValue.price,
                  value: optionSelectionSnapshot.value,
                ),
                quantity: optionSelectionSnapshot.quantity),
          );
        }
        optionStates.add(optionState);
      }
      return optionStates;
    }

    Future<void> onOrderAgainPressed() async {
      var storeId = order.store!.id;
      var cart = Provider.of<CartModel>(context, listen: false);
      List<Category>? categories;

      cart.setOrderType(order.type);
      try {
        categories = await cart.fetchStoreMenu(
            storeId, appModel.getLanguageCode(), context);
        await cart.fetchStoreDetail(
            order.store!.id, appModel.getLanguageCode(), context);
      } catch (error) {
        await showWarningDialog(
          AppLocalizations.of(context)!.notification,
          AppLocalizations.of(context)!.storeNotFound,
          AppLocalizations.of(context)!.confirm,
        );
        return;
      }

      order.items!.forEach((item) {
        var product = getProductFromCategories(categories!, item.product!.id);
        var optionStates = mapOptionState(item, product);

        if (product == null || optionStates == null) return;

        cart.addToCart(product, item.quantity, optionStates);
      });

      if (cart.cartItems.length < order.items!.length) {
        await showWarningDialog(
          AppLocalizations.of(context)!.notification,
          AppLocalizations.of(context)!.itemModified,
          AppLocalizations.of(context)!.confirm,
        );
        Navigator.pushNamed(context, '/storeMenu',
            arguments: StoreMenuArguments(order.store!.id));
      } else {
        Navigator.pushNamed(context, '/storeMenu',
            arguments: StoreMenuArguments(order.store!.id));
      }
    }

    return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: LimitedBox(
            child: Card(
          // This ensures that the Card's children (including the ink splash) are clipped correctly.
          margin: EdgeInsets.only(bottom: 15.0),
          clipBehavior: Clip.antiAlias,
//            shape: shape,
          child: Column(children: <Widget>[
            Container(
              color: statusColor[order.getFriendlyStatus()],
              height: 35.0,
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 10),
                child: Center(
                  child: Text(
                      AppLocalizations.of(context)!
                          .getByKey(order.getFriendlyStatus())!,
                      style:
                          textTheme.bodyText1!.copyWith(color: Colors.white)),
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: <Widget>[
                      ClipOval(
                        child: CachedNetworkImage(
                          imageUrl: order.store!.logoImgUrl!,
                          placeholder: (context, url) => Center(
                            child: SizedBox(
                              height: 20.0,
                              width: 20.0,
                              child: CircularProgressIndicator(
                                strokeWidth: 1.0,
                              ),
                            ),
                          ),
                          errorWidget: (context, url, error) =>
                              Icon(Icons.error),
                          width: 40,
                          height: 40,
                          fit: BoxFit.cover,
                        ),
                      ),
                      SizedBox(
                        width: 10.0,
                      ),
                      Expanded(
                        child: Text(order.store!.name!),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 8.0,
                  ),
                  Text(
                    DateTimeUtil.formatDisplay(order.createdAt!, 'MM-dd HH:mm'),
                    style: textTheme.caption,
                  ),
                  SizedBox(
                    height: 5.0,
                  ),
                  Text(
                    'Order # ${order.orderNumber}',
                    style: textTheme.caption,
                  ),
                  SizedBox(
                    height: 5.0,
                  ),
                  Divider(),
                  for (final orderItem in order.items!)
                    _OrderItem(
                      orderItem: orderItem,
                    ),
                  SizedBox(
                    height: 5.0,
                  ),
                  if (order.type == OrderType.TAKEAWAY &&
                      order.status == OrderStatus.COMPLETED)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        ElevatedButton(
                            onPressed: onPressed,
                            style: ButtonStyle(
                                backgroundColor:
                                    MaterialStateProperty.all<Color>(
                                        Theme.of(context).colorScheme.primary),
                                shape: MaterialStateProperty.all<
                                        RoundedRectangleBorder>(
                                    RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(18.0),
                                ))),
                            child: Text(
                              AppLocalizations.of(context)!.pick!,
                              style: textTheme.button!
                                  .copyWith(color: Colors.white),
                            )),
                        Text(
                          '${AppLocalizations.of(context)!.total}: \$' +
                              (order.amount! / 100).toString(),
                        )
                      ],
                    )
                  else if (order.status == OrderStatus.COLLECTED)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        ElevatedButton(
                            onPressed: onOrderAgainPressed,
                            style: ButtonStyle(
                                backgroundColor:
                                    MaterialStateProperty.all<Color>(
                                        Theme.of(context).colorScheme.primary),
                                shape: MaterialStateProperty.all<
                                        RoundedRectangleBorder>(
                                    RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(18.0),
                                ))),
                            child: Text(
                              AppLocalizations.of(context)!.orderAgain!,
                              style: textTheme.button!
                                  .copyWith(color: Colors.white),
                            )),
                        Text(
                          '${AppLocalizations.of(context)!.total}: \$' +
                              (order.amount! / 100).toString(),
                        )
                      ],
                    )
                  else
                    Align(
                      alignment: Alignment.centerRight,
                      child: Text(
                        '${AppLocalizations.of(context)!.total}: \$' +
                            (order.amount! / 100).toString(),
                      ),
                    ),
                ],
              ),
            ),
          ]),
        )));
  }
}

class _OrderItem extends StatelessWidget {
  final OrderItem orderItem;

  _OrderItem({
    Key? key,
    required this.orderItem,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final AppModel appModel = Provider.of<AppModel>(context, listen: false);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 0),
      child: LimitedBox(
        child: Column(
          children: <Widget>[
            Row(
              children: [
                SizedBox(
                  width: 30.0,
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      orderItem.quantity.toString() + ' X',
                      style: textTheme.caption,
                    ),
                  ),
                ),
                Expanded(
                  child: Text(
                    getTranslatedName(appModel.getLanguageCode(),
                            orderItem.product!.translations) ??
                        orderItem.product!.name!,
                    style: textTheme.caption,
                  ),
                ),
                Text(
                  '\$' + (orderItem.unitPrice! / 100).toString(),
                  style: textTheme.caption,
                ),
              ],
            ),
            Container(
              child: orderItem.options!.length > 0
                  ? Column(
                      children: <Widget>[
                        for (final option in orderItem.options!)
                          Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                SizedBox(
                                  width: 15.0,
                                ),
                                Align(
                                  alignment: Alignment.topLeft,
                                  child: Text(
                                    getTranslatedName(
                                            appModel.getLanguageCode(),
                                            option.translations) ??
                                        option.name! + ':',
                                    style: textTheme.caption,
                                  ),
                                ),
                                SizedBox(
                                  width: 5.0,
                                ),
                                Column(
                                  children: <Widget>[
                                    for (final selection in option.selections!)
                                      Row(
                                        children: <Widget>[
                                          Text(
                                            getTranslatedName(
                                                    appModel.getLanguageCode(),
                                                    selection.translations) ??
                                                selection.name!,
                                            style: textTheme.caption,
                                          ),
                                          Container(
                                            child: selection.price! > 0
                                                ? Text(
                                                    ' (\$${(selection.price! / 100).toString()})',
                                                    style: textTheme.caption,
                                                  )
                                                : SizedBox.shrink(),
                                          ),
                                          SizedBox(
                                            width: 10.0,
                                          ),
                                          Text(
                                            'X ' +
                                                selection.quantity.toString(),
                                            style: textTheme.caption,
                                          ),
                                        ],
                                      ),
                                    SizedBox(
                                      height: 5.0,
                                    ),
                                  ],
                                ),
                              ]),
                      ],
                    )
                  : SizedBox.shrink(),
            ),
            Divider(),
          ],
        ),
      ),
    );
  }
}
