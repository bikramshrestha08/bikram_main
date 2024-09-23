import 'package:flutter/material.dart';
import 'package:linkeat/routes/home/slider.dart';
import 'package:linkeat/routes/home/popular.dart';

class Home extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: PreferredSize(
          preferredSize: Size.fromHeight(0.0), // here the desired height
          child: AppBar()),
      body: Scrollbar(
        child: ListView(
          children: <Widget>[
            Container(
              child: HomeSlider(),
            ),
            PopularStores()
          ],
        ),
      ),
    );
  }
}
