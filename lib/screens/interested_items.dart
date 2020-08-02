import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_data_stream_builder/flutter_data_stream_builder.dart';
import 'package:provider/provider.dart';
import 'package:the_project_hariyal/utils.dart';

import 'product_info.dart';
import 'widgets/network_image.dart';

class InterestedItems extends StatefulWidget {
  @override
  _InterestedItemsState createState() => _InterestedItemsState();
}

class _InterestedItemsState extends State<InterestedItems> {
  Firestore fireStore = Firestore.instance;
  Utils utils = Utils();
  QuerySnapshot interests;

  @override
  Widget build(BuildContext context) {
    interests = context.watch<QuerySnapshot>();

    if (interests == null) {
      return Container(
        child: utils.loadingIndicator(),
      );
    } else if (interests.documents.length == 0) {
      Container(
        child: Center(
          child: Text('You don\'t have interests in any of our product :/',
              style: TextStyle(fontSize: 24), textAlign: TextAlign.center),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Interested Items'),
      ),
      body: ListView.builder(
          itemCount: interests.documents.length,
          itemBuilder: (context, index) {
            return DataStreamBuilder<DocumentSnapshot>(
              loadingBuilder: (context) => utils.loadingIndicator(),
              stream: fireStore
                  .collection('products')
                  .document(interests.documents[index]['productId'])
                  .snapshots(),
              builder: (context, productsnap) {
                return buildItems(productsnap, index);
              },
            );
          }),
    );
  }

  Widget buildItems(DocumentSnapshot snapshot, int index) {
    return Stack(
      children: <Widget>[
        GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ProductInfo(docId: snapshot.documentID),
              ),
            );
          },
          child: Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            elevation: 9,
            margin: EdgeInsets.only(top: 12, right: 24, left: 12, bottom: 12),
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
                      snapshot.data['images'][0],
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
                            snapshot.data['title'],
                            textScaleFactor: 1.4,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Spacer(),
                          Text(
                            '₹ ${snapshot.data['price']}',
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
              interests.documents.forEach((element) {
                if (element.data['productId'] == snapshot.documentID) {
                  element.reference.delete();
                }
              });
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
