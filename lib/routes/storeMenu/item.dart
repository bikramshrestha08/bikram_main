import 'package:flutter/material.dart';

import 'package:cached_network_image/cached_network_image.dart';

import 'package:linkeat/models/store.dart';
import 'package:linkeat/models/routeArguments.dart';

class MenuItem extends StatelessWidget {
  final Product item;
  final bool storeOpened;

  MenuItem({
    Key? key,
    required this.item,
    required this.storeOpened,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: LimitedBox(
        // maxHeight: 80,
        child: InkWell(
          onTap: () {
            Navigator.pushNamed(
              context,
              '/productDetail',
              arguments: ProductDetailArguments(
                item,
                storeOpened,
              ),
            );
          },
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      item.name!,
                      style: textTheme.subtitle2,
                    ),
                    SizedBox(
                      height: 5,
                    ),
//                  Text(item.description, style: textTheme.caption),
                    Text(
                      '\$' + (item.price! / 100).toString(),
                      style: textTheme.bodyText2,
                    ),
                  ],
                ),
              ),
              SizedBox(width: 24),
              (item.imgUrl != null && item.imgUrl!.isNotEmpty)
                  ? Hero(
                      tag: item.id!,
                      child: CachedNetworkImage(
                        imageUrl: item.imgUrl!,
                        placeholder: (context, url) => Center(
                          child: SizedBox(
                            height: 10.0,
                            width: 10.0,
                            child: CircularProgressIndicator(
                              strokeWidth: 1.0,
                            ),
                          ),
                        ),
                        errorWidget: (context, url, error) => Icon(Icons.error),
                        width: 80,
                        height: 80,
                        fit: BoxFit.cover,
                      ),
                    )
                  : SizedBox.shrink(),
            ],
          ),
        ),
      ),
    );
  }
}
