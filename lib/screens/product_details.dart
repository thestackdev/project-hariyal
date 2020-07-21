import 'dart:collection';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../utils.dart';
import 'full_screen.dart';
import 'widgets/image_slider.dart';

class ProductDetail extends StatefulWidget {
  final DocumentSnapshot productSnap;
  final uid;

  const ProductDetail({Key key, this.productSnap, this.uid}) : super(key: key);

  @override
  _ProductDetailState createState() => _ProductDetailState();
}

class _ProductDetailState extends State<ProductDetail> {
  Utils utils;

  @override
  void initState() {
    utils = new Utils();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<DocumentSnapshot>(
          stream: Firestore.instance
              .collection('interested')
              .document(widget.uid)
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              return Stack(
                children: [
                  Container(
                      height: MediaQuery.of(context).size.height / 1.5,
                      width: MediaQuery.of(context).size.width,
                      child: ImageSliderWidget(
                        onTap: () {
                          Navigator.push(
                            context,
                            PageRouteBuilder(
                              transitionDuration: Duration(milliseconds: 500),
                              pageBuilder: (_, __, ___) => FullScreenView(
                                widget.productSnap['images'],
                                widget.productSnap.documentID,
                              ),
                            ),
                          );
                        },
                        isZoomable: false,
                        fit: BoxFit.contain,
                        imageHeight: MediaQuery.of(context).size.height / 1.5,
                        imageUrls: widget.productSnap['images'],
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
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      ListTile(
                                          title: Text(
                                            utils.camelCase(
                                                widget.productSnap['title']),
                                            style: TextStyle(
                                                color: Colors.black,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 28.0),
                                          ),
                                          trailing: IconButton(
                                            icon: snapshot.data.data != null
                                                ? snapshot.data['interested']
                                                    .containsValue(
                                                  widget
                                                      .productSnap.documentID,
                                                )
                                                    ? Icon(
                                                  Icons.favorite,
                                                  color: Colors.red[800],
                                                )
                                                    : Icon(
                                                    Icons.favorite_border)
                                                : Icon(Icons.favorite_border),
                                            onPressed: () {
                                              if (snapshot.data.data != null ||
                                                  snapshot.data['interested']
                                                      .length >
                                                      0 ||
                                                  snapshot.data['interested'] !=
                                                      null) {
                                                Map map = new HashMap();
                                                map =
                                                snapshot.data['interested'];
                                                if (map.containsValue(widget
                                                    .productSnap.documentID)) {
                                                  var key = map.keys.firstWhere(
                                                          (element) =>
                                                      map[element] ==
                                                          widget.productSnap
                                                              .documentID,
                                                      orElse: () => null);
                                                  map.remove(key);
                                                  snapshot.data.reference
                                                      .updateData(
                                                      {'interested': map});
                                                } else {
                                                  map[Timestamp.now()
                                                      .toDate()
                                                      .toString()] =
                                                      widget.productSnap
                                                          .documentID
                                                          .toString();
                                                  snapshot.data.reference
                                                      .updateData(
                                                      {'interested': map});
                                                }
                                              } else {
                                                snapshot.data.reference
                                                    .setData({
                                                  'interested': {
                                                    Timestamp.now()
                                                        .toDate()
                                                        .toString():
                                                    widget.productSnap
                                                        .documentID
                                                  }
                                                });
                                              }
                                            },
                                              )),
                                          Padding(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 16.0,
                                                vertical: 12.0),
                                            child: Text(
                                              widget.productSnap['description'],
                                              style: TextStyle(
                                                  color: Colors.black,
                                                  fontSize: 18),
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
                                      mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          'Price ${widget
                                              .productSnap['price']}',
                                          style: TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 18.0),
                                        ),
                                        RaisedButton(
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 8.0, horizontal: 16.0),
                                          shape: RoundedRectangleBorder(
                                              borderRadius:
                                              BorderRadius.circular(10.0)),
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
                                                padding: const EdgeInsets.all(
                                                    8.0),
                                                child: Icon(
                                                  Icons.arrow_forward_ios,
                                                  color: Colors.orange,
                                                  size: 16.0,
                                                ),
                                                decoration: BoxDecoration(
                                                    color: Colors.white,
                                                    borderRadius:
                                                    BorderRadius.circular(
                                                        10.0)),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            )),
                      ],
                    ),
                  ),
                ],
              );
            } else {
              return Center(
                child: CircularProgressIndicator(),
              );
            }
          }),
    );
  }
}
