import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class InterestedItems extends StatefulWidget {
  final dynamic uid;

  InterestedItems(this.uid);

  @override
  _InterestedItemsState createState() => _InterestedItemsState();
}

class _InterestedItemsState extends State<InterestedItems> {
  var fireStore;
  int count = 30;

  @override
  void initState() {
    fireStore = Firestore.instance;
    super.initState();
  }

  ScrollController _scrollController;

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
        child: StreamBuilder<DocumentSnapshot>(
            stream: fireStore
                .collection('interested')
                .document(widget.uid)
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                return StreamBuilder(
                  stream: fireStore
                      .collection('interested')
                      .limit(count)
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      return ListView.builder(
                          controller: _scrollController,
                          itemCount: snapshot.data.documents.length,
                          itemBuilder: (context, index) {
                            Map<dynamic, dynamic> map =
                                snapshot.data.documents.data[index];
                            return buildItems(context, map);
                          });
                    } else {
                      return Center(
                        child: SpinKitWave(
                          color: Colors.orange,
                          size: 50.0,
                        ),
                      );
                    }
                  },
                );
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

  Widget buildItems(BuildContext context, Map<dynamic, dynamic> map) {
    return Card(
      margin: EdgeInsets.all(12),
      child: ListTile(
        title: Text(map['title']),
        subtitle: Text(map['price']),
      ),
    );
  }
}
