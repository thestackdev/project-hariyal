import 'package:flutter/material.dart';
import 'package:flutter_swiper/flutter_swiper.dart';
import 'package:the_project_hariyal/screens/full_screen.dart';

import 'network_image.dart';

class SliderImage extends StatelessWidget {
  final List<dynamic> imageUrls;
  final dotAlignment, tap, type, index, sliderBg;
  final double imageHeight;

  const SliderImage(
      {this.imageUrls,
      this.imageHeight,
      this.tap,
      this.dotAlignment,
      this.type,
      this.index,
      this.sliderBg});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: imageHeight,
      color: sliderBg,
      padding: EdgeInsets.all(16.0),
      child: Swiper(
        itemBuilder: (BuildContext context, int index) {
          return ClipRRect(
            borderRadius: BorderRadius.circular(10.0),
            child: PNetworkImage(
              imageUrls[index],
              fit: BoxFit.cover,
            ),
          );
        },
        index: index == null ? 0 : index,
        itemWidth: 300,
        itemHeight: imageHeight,
        itemCount: imageUrls.length,
        layout: type,
        loop: false,
        onTap: (value) {
          if (tap) {
            Navigator.of(context).push(PageRouteBuilder(
                opaque: false,
                pageBuilder: (BuildContext context, _, __) => FullScreen(
                      images: imageUrls,
                      index: value,
                    )));
          }
        },
        pagination: new SwiperPagination(
          builder: new SwiperCustomPagination(
              builder: (BuildContext context, SwiperPluginConfig config) {
            return new ConstrainedBox(
              child: Align(
                alignment: dotAlignment,
                child: new DotSwiperPaginationBuilder(
                        color: Colors.grey,
                        activeColor: Theme.of(context).accentColor,
                        size: 10.0,
                        activeSize: 20.0)
                    .build(context, config),
              ),
              constraints: new BoxConstraints.expand(height: 50.0),
            );
          }),
          alignment: dotAlignment,
        ),
      ),
    );
  }
}
