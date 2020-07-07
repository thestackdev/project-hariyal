import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:the_project_hariyal/screens/customer/models/product_model.dart';
import 'package:the_project_hariyal/screens/customer/models/user_model.dart';

class Home extends StatefulWidget {
  final UserModel userModel;

  Home(this.userModel);

  @override
  _HomeState createState() => _HomeState(userModel);
}

class _HomeState extends State<Home> {
  final UserModel userModel;

  _HomeState(this.userModel);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Home'),
        actions: [
          IconButton(
            onPressed: () {},
            icon: Icon(Icons.filter_list),
          )
        ],
      ),
      drawer: Drawer(
        child: ListView(
          children: [
            SizedBox(
              height: 20,
            ),
            Padding(
              padding: EdgeInsets.only(left: 20),
              child: Align(
                alignment: Alignment.topLeft,
                child: IconButton(
                  icon: Icon(Icons.close),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ),
            ),
            SizedBox(
              height: 20,
            ),
            Padding(
              padding: EdgeInsets.only(left: 50),
              child: ListTile(
                title: Text(
                  userModel.name,
                  textScaleFactor: 2,
                ),
              ),
            ),
            SizedBox(
              height: 30,
            ),
            Padding(
              padding: EdgeInsets.only(left: 50, right: 10),
              child: ListTile(
                title: Row(
                  children: [
                    Text(
                      'Edit Profile',
                      style: TextStyle(fontSize: 18),
                    ),
                    Spacer(),
                    Icon(
                      Icons.arrow_forward_ios,
                      size: 18,
                    )
                  ],
                ),
              ),
            ),
            SizedBox(
              height: 10,
            ),
            Padding(
              padding: EdgeInsets.only(left: 50, right: 10),
              child: ListTile(
                title: Row(
                  children: [
                    Text(
                      'Booked Items',
                      style: TextStyle(fontSize: 18),
                    ),
                    Spacer(),
                    Icon(
                      Icons.arrow_forward_ios,
                      size: 18,
                    )
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      body: SafeArea(
        child: StreamBuilder<QuerySnapshot>(
          stream: Firestore.instance.collection('products').snapshots(),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              return ListView.builder(
                  itemCount: snapshot.data.documents.length,
                  itemBuilder: (BuildContext context, int index) {
                    ProductModel productModel = ProductModel.fromMap(
                        snapshot.data.documents[index].data,
                        snapshot.data.documents[index].documentID);
                    return Text(productModel.id);
                  });
            } else {
              return Center(
                child: SpinKitWave(
                    color: Colors.orangeAccent, type: SpinKitWaveType.start),
              );
            }
          },
        ),
      ),
    );
  }
}
