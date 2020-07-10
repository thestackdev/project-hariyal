import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:the_project_hariyal/screens/customer/booked_items.dart';
import 'package:the_project_hariyal/screens/customer/edit_profile.dart';
import 'package:the_project_hariyal/screens/customer/interested_items.dart';
import 'package:the_project_hariyal/screens/customer/product_details.dart';

import 'widgets/network_image.dart';

class Home extends StatefulWidget {
  final uid;

  const Home({Key key, this.uid}) : super(key: key);

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  ScrollController _scrollController;

  List states = [];
  List areas = [];
  List categories = [];
  List interestedList = [];
  List interests = [];

  Firestore firestore;

  int count = 30;

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
  void initState() {
    _scrollController = ScrollController();
    _scrollController.addListener(_scrollListener);
    firestore = Firestore.instance;
    getFilters();
    super.initState();
  }

  getFilters() async {
    firestore.collection('extras').getDocuments().then((value) {
      value.documents.forEach((element) {
        if (element.documentID == 'states') {
          states.addAll(element.data['states_array'].toList());
        } else if (element.documentID == 'category') {
          categories.addAll(element.data['category_array'].toList());
        } else if (element.documentID == 'areas') {
          areas.addAll(element.data['areas_array'].toList());
        }
      });
    });
  }

  showFilterDialog() {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(6),
          topRight: Radius.circular(6),
        ),
      ),
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, state) {
            return Container(
              padding: EdgeInsets.all(12),
              margin: EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Divider(),
                  Text(
                    'Filter by',
                    style: TextStyle(fontSize: 21, fontWeight: FontWeight.bold),
                  ),
                  Divider(
                    thickness: 1,
                    color: Colors.grey,
                  ),
                  DropdownButtonFormField(
                      decoration: getDecoration('State'),
                      isExpanded: true,
                      iconEnabledColor: Colors.grey,
                      style: TextStyle(color: Colors.grey, fontSize: 16),
                      iconSize: 30,
                      elevation: 9,
                      onChanged: (newValue) {
                        firestore
                            .collection('customers')
                            .document(widget.uid)
                            .updateData({
                          'current_search': 'location.state',
                          'search_value': newValue,
                        });

                        Navigator.pop(context);
                      },
                      items: states.map<DropdownMenuItem<String>>((e) {
                        return DropdownMenuItem<String>(
                            value: e,
                            child: Text(
                              e.toString(),
                            ));
                      }).toList()),
                  Divider(
                    thickness: 1,
                    color: Colors.grey,
                  ),
                  DropdownButtonFormField(
                      decoration: getDecoration('Area'),
                      isExpanded: true,
                      iconEnabledColor: Colors.grey,
                      style: TextStyle(color: Colors.grey, fontSize: 16),
                      iconSize: 30,
                      elevation: 9,
                      onChanged: (newValue) {
                        firestore
                            .collection('customers')
                            .document(widget.uid)
                            .updateData({
                          'current_search': 'location.area',
                          'search_value': newValue,
                        });

                        Navigator.pop(context);
                      },
                      items: areas.map<DropdownMenuItem<String>>((e) {
                        return DropdownMenuItem<String>(
                            value: e,
                            child: Text(
                              e.toString(),
                            ));
                      }).toList()),
                  Divider(
                    thickness: 1,
                    color: Colors.grey,
                  ),
                  DropdownButtonFormField(
                      decoration: getDecoration('Category'),
                      isExpanded: true,
                      iconEnabledColor: Colors.grey,
                      style: TextStyle(color: Colors.grey, fontSize: 16),
                      iconSize: 30,
                      elevation: 9,
                      onChanged: (newValue) {
                        firestore
                            .collection('customers')
                            .document(widget.uid)
                            .updateData({
                          'current_search': 'category',
                          'search_value': newValue,
                        });

                        Navigator.pop(context);
                      },
                      items: categories.map<DropdownMenuItem<String>>((e) {
                        return DropdownMenuItem<String>(
                            value: e,
                            child: Text(
                              e.toString(),
                            ));
                      }).toList())
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DocumentSnapshot>(
        stream:
        firestore.collection('customers').document(widget.uid).snapshots(),
        builder: (context, customersnap) {
          if (customersnap.hasData) {
            return StreamBuilder<DocumentSnapshot>(
                stream: firestore
                    .collection('interested')
                    .document(widget.uid)
                    .snapshots(),
                builder: (context, interestedsnap) {
                  if (interestedsnap.hasData) {
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
                            SizedBox(height: 20),
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
                            SizedBox(height: 20),
                            Padding(
                              padding: EdgeInsets.only(left: 50),
                              child: ListTile(
                                title: Text(
                                  customersnap.data['name'],
                                  textScaleFactor: 2,
                                ),
                              ),
                            ),
                            SizedBox(height: 30),
                            Padding(
                              padding: EdgeInsets.only(left: 50, right: 10),
                              child: ListTile(
                                onTap: () {
                                  Navigator.of(context).pop(true);
                                  Navigator.push(context,
                                      MaterialPageRoute(builder: (_) {
                                        return EditProfile(
                                          uid: widget.uid,
                                          usersnap: customersnap.data,
                                        );
                                      }));
                                },
                                title: Row(
                                  children: [
                                    Text(
                                      'Edit Profile',
                                      style: TextStyle(fontSize: 18),
                                    ),
                                    Spacer(),
                                    Icon(Icons.arrow_forward_ios, size: 18)
                                  ],
                                ),
                              ),
                            ),
                            SizedBox(height: 10),
                            Padding(
                              padding: EdgeInsets.only(left: 50, right: 10),
                              child: ListTile(
                                onTap: () {
                                  Navigator.of(context).pop(true);
                                  Navigator.push(context,
                                      MaterialPageRoute(builder: (_) {
                                        return BookedItems();
                                      }));
                                },
                                title: Row(
                                  children: [
                                    Text(
                                      'Booked Items',
                                      style: TextStyle(fontSize: 18),
                                    ),
                                    Spacer(),
                                    Icon(Icons.arrow_forward_ios, size: 18)
                                  ],
                                ),
                              ),
                            ),
                            SizedBox(height: 10),
                            Padding(
                              padding: EdgeInsets.only(left: 50, right: 10),
                              child: ListTile(
                                onTap: () {
                                  Navigator.of(context).pop(true);
                                  Navigator.push(context,
                                      MaterialPageRoute(builder: (_) {
                                        print(interestedsnap.data.data);
                                        return InterestedItems(
                                          interestedsnap: interestedsnap.data,
                                        );
                                      }));
                                },
                                title: Row(
                                  children: [
                                    Text(
                                      'Interested Items',
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
                          stream: firestore
                              .collection('products')
                              .where(customersnap.data['current_search'],
                              isEqualTo: customersnap.data['search_value'])
                              .limit(count)
                              .snapshots(),
                          builder: (context, productsnap) {
                            if (productsnap.hasData) {
                              return buildItem(productsnap, interestedsnap);
                            } else {
                              return Center(
                                child: SpinKitWave(
                                  color: Colors.orange,
                                  size: 50.0,
                                ),
                              );
                            }
                          },
                        ),
                      ),
                    );
                  } else {
                    return Center(
                      child: SpinKitWave(
                        color: Colors.orange,
                        size: 50.0,
                      ),
                    );
                  }
                });
          } else {
            return Center(
              child: SpinKitWave(
                color: Colors.orange,
                size: 50.0,
              ),
            );
          }
        });
  }

  buildItem(AsyncSnapshot<QuerySnapshot> productsnap,
      AsyncSnapshot<DocumentSnapshot> interestsnap) {
    return ListView.builder(
        controller: _scrollController,
        itemCount: productsnap.data.documents.length,
        itemBuilder: (context, index) {
          return GestureDetector(
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (_) {
                return ProductDetail(
                  productSnap: productsnap.data.documents[index],
                );
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
                        width: MediaQuery
                            .of(context)
                            .size
                            .width / 3,
                        child: ClipRRect(
                          borderRadius: BorderRadius.all(Radius.circular(6)),
                          child: Hero(
                            tag: productsnap.data.documents[index].documentID,
                            child: PNetworkImage(
                              productsnap.data.documents[index].data['images']
                              [0],
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
                                productsnap.data.documents[index]['title'],
                                style: TextStyle(fontSize: 21),
                              ),
                              subtitle: Text(
                                productsnap.data.documents[index]
                                ['description'],
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            SizedBox(height: 10),
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
                        onPressed: () {
                          if (interestsnap.data.data != null) {
                            if (interestsnap.data['interested'].contains(
                                productsnap.data.documents[index].documentID)) {
                              interestsnap.data.reference.updateData({
                                'interested': FieldValue.arrayRemove(
                                  [
                                    productsnap.data.documents[index].documentID
                                  ],
                                )
                              });
                            } else {
                              interestsnap.data.reference.updateData({
                                'interested': FieldValue.arrayUnion(
                                  [
                                    productsnap.data.documents[index].documentID
                                  ],
                                )
                              });
                            }
                          }
                        },
                        icon: interestsnap.data.data != null
                            ? interestsnap.data['interested'].contains(
                          productsnap.data.documents[index].documentID,
                        )
                            ? Icon(
                          Icons.favorite,
                          color: Colors.red[800],
                        )
                            : Icon(Icons.favorite_border)
                            : Icon(Icons.favorite_border),
                      )
                    ],
                  ),
                ),
              ),
            ),
          );
        });
  }

  getDecoration(label) {
    return InputDecoration(
      labelText: label,
      isDense: true,
      labelStyle: TextStyle(
        color: Colors.red.shade300,
        fontWeight: FontWeight.bold,
        fontSize: 16,
        letterSpacing: 1.0,
      ),
      border: InputBorder.none,
      fillColor: Colors.grey.shade200,
      filled: true,
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      disabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
    );
  }
}

/* if (customersnap.data.data['isBlocked'] == true) {
                          FirebaseAuth.instance.signOut();
                          Navigator.pushReplacement(context,
                              MaterialPageRoute(builder: (_) {
                            Utils().toast(
                                context, 'User have been deleted from database',
                                bgColor: Utils().randomGenerator());
                            return SplashScreen(false);
                          }));
                        } */
