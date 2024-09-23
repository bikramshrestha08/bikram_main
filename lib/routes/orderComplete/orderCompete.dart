import 'package:eva_icons_flutter/eva_icons_flutter.dart';
import 'package:flutter/material.dart';

import 'package:linkeat/l10n/localizations.dart';

class OrderComplete extends StatelessWidget {
  static const routeName = '/orderComplete';
  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.white,
        // brightness: Theme.of(context).platform == TargetPlatform.android
        //     ? Brightness.dark
        //     : Brightness.light,
        iconTheme: IconThemeData(
          color: Colors.black87,
        ),
        title: Text(
          AppLocalizations.of(context)!.orderComplete!,
          style: textTheme.headline5,
        ),
        centerTitle: true,
      ),
      body: Center(
        child: Column(
          children: <Widget>[
            Padding(
              padding: EdgeInsets.all(50.0),
              child: Center(
                child: Icon(
                  EvaIcons.checkmarkCircle2Outline,
                  size: 70.0,
                  color: colorScheme.primary,
                ),
              ),
            ),
            SizedBox(
              width: 150,
              height: 45,
              child: OutlinedButton(
                // highlightedBorderColor: Colors.grey[400],
                // highlightColor: Colors.grey[200],
                // shape: RoundedRectangleBorder(
                //     borderRadius: BorderRadius.circular(30.0)),
                onPressed: () {
                  Navigator.pushNamedAndRemoveUntil(context, '/', (_) => false);
                },
                child: Text(
                  AppLocalizations.of(context)!.backToHome!,
                  style: textTheme.button,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
