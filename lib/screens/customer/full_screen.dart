import 'package:flutter/material.dart';
import 'package:the_project_hariyal/screens/customer/widgets/image_slider.dart';

class FullScreenView extends StatefulWidget {
  final images;
  final tag;

  FullScreenView(this.images, this.tag);

  @override
  _FullScreenViewState createState() => _FullScreenViewState();
}

class _FullScreenViewState extends State<FullScreenView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ImageSliderWidget(
        imageHeight: MediaQuery.of(context).size.height,
        imageUrls: widget.images,
        tag: widget.tag,
        isZoomable: true,
      ),
    );
  }
}
