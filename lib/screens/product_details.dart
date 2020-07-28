import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_data_stream_builder/flutter_data_stream_builder.dart';
import 'package:flutter_swiper/flutter_swiper.dart';
import 'package:provider/provider.dart';
import 'package:the_project_hariyal/screens/widgets/slider.dart';
import 'package:the_project_hariyal/utils.dart';

class ProductDetail extends StatefulWidget {
  final String docId;

  const ProductDetail({Key key, this.docId}) : super(key: key);

  @override
  _ProductDetailState createState() => _ProductDetailState();
}

class _ProductDetailState extends State<ProductDetail> {
  QuerySnapshot interests;
  DocumentSnapshot usersnap;
  Firestore firestore = Firestore.instance;
  Utils utils = Utils();
  Set interestSet = {};

  @override
  Widget build(BuildContext context) {
    interests = context.watch<QuerySnapshot>();
    usersnap = context.watch<DocumentSnapshot>();

    if (interests == null) {
      return Container(
        child: utils.loadingIndicator(),
      );
    }
    interestSet.clear();
    interests.documents.forEach((element) {
      interestSet.add(element.data['productId']);
    });
    return Scaffold(
      body: DataStreamBuilder<DocumentSnapshot>(
          stream: firestore
              .collection('products')
              .document(widget.docId)
              .snapshots(),
          builder: (context, snapshot) {
            return Stack(
              children: [
                Container(
                    height: MediaQuery.of(context).size.height / 1.5,
                    width: MediaQuery.of(context).size.width,
                    child: SliderImage(
                      imageUrls: snapshot['images'],
                      sliderBg: Colors.grey.shade800,
                      tap: true,
                      imageHeight: 300,
                      dotAlignment: Alignment.topCenter,
                      type: SwiperLayout.STACK,
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
                                          Utils().camelCase(snapshot['title']),
                                          style: TextStyle(
                                              color: Colors.black,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 28.0),
                                        ),
                                        trailing: IconButton(
                                          icon: interestSet
                                                  .contains(snapshot.documentID)
                                              ? Icon(
                                                  Icons.favorite,
                                                  color: Colors.red[800],
                                                )
                                              : Icon(Icons.favorite_border),
                                          onPressed: () {
                                            handleInterests(snapshot);
                                          },
                                        )),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 16.0, vertical: 12.0),
                                      child: Text(
                                        snapshot['description'],
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
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Price ${snapshot['price']}',
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
          }),
    );
  }

  handleInterests(DocumentSnapshot snapshot) {
    if (interestSet.contains(snapshot.documentID)) {
      for (var element in interests.documents) {
        if (element.data['productId'] == snapshot.documentID) {
          element.reference.delete();
          snapshot.reference.updateData(
              {'interested_count': --snapshot.data['interested_count']});
          break;
        }
      }
    } else {
      firestore.collection('interests').document().setData({
        'timestamp': DateTime.now().millisecondsSinceEpoch,
        'productId': snapshot.documentID,
        'author': usersnap.documentID,
      });
      snapshot.reference.updateData(
          {'interested_count': ++snapshot.data['interested_count']});
    }
  }
}
