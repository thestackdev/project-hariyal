import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class Admins extends StatefulWidget {
  @override
  _AdminsState createState() => _AdminsState();
}

class _AdminsState extends State<Admins> {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: Firestore.instance.collection('admin').snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return ListView.builder(
            itemCount: snapshot.data.documents.length,
            itemBuilder: (BuildContext context, int index) {
              if (snapshot.data.documents[index].documentID == 'super_admin') {
                return Container();
              } else {
                return Container(
                  margin: EdgeInsets.all(9),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(9),
                    color: Colors.grey.shade300,
                  ),
                  child: ListTile(
                    title: Text(snapshot.data.documents[index]['name']),
                    subtitle: Text((snapshot.data.documents[index].documentID)),
                  ),
                );
              }
            },
          );
        } else {
          return Center(
            child: CircularProgressIndicator(),
          );
        }
      },
    );
  }
}
