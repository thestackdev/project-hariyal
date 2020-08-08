import 'package:flutter/material.dart';
import 'package:flutter_swiper/flutter_swiper.dart';
import 'package:the_project_hariyal/utils.dart';

import 'widgets/slider.dart';

class FullScreen extends StatelessWidget {
  final images, index;

  FullScreen({this.images, this.index});

  @override
  Widget build(BuildContext context) {
    try {
      return Scaffold(
        backgroundColor: Colors.white10,
        body: SafeArea(
          child: Hero(
            tag: 04,
            child: SliderImage(
              dotAlignment: Alignment.bottomCenter,
              imageUrls: images,
              sliderBg: Colors.transparent,
              tap: false,
              type: SwiperLayout.DEFAULT,
              index: index,
            ),
          ),
        ),
      );
    } catch (e) {
      return Utils().errorWidget(e.toString());
    }
  }
}
