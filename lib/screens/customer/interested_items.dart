import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:the_project_hariyal/screens/customer/product_details.dart';
import 'package:the_project_hariyal/screens/customer/widgets/network_image.dart';

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
        child: widget.interestedsnap.data == null
            ? Center(
                child: Text(
                'You don\'t have interests in any of our product :/',
                style: TextStyle(fontSize: 24),
                textAlign: TextAlign.center,
              ))
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
                        )));
          },
          child: Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12.0),
            ),
            elevation: 12,
            margin: EdgeInsets.only(left: 15, top: 15, right: 32, bottom: 15),
            child: Container(
              height: 120,
              width: MediaQuery.of(context).size.width,
              child: Row(
                children: <Widget>[
                  ClipRRect(
                      borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(12.0),
                          bottomLeft: Radius.circular(12.0)),
                      child: PNetworkImage(
                        snapshot.data.documents[index]['images'][0],
                        height: 120,
                        width: 160,
                        fit: BoxFit.fitHeight,
                      )),
                  SizedBox(
                    width: 20,
                  ),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Spacer(),
                      Container(
                        margin: EdgeInsets.only(left: 12),
                        child: Text(
                          snapshot.data.documents[index]['title'],
                          textScaleFactor: 1.5,
                          style: TextStyle(
                              color: Colors.black, fontWeight: FontWeight.bold),
                        ),
                      ),
                      Spacer(),
                      Container(
                        margin: EdgeInsets.only(left: 12),
                        child: Text(
                          '${snapshot.data.documents[index]['price']} Rs',
                          textScaleFactor: 1.2,
                          style: TextStyle(
                              fontStyle: FontStyle.italic,
                              color: Colors.black54,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                      Spacer(),
                    ],
                  ),
                  SizedBox(
                    width: 10,
                  ),
                ],
              ),
            ),
          ),
        ),
        Positioned(
          top: 32,
          right: 20,
          child: GestureDetector(
            child: Container(
              decoration: BoxDecoration(
                  color: Colors.red, borderRadius: BorderRadius.circular(6)),
              child: Icon(
                Icons.close,
                color: Colors.white,
              ),
            ),
            onTap: () async {
              await fireStore
                  .collection('interested')
                  .document(snapshot.data.documents[index].documentID)
                  .delete();
            },
          ),
        )
      ],
    );
  }
}
