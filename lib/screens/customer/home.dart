import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:the_project_hariyal/screens/customer/booked_items.dart';
import 'package:the_project_hariyal/screens/customer/edit_profile.dart';
import 'package:the_project_hariyal/screens/customer/models/product_model.dart';
import 'package:the_project_hariyal/screens/customer/models/user_model.dart';
import 'package:the_project_hariyal/screens/customer/product_details.dart';

import 'widgets/network_image.dart';

class Home extends StatefulWidget {
  final UserModel userModel;
  final uid;

  Home(this.uid, this.userModel);

  @override
  _HomeState createState() => _HomeState(userModel, uid);
}

class _HomeState extends State<Home> {
  final UserModel userModel;
  final uid;

  _HomeState(this.userModel, this.uid);

  var doc;

  ScrollController _scrollController;

  List states = [];
  List<dynamic> areas = [];
  List<dynamic> categories = [];

  List<dynamic> interestedList = [];

  String stateCategory, stateValue;
  String areaCategory, areaValue;

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
    getInterested();
    setState(() {
      stateCategory = 'location.state';
      stateValue = userModel.location['state'];
      areaCategory = 'location.area';
      areaValue = userModel.location['cityDistrict'];
    });
    super.initState();
  }

  Future getInterested() async {
    doc = firestore
        .collection('customers')
        .document(uid)
        .snapshots()
        .listen((event) {
      interestedList = event.data['interested_products'];
    });
  }

  Future setInterested(dynamic id) async {
    if (interestedList.contains(id)) {
      setState(() {
        interestedList.remove(id);
      });
    } else {
      setState(() {
        interestedList.add(id);
      });
    }
    firestore
        .collection('customers')
        .document(uid)
        .updateData({'intrested_products': interestedList});
  }

  Future getFilters() async {
    var doc0 = firestore.collection('extras').document('states');
    var document0 = await doc0.get();
    states = document0['states_array'];

    var doc1 = firestore.collection('extras').document('areas');
    var document1 = await doc1.get();
    areas = document1['areas_array'];

    var doc2 = firestore.collection('extras').document('category');
    var document2 = await doc2.get();
    categories = document2['category_array'];
  }

  void showFilterDialog() {
    showModalBottomSheet(
        context: context,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(6), topRight: Radius.circular(6))),
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
                      style:
                          TextStyle(fontSize: 21, fontWeight: FontWeight.bold),
                    ),
                    Divider(
                      thickness: 1,
                      color: Colors.grey,
                    ),
                    DropdownButtonFormField(
                        decoration: InputDecoration(
                          labelText: 'State',
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
                        ),
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
                        decoration: InputDecoration(
                          labelText: 'Area',
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
                        ),
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
                        decoration: InputDecoration(
                          labelText: 'Category',
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
                        ),
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
        });
  }

  @override
  void dispose() {
    doc.cancel();
    super.dispose();
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
                onTap: () {
                  Navigator.of(context).pop(true);
                  Navigator.push(context, MaterialPageRoute(builder: (_) {
                    return EditProfile(userModel, uid);
                  }));
                },
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
                onTap: () {
                  Navigator.of(context).pop(true);
                  Navigator.push(context, MaterialPageRoute(builder: (_) {
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
        child: StreamBuilder<DocumentSnapshot>(
            stream: firestore
                .collection('customers')
                .document(widget.uid)
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                return StreamBuilder(
                  stream: firestore
                      .collection('products')
                      .where(snapshot.data['current_search'],
                          isEqualTo: snapshot.data['search_value'])
                      .limit(count)
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      return ListView.builder(
                          controller: _scrollController,
                          itemCount: snapshot.data.documents.length,
                          itemBuilder: (context, index) {
                            ProductModel productModel = ProductModel.fromMap(
                                snapshot.data.documents[index].data,
                                snapshot.data.documents[index].documentID);
                            return buildItems(context, productModel);
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
                  onPressed: () {
                    setInterested(productModel.id);
                  },
                  icon: interestedList != null
                      ? interestedList.contains(productModel.id)
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
  }
}
