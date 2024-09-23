import 'dart:async';

import 'package:flutter/material.dart';

import 'package:linkeat/widgets/storeCard.dart';
import 'package:linkeat/models/store.dart';
import 'package:linkeat/service/api.dart';
import 'package:linkeat/l10n/localizations.dart';

class PopularStores extends StatefulWidget {
  PopularStores({Key? key}) : super(key: key);

  @override
  _PopularStoresState createState() => _PopularStoresState();
}

class _PopularStoresState extends State<PopularStores> {
  Future<List<StoreSummary>>? futureStores;

  @override
  void initState() {
    super.initState();
    futureStores = fetchPopularStores(context);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<StoreSummary>>(
      future: futureStores,
      builder: (context, snapshot) {
        if (snapshot.hasData && snapshot.data!.length > 0) {
          return PopularSection(
            title: AppLocalizations.of(context)!.popularInTown!,
            stores: snapshot.data,
          );
        } else if (snapshot.hasError) {
          return Text("${snapshot.error}");
        }
        // By default, show a loading spinner.
        return Center(
          widthFactor: 9.5,
          heightFactor: 9.5,
          child: SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              backgroundColor: Colors.white,
              strokeWidth: 1.0,
            ),
          ),
        );
      },
    );
  }
}

class PopularSection extends StatelessWidget {
  const PopularSection({Key? key, required this.title, this.shape, this.stores})
      : assert(title != null, stores != null),
        super(key: key);

  // This height will allow for all the Card's content to fit comfortably within the card.
  // static const height = 254.0;
  final String title;
  final List<StoreSummary>? stores;
  final ShapeBorder? shape;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SectionTitle(title: title),
        for (final store in stores!)
          StoreCard(
            store: store,
          ),
      ],
    );
  }
}

class SectionTitle extends StatelessWidget {
  const SectionTitle({
    Key? key,
    this.title,
  }) : super(key: key);

  final String? title;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 20, 18, 3),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(title!, style: textTheme.headline6!.copyWith(fontSize: 24)),
      ),
    );
  }
}
