import 'package:flutter/material.dart';
import 'package:the_project_hariyal/screens/customer/models/product_model.dart';

import 'file:///E:/000Gautham/Flutter%20Projects%20VS/hariyal/lib/screens/customer/widgets/image_slider.dart';

class ProductDetail extends StatefulWidget {
  final ProductModel productModel;

  ProductDetail(this.productModel);

  @override
  _ProductDetailState createState() => _ProductDetailState(productModel);
}

class _ProductDetailState extends State<ProductDetail> {
  final ProductModel productModel;

  _ProductDetailState(this.productModel);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
              height: MediaQuery.of(context).size.height / 1.5,
              width: MediaQuery.of(context).size.width,
              child: ImageSliderWidget(
                imageUrls: productModel.images,
                imageBorderRadius: BorderRadius.circular(8.0),
              )),
          SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    children: [
                      MaterialButton(
                        padding: const EdgeInsets.all(8.0),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10.0)),
                        child: Icon(Icons.arrow_back_ios),
                        color: Colors.white,
                        textColor: Colors.black,
                        minWidth: 0,
                        height: 40,
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                ),
                Spacer(),
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(32.0),
                        color: Colors.white),
                    child: Column(
                      children: [
                        const SizedBox(height: 30.0),
                        Expanded(
                          child: SingleChildScrollView(
                            physics: BouncingScrollPhysics(),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                ListTile(
                                  title: Text(
                                    productModel.title,
                                    style: TextStyle(
                                        color: Colors.black,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 28.0),
                                  ),
                                  trailing: IconButton(
                                    icon: Icon(Icons.favorite_border),
                                    onPressed: () {},
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 16.0, vertical: 12.0),
                                  child: Text(
                                    productModel.description,
                                    style: TextStyle(
                                        color: Colors.black, fontSize: 18),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              vertical: 12, horizontal: 24),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(20.0),
                                topRight: Radius.circular(20.0)),
                            color: Colors.grey.shade900,
                          ),
                          child: Row(
                            children: [
                              Text(
                                'Price' + " Rs",
                                style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18.0),
                              ),
                              const SizedBox(width: 20.0),
                              Spacer(),
                              RaisedButton(
                                padding: const EdgeInsets.symmetric(
                                    vertical: 8.0, horizontal: 16.0),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10.0)),
                                onPressed: () async {},
                                color: Colors.orange,
                                textColor: Colors.white,
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: <Widget>[
                                    Text(
                                      "Book Now",
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16.0),
                                    ),
                                    const SizedBox(width: 20.0),
                                    Container(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Icon(
                                        Icons.arrow_forward_ios,
                                        color: Colors.orange,
                                        size: 16.0,
                                      ),
                                      decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius:
                                              BorderRadius.circular(10.0)),
                                    )
                                  ],
                                ),
                              )
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}
