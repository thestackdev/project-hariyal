import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

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
        child: StreamBuilder<QuerySnapshot>(
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
                      return Card(
                        margin: EdgeInsets.all(12),
                        child: ListTile(
                          title: Text(snapshot.data.documents[index]['title']),
                          subtitle:
                              Text(snapshot.data.documents[index]['price']),
                        ),
                      );
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
}
