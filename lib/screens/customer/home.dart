import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:the_project_hariyal/screens/customer/models/product_model.dart';
import 'package:the_project_hariyal/screens/customer/models/user_model.dart';
import 'package:the_project_hariyal/screens/customer/network_image.dart';
import 'package:the_project_hariyal/screens/customer/product_details.dart';

class Home extends StatefulWidget {
  final UserModel userModel;
  final uid;

  Home(this.uid, this.userModel);

  @override
  _HomeState createState() => _HomeState(userModel);
}

class _HomeState extends State<Home> {
  final UserModel userModel;

  _HomeState(this.userModel);

  String stateCategory, stateValue;
  String areaCategory, areaValue;

  List<DocumentSnapshot> products = [];

  @override
  void initState() {
    setState(() {
      stateCategory = 'location.state';
      stateValue = userModel.location['state'];
      areaCategory = 'location.area';
      areaValue = userModel.location['cityDistrict'];
    });
    super.initState();
  }

  void showFilterDialog() {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Filter'),
            content: Wrap(
              children: [
                Column(
                  children: [
                    Row(
                      children: [
                        Text(
                          'Area',
                          textScaleFactor: 1.4,
                        ),
                        new DropdownButton<String>(
                          items: <String>['hyderabad', 'secunderabad']
                              .map((String value) {
                            return new DropdownMenuItem<String>(
                              value: value,
                              child: new Text(value),
                            );
                          }).toList(),
                          onChanged: (newValue) {
                            setState(() {
                              areaCategory = 'location.area';
                              areaValue = newValue;
                            });
                          },
                        )
                      ],
                    ),
                    Row(
                      children: [
                        Text(
                          'State',
                          textScaleFactor: 1.4,
                        ),
                        new DropdownButton<String>(
                          items: <String>['andhra pradesh', 'telangana']
                              .map((String value) {
                            return new DropdownMenuItem<String>(
                              value: value,
                              child: new Text(value),
                            );
                          }).toList(),
                          onChanged: (newValue) {
                            setState(() {
                              stateCategory = 'location.state';
                              stateValue = newValue;
                            });
                          },
                        )
                      ],
                    )
                  ],
                )
              ],
            ),
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Home'),
        actions: [
          IconButton(
            onPressed: () {
              showFilterDialog();
            },
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
        child: StreamBuilder(
          stream: Firestore.instance.collection('products').snapshots(),
          builder: (context, snapshot) {
            if (snapshot.data == null ||
                snapshot.connectionState == ConnectionState.none ||
                snapshot.connectionState == ConnectionState.waiting) {
              return Center(
                child: SpinKitWave(
                  color: Colors.orange,
                  size: 50.0,
                ),
              );
            }
            if (snapshot.hasError) {
              return Center(
                child: Text(
                  snapshot.error,
                  textScaleFactor: 2,
                ),
              );
            }
            if (!snapshot.hasData || snapshot.data.documents.length <= 0) {
              return Center(
                child: Text(
                  'No Products Available',
                  textScaleFactor: 2,
                ),
              );
            }
            return ListView.builder(
                itemCount: snapshot.data.documents.length,
                itemBuilder: (context, index) {
                  ProductModel productModel = ProductModel.fromMap(
                      snapshot.data.documents[index].data,
                      snapshot.data.documents[index].documentID);
                  return buildItems(context, productModel);
                });
          },
        ),
      ),
    );
  }

  Widget buildItems(BuildContext context, ProductModel productModel) {
    return GestureDetector(
      onTap: () {
        Navigator.push(context, MaterialPageRoute(builder: (_) {
          return ProductDetail(productModel);
        }));
      },
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 18, vertical: 12),
        child: Card(
          elevation: 6,
          child: Padding(
            padding: EdgeInsets.all(12),
            child: Row(
              children: [
                Container(
                  height: 120,
                  width: MediaQuery.of(context).size.width / 3,
                  child: ClipRRect(
                    borderRadius: BorderRadius.all(Radius.circular(6)),
                    child: Hero(
                      tag: productModel.id,
                      child: PNetworkImage(
                        productModel.images[0],
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ListTile(
                        title: Text(
                          productModel.title,
                          style: TextStyle(fontSize: 21),
                        ),
                        subtitle: Text(
                          productModel.description,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Padding(
                        padding: EdgeInsets.only(left: 20),
                        child: Text(
                          'Price',
                          style: TextStyle(fontSize: 18),
                        ),
                      )
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () {},
                  icon: Icon(Icons.favorite_border),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
