import 'package:flutter/material.dart';

import 'package:provider/provider.dart';
import 'package:eva_icons_flutter/eva_icons_flutter.dart';

import 'package:linkeat/models/store.dart';
import 'package:linkeat/states/cart.dart';
import 'package:linkeat/routes/store/slider.dart';
import 'package:linkeat/l10n/localizations.dart';
import 'package:linkeat/routes/product/options.dart';

class ProductDetail extends StatefulWidget {
  static const routeName = '/productDetail';
  final Product product;
  final bool storeOpened;

  ProductDetail({
    Key? key,
    required this.product,
    required this.storeOpened,
  }) : super(key: key);

  @override
  _ProductDetailState createState() => _ProductDetailState();
}

class _ProductDetailState extends State<ProductDetail> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  late int quantity;
  List<OptionState>? optionsState;

  // TODO options

  void showInSnackBar(String value) {
    // _scaffoldKey.currentState.showSnackBar(SnackBar(
    //   content: Text(value),
    // ));
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(value),
    ));
  }

  @override
  void initState() {
    super.initState();
    quantity = 1;
    if (widget.product.type != 'BASIC' && widget.product.options!.length > 0) {
      optionsState = widget.product.options!
          .map((i) => OptionState(
              option: i,
              optionValuesState: i.optionValues!
                  .map((k) => OptionValueState(optionValue: k))
                  .toList()))
          .toList();
    }
  }

  void changeOptionValueQuantity(
      {required int optionIdx,
      required int optionValueIdx,
      required int quantity}) {
    var newOptionsState = optionsState!;
    newOptionsState[optionIdx].optionValuesState![optionValueIdx].quantity =
        quantity;
    setState(() {
      optionsState = newOptionsState
          .map((optionState) => OptionState(
                optionValuesState: optionState.optionValuesState,
                option: optionState.option,
                quantity: optionState.optionValuesState!
                    .fold(0, (total, current) => total + current.quantity!),
                reachMaxLimit: optionState.option!.max! > 0 &&
                    optionState.optionValuesState!.fold(
                            0,
                            (dynamic total, current) =>
                                total + current.quantity) >=
                        optionState.option!.max,
              ))
          .toList();
    });
  }

  void addToCart() {
    var cart = Provider.of<CartModel>(context, listen: false);
    if (optionsState != null) {
      var invalidOptions = optionsState!
          .where((optionState) =>
              optionState.option!.min! > 0 &&
              optionState.quantity < optionState.option!.min!)
          .toList();
      if (invalidOptions.length > 0) {
        showInSnackBar(
          'Please check options',
        );
        return;
      }
    }
    cart.addToCart(widget.product, quantity, optionsState ?? []);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;
    return Scaffold(
        key: _scaffoldKey,
        backgroundColor: Colors.white,
        appBar: PreferredSize(
            preferredSize: Size.fromHeight(0.0), // here the desired height
            child: AppBar()),
        floatingActionButton: Padding(
          padding: const EdgeInsets.only(top: 20.0),
          child: FloatingActionButton(
              heroTag: 'back',
              onPressed: () => print("FloatingActionButton"),
              child: IconButton(
                  icon: Icon(EvaIcons.arrowIosBackOutline),
                  onPressed: () => Navigator.pop(context)),
              foregroundColor: Colors.black87,
              backgroundColor: Colors.white,
              elevation: 2.0,
              mini: true,
              // highlightElevation: 12.0,
              shape: CircleBorder()),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.startTop,
        body: Scrollbar(
          child: ListView(
            children: <Widget>[
              widget.product.imgUrl != null
                  ? Hero(
                      tag: widget.product.id!,
                      child: StoreSlider(
                        bannerUrl: [widget.product.imgUrl],
                      ),
                    )
                  : SizedBox(
                      height: 80.0,
                    ),
              SizedBox(
                height: 10,
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.0),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(widget.product.name!,
                      style: textTheme.headline5!.copyWith(fontSize: 24)),
                ),
              ),
              SizedBox(
                height: 10,
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.0),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text('\$' + (widget.product.price! / 100).toString(),
                      style: textTheme.headline5),
                ),
              ),
              SizedBox(
                height: 10,
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.0),
                child: (optionsState != null)
                    ? Column(
                        children: <Widget>[
//                          Divider(),
                          for (final optionState in optionsState!)
                            Column(
                              children: <Widget>[
                                Divider(),
                                Row(
                                  children: <Widget>[
                                    Align(
                                      alignment: Alignment.centerLeft,
                                      child: Text(
                                        optionState.option!.name!,
                                        style: textTheme.subtitle2,
                                      ),
                                    ),
                                    Expanded(
                                      child: Align(
                                        alignment: Alignment.centerRight,
                                        child: optionState.option!.min! > 0
                                            ? Text(
                                                'Required',
                                                style: textTheme.caption!
                                                    .copyWith(
                                                        color: colorScheme
                                                            .primary),
                                              )
                                            : SizedBox.shrink(),
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(
                                  height: 5,
                                ),
                                Align(
                                  alignment: Alignment.centerLeft,
                                  child: optionState.option!.min ==
                                              optionState.option!.max &&
                                          optionState.option!.min! > 0 &&
                                          optionState.option!.max != 0
                                      ? Text(
                                          '(${AppLocalizations.of(context)!.optionPick} ${optionState.option!.min} ${AppLocalizations.of(context)!.optionItem})',
                                          style: textTheme.caption,
                                        )
                                      : SizedBox.shrink(),
                                ),
                                Align(
                                  alignment: Alignment.centerLeft,
                                  child: optionState.option!.min !=
                                              optionState.option!.max &&
                                          optionState.option!.min! >= 0 &&
                                          optionState.option!.max != 0
                                      ? Text(
                                          '(${AppLocalizations.of(context)!.optionPick}${optionState.option!.min}~${optionState.option!.max}${AppLocalizations.of(context)!.optionItem})',
                                          style: textTheme.caption,
                                        )
                                      : SizedBox.shrink(),
                                ),
                                Divider(),
                                for (final optionValueState
                                    in optionState.optionValuesState!)
                                  OptionValueView(
                                    optionIdx:
                                        optionsState!.indexOf(optionState),
                                    optionValueIdx: optionState
                                        .optionValuesState!
                                        .indexOf(optionValueState),
                                    optionValueState: optionValueState,
                                    changeOptionValueQuantity:
                                        changeOptionValueQuantity,
                                    reachMaxLimit: optionState.reachMaxLimit,
                                  ),
                              ],
                            ),
                        ],
                      )
                    : SizedBox.shrink(),
              ),
              Divider(),
              SizedBox(
                height: 20,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  IconButton(
                    iconSize: 50.0,
                    disabledColor: Colors.grey[300],
                    icon: Icon(EvaIcons.minusCircleOutline),
                    tooltip: 'Decrease Quantity',
                    onPressed: quantity > 1
                        ? () {
                            setState(() {
                              quantity -= 1;
                            });
                          }
                        : null,
                  ),
                  SizedBox(
                    width: 6,
                  ),
                  Text(
                    quantity.toString(),
                    style: textTheme.headline5,
                  ),
                  SizedBox(
                    width: 6,
                  ),
                  IconButton(
                    iconSize: 50.0,
                    disabledColor: Colors.grey[300],
                    icon: Icon(EvaIcons.plusCircleOutline),
                    tooltip: 'Increase Quantity',
                    onPressed: () {
                      setState(() {
                        quantity += 1;
                      });
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
        bottomNavigationBar: _AddButton(
          addToCart: addToCart,
          storeOpened: widget.storeOpened,
        ));
  }
}

class _AddButton extends StatelessWidget {
  final Function addToCart;
  final bool storeOpened;

  const _AddButton(
      {Key? key, required this.addToCart, required this.storeOpened})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    var platform = Theme.of(context).platform;
    double paddingBottom = 0;
    if (platform == TargetPlatform.iOS &&
        MediaQuery.of(context).padding.bottom > 0) {
      paddingBottom = 20;
    }

    return Container(
        color: colorScheme.primary,
        child: SafeArea(
          minimum: EdgeInsets.only(bottom: paddingBottom),
          bottom: false,
          child: Container(
            color: colorScheme.primary,
            child: TextButton(
              onPressed: () {
                addToCart();
              },
              child: Container(
                height: 60.0,
                child: Center(
                  child: Text(
                    AppLocalizations.of(context)!.addToCart!,
                    style: textTheme.subtitle1!
                        .copyWith(color: Colors.white, fontSize: 20),
                  ),
                ),
              ),
            ),
          ),
        ));
  }
}
