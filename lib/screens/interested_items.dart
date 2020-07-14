import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'product_details.dart';
import 'widgets/network_image.dart';

class InterestedItems extends StatefulWidget {
  final DocumentSnapshot interestedsnap;

  const InterestedItems({Key key, this.interestedsnap}) : super(key: key);

  @override
  _InterestedItemsState createState() => _InterestedItemsState();
}

class _InterestedItemsState extends State<InterestedItems> {
  Firestore fireStore;
  int count = 30;
  ScrollController _scrollController;

  @override
  void initState() {
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
      body: SafeArea(
        child: widget.interestedsnap.data['interested'].length == 0
            ? Center(
                child: Text(
                  'You don\'t have interests in any of our product :/',
                  style: TextStyle(fontSize: 24),
                  textAlign: TextAlign.center,
                ),
              )
            : StreamBuilder<QuerySnapshot>(
                stream: fireStore
                    .collection('products')
                    .where(
                      FieldPath.documentId,
                      whereIn: widget.interestedsnap.data['interested'],
                    )
                    .limit(count)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    return ListView.builder(
                        controller: _scrollController,
                        itemCount: snapshot.data.documents.length,
                        itemBuilder: (context, index) {
                          return buildItems(snapshot, index);
                        });
                  } else {
                    return Center(
                      child: SpinKitWave(
                        color: Colors.orange,
                        size: 50.0,
                      ),
                    );
                  }
                }),
      ),
    );
  }

  Widget buildItems(AsyncSnapshot<QuerySnapshot> snapshot, int index) {
    return Stack(
      children: <Widget>[
        GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ProductDetail(
                  productSnap: snapshot.data.documents[index],
                ),
              ),
            );
          },
          child: Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            elevation: 9,
            margin: EdgeInsets.all(9),
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
                      snapshot.data.documents[index]['images'][0],
                      height: 120,
                      width: 160,
                      fit: BoxFit.fitHeight,
                    ),
                  ),
                  Flexible(
                    child: Padding(
                      padding: const EdgeInsets.only(left: 9),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            snapshot.data.documents[index]['title'],
                            textScaleFactor: 1.4,
                            style: TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            '₹ ${snapshot.data.documents[index]['price']}',
                            textScaleFactor: 1.2,
                            style: TextStyle(
                                fontStyle: FontStyle.italic,
                                color: Colors.black54,
                                fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
