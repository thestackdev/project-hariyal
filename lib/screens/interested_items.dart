import 'dart:collection';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:the_project_hariyal/utils.dart';

import 'product_details.dart';
import 'widgets/network_image.dart';

class InterestedItems extends StatefulWidget {
  final DocumentSnapshot interestedsnap;
  final uid;

  const InterestedItems({Key key, this.interestedsnap, this.uid})
      : super(key: key);

  @override
  _InterestedItemsState createState() => _InterestedItemsState();
}

class _InterestedItemsState extends State<InterestedItems> {
  Firestore fireStore;
  int count = 30;
  ScrollController _scrollController;

  List productIds = new List();

  @override
  void initState() {
    productIds = widget.interestedsnap.data['interested'].values.toList();
    fireStore = Firestore.instance;
    _scrollController = ScrollController();
    _scrollController.addListener(_scrollListener);
    super.initState();
  }

  _scrollListener() {
    if (_scrollController.offset >=
            _scrollController.position.maxScrollExtent &&
        !_scrollController.position.outOfRange) {
      setState(() {
        count += 30;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Interested Items'),
      ),
      body: SafeArea(
        child: productIds.length == 0
            ? Center(
                child: Text(
                  'You don\'t have interests in any of our product :/',
                  style: TextStyle(fontSize: 24),
                  textAlign: TextAlign.center,
                ),
              )
            : ListView.builder(
                controller: _scrollController,
                itemCount: productIds.length,
                itemBuilder: (context, index) {
                  return StreamBuilder(
                    stream: fireStore
                        .collection('products')
                        .document(productIds[index])
                        .snapshots(),
                    builder: (context, productSnap) {
                      return productSnap.hasData
                          ? buildItems(productSnap, index)
                          : Center(
                              child: SpinKitWave(
                                color: Colors.orange,
                                size: 50.0,
                              ),
                            );
                    },
                  );
                }),
      ),
    );
  }

  Widget buildItems(AsyncSnapshot<DocumentSnapshot> snapshot, int index) {
    return Stack(
      children: <Widget>[
        Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 9,
          margin: EdgeInsets.only(top: 12, right: 24, left: 12, bottom: 12),
          child: GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ProductDetail(
                    productSnap: snapshot.data,
                    uid: widget.uid,
                  ),
                ),
              );
            },
            child: Container(
              height: 120,
              width: MediaQuery.of(context).size.width,
              child: Row(
                children: <Widget>[
                  ClipRRect(
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(12.0),
                      bottomLeft: Radius.circular(12.0),
                    ),
                    child: PNetworkImage(
                      snapshot.data.data['images'][0],
                      height: 120,
                      width: 160,
                      fit: BoxFit.fitHeight,
                    ),
                  ),
                  Flexible(
                    child: Padding(
                      padding: const EdgeInsets.only(left: 9),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Spacer(),
                          Text(
                            snapshot.data.data['title'],
                            textScaleFactor: 1.4,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Spacer(),
                          Text(
                            '₹ ${snapshot.data.data['price']}',
                            textScaleFactor: 1.2,
                            style: TextStyle(
                                fontStyle: FontStyle.italic,
                                color: Colors.black54,
                                fontWeight: FontWeight.bold),
                          ),
                          Spacer(),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        Positioned(
          top: 32,
          right: 12,
          child: GestureDetector(
            onTap: () {
              int count = snapshot.data.data['interested_count'];
              Map map = new HashMap();
              map = widget.interestedsnap.data['interested'];
              count = count - 1;
              var key = map.keys.firstWhere(
                      (element) => map[element] == snapshot.data.documentID,
                  orElse: () => null);
              if (key != null) {
                setState(() {
                  productIds.remove(snapshot.data.documentID);
                });
                map.remove(key);
                widget.interestedsnap.reference.updateData({'interested': map});
                snapshot.data.reference.updateData({'interested_count': count});
              } else {
                Utils().toast(context, 'Something went wrong',
                    bgColor: Utils().randomGenerator());
              }
            },
            child: Container(
              decoration: BoxDecoration(
                  color: Colors.red, borderRadius: BorderRadius.circular(6)),
              child: Icon(
                Icons.close,
                color: Colors.white,
              ),
            ),
          ),
        )
      ],
    );
  }
}
