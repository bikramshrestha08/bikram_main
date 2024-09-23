import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import 'package:carousel_slider/carousel_slider.dart';

import 'package:linkeat/models/cms.dart';
import 'package:linkeat/service/api.dart';

class HomeSlider extends StatefulWidget {
  HomeSlider({Key? key}) : super(key: key);

  @override
  _HomeSliderState createState() => _HomeSliderState();
}

class _HomeSliderState extends State<HomeSlider> {
  Future<List<Album>>? futureAlbums;
  int _current = 0;

  @override
  void initState() {
    super.initState();
    futureAlbums = fetchAlbums(context);
  }

  CarouselController buttonCarouselController = CarouselController();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Album>>(
      future: futureAlbums,
      builder: (context, snapshot) {
        if (snapshot.hasData && snapshot.data!.length > 0) {
          return Stack(children: [
            CarouselSlider(
              items: snapshot.data!
                  .map((item) => Container(
                        child: Center(
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
                          errorWidget: (context, url, error) =>
                              Icon(Icons.error),
                          width: 1000,
//                            height: 80,
                          fit: BoxFit.cover,
                        )),
                        color: Colors.white,
                      ))
                  .toList(),
              carouselController: buttonCarouselController,
              options: CarouselOptions(
                  height: 190,
                  autoPlay: snapshot.data!.length > 1 ? true : false,
                  autoPlayInterval: Duration(seconds: 4),
                  autoPlayAnimationDuration: Duration(milliseconds: 800),
                  autoPlayCurve: Curves.fastOutSlowIn,
                  enableInfiniteScroll: true,
                  aspectRatio: 2,
                  initialPage: 0,
                  viewportFraction: 1.0,
                  enlargeCenterPage: false,
                  scrollDirection: Axis.horizontal,
                  onPageChanged: (index, reason) {
                    setState(() {
                      _current = index;
                    });
                  }),
            ),
            SizedBox(
              child: snapshot.data!.length > 1
                  ? Padding(
                      padding: EdgeInsets.only(top: 160),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: snapshot.data!.map((url) {
                          int index = snapshot.data!.indexOf(url);
                          return Container(
                            width: 8.0,
                            height: 8.0,
                            margin: EdgeInsets.symmetric(
                                vertical: 10.0, horizontal: 2.0),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: _current == index
                                  ? Color.fromRGBO(255, 255, 255, 0.9)
                                  : Color.fromRGBO(255, 255, 255, 0.4),
                            ),
                          );
                        }).toList(),
                      ),
                    )
                  : SizedBox.shrink(),
            ),
          ]);
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
