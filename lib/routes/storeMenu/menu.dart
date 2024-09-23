import 'package:linkeat/models/store.dart';
import 'package:linkeat/states/app.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:provider/provider.dart';

import 'package:linkeat/states/cart.dart';
import 'package:linkeat/l10n/localizations.dart';
import 'package:linkeat/routes/storeMenu/item.dart';

class StoreMenu extends StatefulWidget {
  static const routeName = '/storeMenu';
  final String? uuid;

  StoreMenu({
    Key? key,
    required this.uuid,
  }) : super(key: key);

  @override
  _StoreMenuState createState() => _StoreMenuState();
}

// class _StoreMenuState extends State<StoreMenu> {
//   Future<List<Category>?>? futureCategories;
//   Future<List<Record>?>? futureSpecialTags;

//   @override
//   void initState() {
//     super.initState();
//     var appModel = Provider.of<AppModel>(context, listen: false);
//     var cartModel = Provider.of<CartModel>(context, listen: false);
//     futureCategories = cartModel.fetchStoreMenu(
//         widget.uuid, appModel.getLanguageCode(), context);
//     futureSpecialTags = cartModel.fetchSpecialTags(widget.uuid!, context);
//   }

class _StoreMenuState extends State<StoreMenu> {
  Future<List<Category>?>? futureCategories; // 使用 Future<List<Category>?> 来存储异步加载的数据

  @override
  void initState() {
    super.initState();
    futureCategories = fetchMenuData(); // 在 initState 中初始化 futureCategories
  }

  Future<List<Category>?> fetchMenuData() async {
    var appModel = Provider.of<AppModel>(context, listen: false);
    var cartModel = Provider.of<CartModel>(context, listen: false);

    try {
      final List<Record> specialTags = await cartModel.fetchSpecialTags(widget.uuid!, context);
      final List<Category> normalCategories = await cartModel.fetchStoreMenu(widget.uuid!, appModel.getLanguageCode(), context) ?? [];


      List<Category> specialTagCategories = []; // 存储转换后的特殊标签分类

      // 将 Record 转换为 Category，这里假设 Record 有足够的信息
      for (var record in specialTags) {
        var category = Category(
          id: record.id,
          name: record.name,
          sortOrder: record.sortOrder,
          products: record.products?.map((product) => Product.fromJson(product.toJson())).toList(),
        );
        specialTagCategories.add(category);
      }

      // 合并特殊标签分类和普通分类
      List<Category> combinedCategories = [...specialTagCategories, ...normalCategories];
      return combinedCategories; // 返回合并后的分类列表
    } catch (error) {
      print("Error fetching menu data: $error");
      return null; // 发生错误时返回null
    }
  }
  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    var cart = Provider.of<CartModel>(context);
    var storeDetail = cart.storeDetail;
    return WillPopScope(
      child: FutureBuilder<List<Category>?>(
        future: futureCategories,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            var categories = snapshot.data!;
            return DefaultTabController(
              length: categories.length,
              child: Scaffold(
                backgroundColor: Colors.white,
                appBar: AppBar(
//        automaticallyImplyLeading: false,
                  systemOverlayStyle: SystemUiOverlayStyle(
                      statusBarBrightness: Brightness.light),
                  backgroundColor: Colors.white,
                  iconTheme: IconThemeData(
                    color: Colors.black87,
                  ),
                  // title: Text(
                  //   storeDetail?.name,
                  //   style: textTheme.headline5,
                  // ),
                  bottom: TabBar(
                    labelColor: Colors.black87,
                    isScrollable: true,
                    tabs: [
                      for (final category in categories)
                        Tab(
                          child:
                              Text(category.name!, style: textTheme.subtitle1),
                        ),
                    ],
                  ),
                ),
                body: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 10.0),
                  child: categories.length > 0
                      ? TabBarView(
                          children: [
                            for (final category in categories)
                              ListView.builder(
                                  padding: const EdgeInsets.all(8),
                                  itemCount:
                                      category.getItemsByType(cart.type).length,
                                  itemBuilder:
                                      (BuildContext context, int index) {
                                    return Column(
                                      children: <Widget>[
                                        MenuItem(
                                          item: category
                                              .getItemsByType(cart.type)[index],
                                          storeOpened: storeDetail!.isOpened(),
                                        ),
                                        Divider(),
                                      ],
                                    );
                                  }),
                          ],
                        )
                      : Center(
                          child: Text(
                            'No Data',
                            style: textTheme.caption,
                          ),
                        ),
                ),
                bottomNavigationBar: cart.cartTotalQuantity > 0
                    ? _CartTotalBar()
                    : SizedBox.shrink(),
              ),
            );
          } else if (snapshot.hasError) {
            return Text("${snapshot.error}");
          }

          // By default, show a loading spinner.
          return Scaffold(
            backgroundColor: Colors.white,
            body: Center(
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  backgroundColor: Colors.white,
                  strokeWidth: 1.0,
                ),
              ),
            ),
          );
        },
      ),
      onWillPop: () async {
        cart.emptyCart();
        Navigator.of(context).pop();
        return true;
      },
    );
  }
}

class _CartTotalBar extends StatelessWidget {
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
      color: colorScheme.primary,
      child: TextButton(
        onPressed: () {
          Navigator.pushNamed(
            context,
            '/cart',
          );
        },
        child: SafeArea(
          minimum: EdgeInsets.only(bottom: paddingBottom),
          bottom: false,
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
                        style: textTheme.bodyText2!.copyWith(fontSize: 15.0),
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
                        AppLocalizations.of(context)!.viewCart!,
                        style: textTheme.subtitle1!
                            .copyWith(color: Colors.white, fontSize: 18),
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
    );
  }
}
