import 'package:linkeat/states/app.dart';
import 'package:flutter/material.dart';

import 'package:cached_network_image/cached_network_image.dart';

import 'package:linkeat/models/store.dart';
import 'package:linkeat/models/routeArguments.dart';
import 'package:provider/provider.dart';

class StoreCard extends StatelessWidget {
  const StoreCard({Key? key, required this.store, this.shape})
      : assert(store != null),
        super(key: key);

  final StoreSummary store;
  final ShapeBorder? shape;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    var appModel = Provider.of<AppModel>(context, listen: false);
    return Container(
      padding: EdgeInsets.fromLTRB(18, 15, 18, 10),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(width: 1, color: Colors.black12),
        ),
      ),
      child: InkWell(
        onTap: () {
          Navigator.pushNamed(
            context,
            '/storeHome',
            arguments: StoreHomeArguments(
              store.uuid,
            ),
          );
        },
        // Generally, material cards use onSurface with 12% opacity for the pressed state.
        // splashColor: Theme.of(context).colorScheme.onSurface.withOpacity(0.12),
        // Generally, material cards do not have a highlight overlay.
        highlightColor: Colors.transparent,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: 184,
              child: Stack(
                children: [
                  Positioned.fill(
                    child: CachedNetworkImage(
                      imageUrl: store.bannerUrls![0],
                      placeholder: (context, url) => Center(
                        child: SizedBox(
                          height: 20.0,
                          width: 20.0,
                          child: CircularProgressIndicator(
                            strokeWidth: 1.0,
                          ),
                        ),
                      ),
                      errorWidget: (context, url, error) => Icon(Icons.error),
                      fit: BoxFit.cover,
                    ),
                  ),
                ],
              ),
            ),
            // Description and share/explore buttons.
            Padding(
              padding: const EdgeInsets.fromLTRB(0, 15, 0, 0),
              child: Text(store.getTranslatedName(appModel.getLanguageCode())!,
                  style: Theme.of(context)
                      .textTheme
                      .subtitle1!
                      .copyWith(fontWeight: FontWeight.w600)),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(0, 5, 0, 0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  for (final tag in store.tags!)
                    Padding(
                      padding: EdgeInsets.only(right: 10),
                      child: Text(tag,
                          style: textTheme.caption!.copyWith(fontSize: 11)),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
