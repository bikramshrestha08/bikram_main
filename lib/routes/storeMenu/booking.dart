import 'package:flutter/material.dart';
import 'package:linkeat/l10n/localizations.dart';
import 'package:linkeat/routes/signIn/bookingForm.dart';

class Booking extends StatelessWidget { // Class name capitalized to follow Dart conventions
  final String? uuid;
  static const routeName = '/booking';

  Booking({
    Key? key,
    this.uuid,
  }) : super(key: key); // 'required' removed since uuid is nullable

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    // Handling uuid being null
    if (uuid == null) {
      // Here you can decide what to do if uuid is null.
      // For example, return an error widget or redirect.
      return Scaffold(
        body: Center(child: Text('UUID is required for booking.')),
      );
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        iconTheme: IconThemeData(
          color: Colors.black87,
        ),
        title: Text(
          AppLocalizations.of(context)!.booking!,
          style: textTheme.headline5,
        ),
      ),
      body: BookingForm(uuid: uuid!), // uuid is now asserted to be non-null
    );
  }
}

