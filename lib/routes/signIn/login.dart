import 'package:flutter/material.dart';

class Login extends StatelessWidget {
  bool resetToHome;
  static const routeName = '/login';

  Login({
    Key? key,
    this.resetToHome = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        iconTheme: IconThemeData(
          color: Colors.black87,
        ),
        title: Text(
          'Account',
          style: textTheme.headline5,
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Scan the QR Code',
              style: textTheme.headline6,
            ),
            SizedBox(height: 16.0),
            Center(
              child: Column(
                children: [
                  Text(
                    'Please scan the QR code to get your storeId for login.',
                    textAlign: TextAlign.center,
                    style: textTheme.subtitle1,
                  ),
                  SizedBox(height: 16.0),
                  Icon(
                    Icons.qr_code_scanner,
                    size: 200,
                    color: Colors.black87,
                  ),
                  SizedBox(height: 16.0),
                  Text(
                    'Scan the QR code to get the storeId.',
                    textAlign: TextAlign.center,
                    style: textTheme.subtitle1,
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
