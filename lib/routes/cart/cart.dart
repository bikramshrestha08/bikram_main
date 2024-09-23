import 'package:linkeat/utils/store.dart';
import 'package:eva_icons_flutter/eva_icons_flutter.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:linkeat/l10n/localizations.dart';
import 'package:linkeat/states/cart.dart';
import 'package:linkeat/models/order.dart';
import 'package:linkeat/utils/sputil.dart';
import 'package:linkeat/config.dart';

import '../../models/routeArguments.dart';

class Cart extends StatelessWidget {
  static const routeName = '/cart';

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final cart = Provider.of<CartModel>(context);
    String? storeId;
    if (cart.storeDetail != null && cart.storeDetail!.uuid != null) {
      storeId = cart.storeDetail!.uuid;
    }
    var availableOrder = true;
    String? notAvaliableOrderReason = '';
    if (cart.type == OrderType.TAKEAWAY) {
      var _pickupTimeOptions =
      getTakeAwayTimeOptions(cart.storeDetail!.businessHour!);
      if (_pickupTimeOptions == null ||
          !cart.storeDetail!.storeConfig!.acceptTakeaway!) {
        availableOrder = false;
        notAvaliableOrderReason =
            AppLocalizations.of(context)!.pickupNotAvailable;
      }
    }

    if (cart.type == OrderType.DELIVERY) {
      if (!cart.storeDetail!.storeConfig!.acceptDelivery!) {
        availableOrder = false;
        notAvaliableOrderReason =
            AppLocalizations.of(context)!.deliveryNotAvailable;
      } else {
        var validDeliveryRanges = cart.storeDetail!.deliveryCfg!.deliveryRanges!
            .where((deliveryRange) =>
            deliveryRange.postCodes!.contains(Constants.DELIVERY_POSTCODE))
            .toList();
        if (validDeliveryRanges.isEmpty) {
          FocusScope.of(context).requestFocus(new FocusNode());
          availableOrder = false;
          notAvaliableOrderReason =
          '${AppLocalizations.of(context)!.postCodeNotAvailable} (${Constants.DELIVERY_POSTCODE})';
        } else {
          var deliveryRange = validDeliveryRanges[0];
          if (cart.cartTotal < deliveryRange.minimalOrderPrice!) {
            FocusScope.of(context).requestFocus(new FocusNode());
            availableOrder = false;
            notAvaliableOrderReason =
            '${AppLocalizations.of(context)!.deliveryMinOrderError} (\$${(deliveryRange.minimalOrderPrice! / 100).toString()})';
          } else {
            var _deliveryTimeOptions = getDeliveryTimeOptions(
                Constants.DELIVERY_POSTCODE, deliveryRange);
            if (_deliveryTimeOptions == null) {
              availableOrder = false;
              notAvaliableOrderReason =
                  AppLocalizations.of(context)!.deliveryNotAvailable;
            }
          }
        }
      }
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        iconTheme: IconThemeData(
          color: Colors.black87,
        ),
        title: Text(
          AppLocalizations.of(context)!.cart!,
          style: textTheme.headline5,
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.only(top: 10.0),
        child: _CartList(),
      ),
      bottomNavigationBar: _CheckoutBar(
        availableOrder: availableOrder,
        notAvaliableOrderReason: notAvaliableOrderReason,
        storeId: storeId,
      ),
    );
  }
}

class _CartList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var cart = Provider.of<CartModel>(context);
    return ListView.builder(
      itemCount: cart.cartItems.length,
      itemBuilder: (context, index) =>
          _CartItem(cartItem: cart.cartItems[index], index: index),
    );
  }
}

class _CartItem extends StatelessWidget {
  final CartItem cartItem;
  final int index;

  _CartItem({
    Key? key,
    required this.cartItem,
    required this.index,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    var cart = Provider.of<CartModel>(context, listen: false);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
      child: LimitedBox(
        child: Column(
          children: <Widget>[
            Row(
              children: [
                SizedBox(
                  width: 30.0,
                  child: Text(cartItem.quantity.toString() + ' X'),
                ),
                Expanded(
                  child: Text(
                    cartItem.product!.name!,
                    style: textTheme.subtitle2,
                  ),
                ),
                Text('\$' + (cartItem.product!.price! / 100).toString()),
                SizedBox(
                  width: 10.0,
                ),
                IconButton(
                  iconSize: 20.0,
                  icon: Icon(
                    EvaIcons.closeCircleOutline,
                    color: Colors.grey,
                  ),
                  tooltip: 'Remove',
                  onPressed: () {
                    cart.removeFromCart(index);
                  },
                ),
              ],
            ),
            Container(
              child: cartItem.options!.isNotEmpty
                  ? Column(
                children: <Widget>[
                  for (final optionState in cartItem.options!)
                    Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          SizedBox(
                            width: 15.0,
                          ),
                          Align(
                            alignment: Alignment.topLeft,
                            child: Text(
                              optionState.option!.name! + ':',
                              style: textTheme.caption,
                            ),
                          ),
                          SizedBox(
                            width: 5.0,
                          ),
                          Column(
                            children: <Widget>[
                              for (final optionValueState in optionState
                                  .optionValuesState!
                                  .where((item) => item.quantity! > 0)
                                  .toList())
                                Row(
                                  children: <Widget>[
                                    Text(
                                      optionValueState.optionValue!.name!,
                                      style: textTheme.caption,
                                    ),
                                    Container(
                                      child: optionValueState
                                          .optionValue!.price! >
                                          0
                                          ? Text(
                                        ' (\$${(optionValueState.optionValue!.price! / 100).toString()})',
                                        style: textTheme.caption,
                                      )
                                          : SizedBox.shrink(),
                                    ),
                                    SizedBox(
                                      width: 10.0,
                                    ),
                                    Text(
                                      'X ' +
                                          optionValueState.quantity
                                              .toString(),
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

class _CheckoutBar extends StatelessWidget {
  final bool availableOrder;
  final String? notAvaliableOrderReason;
  final String? storeId;

  const _CheckoutBar(
      {Key? key,
        required this.availableOrder,
        required this.notAvaliableOrderReason,
        required this.storeId})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    var cart = Provider.of<CartModel>(context);
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    var platform = Theme.of(context).platform;
    double paddingBottom = 0;
    if (platform == TargetPlatform.iOS &&
        MediaQuery.of(context).padding.bottom > 0) {
      paddingBottom = 20;
    }
    return Container(
        color: availableOrder ? colorScheme.primary : Colors.grey,
        child: availableOrder
            ? SafeArea(
          minimum: EdgeInsets.only(bottom: paddingBottom),
          bottom: false,
          child: Container(
            color: colorScheme.primary,
            child: TextButton(
              onPressed: () {
                String? token =
                SpUtil.preferences.getString('accessToken');
                if (token != null) {
                  Navigator.pushNamed(
                    context,
                    cart.type == OrderType.DELIVERY
                        ? '/checkoutDelivery'
                        : '/checkoutTakeaway',
                  );
                } else {
                  Navigator.pushNamed(
                    context,
                      '/membership_login/?storeid=$storeId',arguments: LoginArguments(false)
                  );
                }
              },
              child: Container(
                height: 60.0,
                child: Row(
                  children: <Widget>[
                    SizedBox(
                      width: 10.0,
                    ),
                    ClipOval(
                      child: Container(
                        width: 25.0,
                        height: 25.0,
                        color: Colors.white,
                        child: Center(
                          child: Text(
                            cart.cartTotalQuantity.toString(),
                            style: textTheme.bodyText2!
                                .copyWith(fontSize: 15.0),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      width: 10.0,
                    ),
                    Text(
                      '\$' + (cart.cartTotal / 100).toString(),
                      style: textTheme.subtitle1!
                          .copyWith(color: Colors.white, fontSize: 18),
                    ),
                    Expanded(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: <Widget>[
                          Text(
                            AppLocalizations.of(context)!.checkout!,
                            style: textTheme.subtitle1!.copyWith(
                                color: Colors.white, fontSize: 18),
                          ),
                          SizedBox(
                            width: 10.0,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        )
            : SafeArea(
          minimum: EdgeInsets.only(bottom: paddingBottom),
          bottom: false,
          child: Container(
            color: Colors.grey,
            child: TextButton(
              onPressed: null,
              child: Container(
                height: 60.0,
                child: Center(
                  child: Text(
                    notAvaliableOrderReason!,
                    style: textTheme.subtitle2!
                        .copyWith(color: Colors.white, fontSize: 13),
                  ),
                ),
              ),
            ),
          ),
        ));
  }
}
