

import 'package:eva_icons_flutter/eva_icons_flutter.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:loadmore/loadmore.dart';

class CustomizedLoadMoreDelegate extends LoadMoreDelegate {
  const CustomizedLoadMoreDelegate(this.ctx, this.scrollToTop);

  final BuildContext ctx;
  final Function scrollToTop;

  @override
  Widget buildChild(LoadMoreStatus status,
      {LoadMoreTextBuilder builder = DefaultLoadMoreTextBuilder.english}) {
    String text = builder(status);
    final textTheme = Theme.of(ctx).textTheme;
    final colorScheme = Theme.of(ctx).colorScheme;
    if (status == LoadMoreStatus.fail) {
      return Container(
        child: Text(
          text.toUpperCase(),
          style: textTheme.caption,
        ),
      );
    }
    if (status == LoadMoreStatus.idle) {
      return Text(
        text.toUpperCase(),
        style: textTheme.caption,
      );
    }
    if (status == LoadMoreStatus.loading) {
      return Container(
        alignment: Alignment.center,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            SizedBox(
              width: 13,
              height: 13,
              child: CircularProgressIndicator(
                backgroundColor: Colors.grey[300],
                strokeWidth: 1,
              ),
            ),
            Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  text.toUpperCase(),
                  style: textTheme.caption,
                )),
          ],
        ),
      );
    }
    if (status == LoadMoreStatus.nomore) {
      return SizedBox(
          height: 40,
          width: 40,
          child: FloatingActionButton(
        child: Icon(
          EvaIcons.arrowIosUpwardOutline,
          color: Colors.white,
        ),
        backgroundColor: colorScheme.primary,
        onPressed: () {
          scrollToTop();
        },
            elevation: 2,
      ));
    }

    return Text(
      text.toUpperCase(),
      style: textTheme.caption,
    );
  }
}
