

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import 'package:carousel_slider/carousel_slider.dart';

class StoreSlider extends StatefulWidget {
  StoreSlider({Key? key, required this.bannerUrl}) : super(key: key);

  final List<String?>? bannerUrl;

  @override
  _SliderState createState() => _SliderState();
}

class _SliderState extends State<StoreSlider> {
  int _current = 0;

  CarouselController buttonCarouselController = CarouselController();

  @override
  Widget build(BuildContext context) {
    return Stack(children: [
      CarouselSlider(
        items: widget.bannerUrl!
            .map((item) => Container(
                  child: Center(
                      child: CachedNetworkImage(
                    imageUrl: item!,
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
                    width: 1000,
//                  height: 80,
                    fit: BoxFit.cover,
                  )),
                  color: Colors.white,
                ))
            .toList(),
        carouselController: buttonCarouselController,
        options: CarouselOptions(
            height: 190,
            autoPlay: widget.bannerUrl!.length > 1 ? true : false,
            autoPlayInterval: Duration(seconds: 5),
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
        child: widget.bannerUrl!.length > 1
            ? Padding(
                padding: EdgeInsets.only(top: 160),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: widget.bannerUrl!.map((url) {
                    int index = widget.bannerUrl!.indexOf(url);
                    return Container(
                      width: 8.0,
                      height: 8.0,
                      margin:
                          EdgeInsets.symmetric(vertical: 10.0, horizontal: 2.0),
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
  }
}
