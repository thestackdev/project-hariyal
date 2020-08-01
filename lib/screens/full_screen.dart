import 'package:flutter/material.dart';
import 'package:flutter_swiper/flutter_swiper.dart';

import 'widgets/slider.dart';

class FullScreen extends StatelessWidget {
  final images, index;

  FullScreen({this.images, this.index});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Hero(
          tag: 04,
          child: SliderImage(
            dotAlignment: Alignment.bottomCenter,
            imageUrls: images,
            sliderBg: Colors.transparent,
            tap: false,
            imageHeight: double.infinity,
            type: SwiperLayout.DEFAULT,
            index: index,
          ),
        ),
      ),
    );
  }
}
