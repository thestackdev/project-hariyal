import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'booked_items.dart';
import 'edit_profile.dart';
import 'interested_items.dart';
import 'product_details.dart';
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
  Stream _query;
  Firestore firestore = Firestore.instance;
  bool isFilterChanged = false;
  String state;
  String area;
  String category;

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
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    _scrollController = ScrollController();
    _scrollController.addListener(_scrollListener);
    firestore = Firestore.instance;
    getFilters();
    initFilters();
    super.initState();
  }

  initFilters() {
    firestore.collection('customers').document(widget.uid).get().then((value) {
      if (mounted) {
        setState(() {
          state = value.data['location']['state'];
          area = value.data['location']['cityDistrict'];
        });
      }
      _query = firestore
          .collection('products')
          .where('area', isEqualTo: value.data['location']['cityDistrict'])
          .limit(count)
          .snapshots();
    });
  }

  getFilters() async {
    firestore.collection('extras').getDocuments().then((value) {
      value.documents.forEach((element) {
        if (element.documentID == 'states') {
          states.addAll(element.data['states_array'].toList());
          states.add('All');
        } else if (element.documentID == 'category') {
          categories.addAll(element.data['category_array'].toList());
          categories.add('All');
        } else if (element.documentID == 'areas') {
          areas.addAll(element.data['areas_array'].toList());
          areas.add('All');
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
          builder: (context, buildstate) {
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
                      // value: state.toLowerCase(),
                      decoration: getDecoration('State'),
                      isExpanded: true,
                      iconEnabledColor: Colors.grey,
                      style: TextStyle(color: Colors.grey, fontSize: 16),
                      iconSize: 30,
                      elevation: 9,
                      onChanged: (newValue) {
                        setState(() {
                          state = newValue;
                        });
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
                      //  value: area.toLowerCase(),
                      decoration: getDecoration('Area'),
                      isExpanded: true,
                      iconEnabledColor: Colors.grey,
                      style: TextStyle(color: Colors.grey, fontSize: 16),
                      iconSize: 30,
                      elevation: 9,
                      onChanged: (newValue) {
                        setState(() {
                          area = newValue;
                        });
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
                      // value: category == null ? 'All' : category.toLowerCase(),
                      decoration: getDecoration('Category'),
                      isExpanded: true,
                      iconEnabledColor: Colors.grey,
                      style: TextStyle(color: Colors.grey, fontSize: 16),
                      iconSize: 30,
                      elevation: 9,
                      onChanged: (newValue) {
                        setState(() {
                          category = newValue;
                        });
                      },
                      items: categories.map<DropdownMenuItem<String>>((e) {
                        return DropdownMenuItem<String>(
                            value: e,
                            child: Text(
                              e.toString(),
                            ));
                      }).toList()),
                  Container(
                    alignment: Alignment.topRight,
                    child: RaisedButton(
                      child: Text('Done'),
                      onPressed: () {
                        if (area != null && state != null && category != null) {
                          getScenario(7, area, state, category);
                        } else if (area != null && state != null) {
                          getScenario(6, area, state, category);
                        } else if (area != null && category != null) {
                          getScenario(5, area, state, category);
                        } else if (state != null && area != null) {
                          getScenario(4, area, state, category);
                        } else if (state != null && category != null) {
                          getScenario(3, area, state, category);
                        } else if (state != null) {
                          getScenario(2, area, state, category);
                        } else if (area != null) {
                          getScenario(1, area, state, category);
                        } else if (category != null) {
                          getScenario(0, area, state, category);
                        }
                        Navigator.pop(context);
                      },
                    ),
                  )
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
                            Padding(
                              padding: EdgeInsets.only(left: 50, right: 10),
                              child: ListTile(
                                onTap: () {},
                                title: Row(
                                  children: [
                                    Text(
                                      'Refer a Friend',
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
                            Padding(
                              padding: EdgeInsets.only(left: 50),
                              child: ListTile(
                                onTap: () => FirebaseAuth.instance.signOut(),
                                title: Text(
                                  'Logout',
                                  style: TextStyle(fontSize: 18),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      body: SafeArea(
                        child: StreamBuilder<QuerySnapshot>(
                          stream: _query,
                          builder: (context, productsnap) {
                            if (productsnap.connectionState ==
                                    ConnectionState.waiting &&
                                isFilterChanged) {
                              return Center(
                                child: SpinKitWave(
                                  color: Colors.orange,
                                  size: 50.0,
                                ),
                              );
                            } else if (productsnap.hasData) {
                              if (productsnap.data.documents.length == 0) {
                                return Center(
                                  child: Text(
                                    'No products found with the search criteria',
                                    textAlign: TextAlign.center,
                                  ),
                                );
                              }
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
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) {
                  return ProductDetail(
                    productSnap: productsnap.data.documents[index],
                    uid: widget.uid,
                  );
                }),
              );
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
                                '${productsnap.data.documents[index]['price']} Rs',
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
                          } else {
                            interestsnap.data.reference.setData({
                              'interested': FieldValue.arrayUnion(
                                [productsnap.data.documents[index].documentID],
                              )
                            });
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

  getScenario(int num, area, state, category) async {
    setState(() {
      isFilterChanged = true;
      if (area == 'All') area = null;
      if (category == 'All') category = null;
      if (state == 'All') state = null;
      switch (num) {
        case 0:
          _query = firestore
              .collection('products')
              .where('category', isEqualTo: category)
              .limit(count)
              .snapshots();
          break;
        case 1:
          _query = firestore
              .collection('products')
              .where('location.area', isEqualTo: area)
              .limit(count)
              .snapshots();
          break;
        case 2:
          _query = firestore
              .collection('products')
              .where('location.state', isEqualTo: state)
              .limit(count)
              .snapshots();

          break;
        case 3:
          _query = firestore
              .collection('products')
              .where('location.state', isEqualTo: state)
              .where('category', isEqualTo: category)
              .limit(count)
              .snapshots();
          break;
        case 4:
          _query = firestore
              .collection('products')
              .where('location.state', isEqualTo: state)
              .where('location.area', isEqualTo: area)
              .limit(count)
              .snapshots();
          break;
        case 5:
          _query = firestore
              .collection('products')
              .where('location.area', isEqualTo: area)
              .where('category', isEqualTo: category)
              .limit(count)
              .snapshots();
          break;
        case 6:
          _query = firestore
              .collection('products')
              .where('location.state', isEqualTo: state)
              .where('location.area', isEqualTo: area)
              .limit(count)
              .snapshots();
          break;
        case 7:
          _query = firestore
              .collection('products')
              .where('location.state', isEqualTo: state)
              .where('location.area', isEqualTo: area)
              .where('category', isEqualTo: category)
              .limit(count)
              .snapshots();
          break;
      }
    });
    isFilterChanged = true;
  }
}
