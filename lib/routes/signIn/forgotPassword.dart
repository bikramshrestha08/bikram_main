import 'package:flutter/material.dart';

import 'package:linkeat/l10n/localizations.dart';
import 'package:linkeat/routes/signIn/forgotPasswordForm.dart';

class ForgotPassword extends StatelessWidget {
  static const routeName = '/forgotPassword';

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
//        automaticallyImplyLeading: false,
        backgroundColor: Colors.white,
        // brightness: Theme.of(context).platform == TargetPlatform.android
        //     ? Brightness.dark
        //     : Brightness.light,
        iconTheme: IconThemeData(
          color: Colors.black87,
        ),
        title: Text(
          AppLocalizations.of(context)!.forgotPassword!,
          style: textTheme.headline5,
        ),
      ),
      body: ForgotPasswordForm(),
    );
  }
}
