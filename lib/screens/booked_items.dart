import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:the_project_hariyal/screens/order_details.dart';
import 'package:the_project_hariyal/utils.dart';

class BookedItems extends StatelessWidget {
  final uid;

  BookedItems(this.uid);

  final Utils utils = new Utils();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Booked Items'),
      ),
      body: SafeArea(
        child: StreamBuilder(
          stream: Firestore.instance
              .collection('orders')
              .where('uid', isEqualTo: uid)
              .snapshots(),
          builder: (streamContext, snap) {
            return snap == null
                ? utils.loadingIndicator()
                : snap.hasData
                    ? snap.data.documents.length <= 1
                        ? buildUI(streamContext, snap)
                        : noItems()
                    : utils.loadingIndicator();
          },
        ),
      ),
    );
  }

  Widget buildUI(
      BuildContext streamContext, AsyncSnapshot<QuerySnapshot> oSnap) {
    return ListView.builder(
      shrinkWrap: true,
      itemCount: oSnap.data.documents.length,
      itemBuilder: (context, index) {
        return Container(
          height: 120,
          padding: EdgeInsets.symmetric(vertical: 6, horizontal: 12),
          child: StreamBuilder<DocumentSnapshot>(
            stream: Firestore.instance
                .collection('products')
                .document(oSnap.data.documents[index].data['pid'])
                .snapshots(),
            builder: (streamContext2, pSnap) {
              var date = new DateTime.fromMillisecondsSinceEpoch(
                  oSnap.data.documents[index]['timeStamp']);
              return pSnap.data.exists
                  ? GestureDetector(
                      onTap: () {
                        Navigator.of(context)
                            .push(MaterialPageRoute(builder: (_) {
                          return OrderDetails(
                              oSnap.data.documents[index].documentID);
                        }));
                      },
                      child: Card(
                        elevation: 6,
                        child: Padding(
                          padding: EdgeInsets.all(12),
                          child: Row(
                            mainAxisSize: MainAxisSize.max,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Container(
                                height: 120,
                                width: 120,
                                child: oSnap.data.documents[index]
                                            .data['oStatus'] ==
                                        0
                                    ? Image.asset('assets/booked.png')
                                    : oSnap.data.documents[index]
                                                .data['oStatus'] ==
                                            1
                                        ? Image.asset('assets/delivered.png')
                                        : oSnap.data.documents[index]
                                                    .data['oStatus'] ==
                                                2
                                            ? Image.asset(
                                                'assets/cancelled.png')
                                            : Image.asset('assets/booked.png'),
                              ),
                              Flexible(
                                child: ListTile(
                                  title: Text(pSnap.data['title'] == null
                                      ? ''
                                      : utils.camelCase(pSnap.data['title'])),
                                  subtitle: Text(
                                      'Booked date ${date.day}/${date.month}/${date.year}'),
                                  trailing: Icon(Icons.arrow_forward_ios),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    )
                  : utils.nullWidget('Something went wrong');
            },
          ),
        );
      },
    );
  }

  Widget noItems() {
    return Center(
      child: Text(
        'No Items Booked Yet',
        textScaleFactor: 3,
        textAlign: TextAlign.center,
      ),
    );
  }
}
