import 'dart:collection';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flare_flutter/flare_actor.dart';
import 'package:flare_flutter/flare_controls.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_data_stream_builder/flutter_data_stream_builder.dart';
import 'package:flutter_money_formatter/flutter_money_formatter.dart';
import 'package:lazy_load_scrollview/lazy_load_scrollview.dart';
import 'package:provider/provider.dart';
import 'package:the_project_hariyal/screens/filters.dart';
import 'package:the_project_hariyal/screens/user_detail.dart';
import 'package:the_project_hariyal/services/auth_services.dart';
import 'package:the_project_hariyal/utils.dart';

import 'booked_items.dart';
import 'edit_profile.dart';
import 'interested_items.dart';
import 'product_details.dart';
import 'widgets/network_image.dart';

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> with TickerProviderStateMixin {
  Firestore firestore = Firestore.instance;
  Utils utils = Utils();
  final FlareControls flareControls = FlareControls();
  Set interestSet = {};
  QuerySnapshot interests;
  DocumentSnapshot usersnap;

  TextEditingController _searchQueryController = new TextEditingController();
  bool _isSearching = false, heartVisibility = false;

  int count = 30, heartIndex = 0;
  Color heartColor = Colors.red[800].withOpacity(0.7);

  _searchListener() {
    if (_searchQueryController.text.isNotEmpty) {
      // getScenario(9, area, state, category);
    }
  }

  @override
  void dispose() {
    _searchQueryController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    utils = new Utils();
    _searchQueryController.addListener(_searchListener);
    super.initState();
  }

  void checkUserProfile(String uid) {
    firestore.collection('customers').document(uid).get().then((value) {
      if (value.exists) {
        if (value.data['name'] == null ||
            value.data['name'].toString().isEmpty ||
            value.data['email'] == null ||
            value.data['email'].toString().isEmpty) {
          Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (context) => UserDetails(uid)));
        }
      } else {
        Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => UserDetails(uid)));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    usersnap = context.watch<DocumentSnapshot>();
    interests = context.watch<QuerySnapshot>();

    if (usersnap == null || interests == null)
      return Container(
        color: Colors.white,
        child: utils.loadingIndicator(),
      );

    checkUserProfile(usersnap.documentID);

    interestSet.clear();
    interests.documents.forEach((element) {
      interestSet.add(element.data['productId']);
    });

    return Scaffold(
      appBar: AppBar(
        title: _isSearching ? _buildSearchField() : Text('Home'),
        actions: _buildActions(),
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
                  utils.camelCase(usersnap.data['name']),
                  textScaleFactor: 2,
                ),
              ),
            ),
            SizedBox(height: 30),
            utils.drawerTile(
              label: 'Edit Profile',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => EditProfile(
                      uid: usersnap.documentID,
                    ),
                  ),
                );
              },
            ),
            utils.drawerTile(
              label: 'Booked Items',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => BookedItems(),
                  ),
                );
              },
            ),
            utils.drawerTile(
              label: 'Interested Items',
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => InterestedItems(),
                ),
              ),
            ),
            utils.drawerTile(label: 'Refer a Friend', onTap: () {}),
            utils.drawerTile(
              label: 'Logout',
              onTap: () {
                return showDialog(
                    context: context,
                    builder: (context) {
                      return AlertDialog(
                        title: Text('Logout!'),
                        content: Text('Are you sure want to log out'),
                        actions: <Widget>[
                          FlatButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                            child: Text('No'),
                          ),
                          FlatButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                              AuthServices().logout();
                            },
                            child: Text('Yes'),
                          )
                        ],
                      );
                    });
              },
            ),
          ],
        ),
      ),
      body: DataStreamBuilder<QuerySnapshot>(
        errorBuilder: (context, error) => utils.errorWidget(error.toString()),
        loadingBuilder: (context) => utils.loadingIndicator(),
        stream: firestore
            .collection('products')
            .where('category.category',
                isEqualTo: usersnap.data['search']['category'] == 'default'
                    ? null
                    : usersnap.data['search']['category'])
            .where('category.subCategory',
                isEqualTo: usersnap.data['search']['subCategory'] == 'default'
                    ? null
                    : usersnap.data['search']['subCategory'])
            .where('location.state',
                isEqualTo: usersnap.data['search']['state'] == 'default'
                    ? null
                    : usersnap.data['search']['state'])
            .where('location.area',
                isEqualTo: usersnap.data['search']['area'] == 'default'
                    ? null
                    : usersnap.data['search']['area'])
            .snapshots(),
        builder: (context, productsnap) {
          if (productsnap.documents.length == 0) {
            return utils.nullWidget(
              'No products found with the search criteria',
            );
          } else {
            return LazyLoadScrollView(
              onEndOfPage: () {
                count += 30;
                handleState();
              },
              child: GridView.builder(
                  itemCount: productsnap.documents.length,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                    childAspectRatio: 0.6,
                  ),
                  itemBuilder: (context, index) {
                    FlutterMoneyFormatter fmf = new FlutterMoneyFormatter(
                      settings: MoneyFormatterSettings(
                        symbol: 'INR',
                        thousandSeparator: ",",
                        symbolAndNumberSeparator: " ",
                      ),
                      amount: double.parse(productsnap.documents[index]['price']
                          .toString()
                          .replaceAll(",", "")),
                    );
                    return GestureDetector(
                        onTap: () {
                          FocusScope.of(context).unfocus();
                          Navigator.push(context,
                              MaterialPageRoute(builder: (_) {
                            return ProductDetail(
                              docId: productsnap.documents[index].documentID,
                            );
                          }));
                        },
                        child: Card(
                            elevation: 6,
                            child: Stack(
                              children: <Widget>[
                                Column(
                                  children: [
                                    SizedBox(
                                      height: 10,
                                    ),
                                    Expanded(
                                      child: Container(
                                        height: 120,
                                        child: ClipRRect(
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(6)),
                                          child: Hero(
                                            tag: productsnap
                                                .documents[index].documentID,
                                            child: PNetworkImage(
                                              productsnap.documents[index]
                                                  .data['images'][0],
                                              fit: BoxFit.contain,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        ListTile(
                                          title: Text(
                                            utils.camelCase(productsnap
                                                .documents[index]['title']),
                                            overflow: TextOverflow.ellipsis,
                                            style: TextStyle(fontSize: 18),
                                          ),
                                          subtitle: Text(
                                            productsnap.documents[index]
                                                ['description'],
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                        ListTile(
                                          trailing: IconButton(
                                              onPressed: () {
                                                handleInterests(productsnap
                                                    .documents[index]);
                                              },
                                              icon: interestSet.contains(
                                                      productsnap
                                                          .documents[index]
                                                          .documentID)
                                                  ? Icon(
                                                      Icons.favorite,
                                                      color: Colors.red[800],
                                                    )
                                                  : Icon(
                                                      Icons.favorite_border)),
                                          title: Text(
                                            '${fmf.output.compactSymbolOnRight.toString()}',
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        )
                                      ],
                                    ),
                                  ],
                                ),
                                heartIndex == index
                                    ? Center(
                                        child: Padding(
                                          padding: EdgeInsets.all(24),
                                          child: FlareActor(
                                            'assets/instagram_like.flr',
                                            controller: flareControls,
                                            animation: 'idle',
                                            fit: BoxFit.contain,
                                            color: Colors.red[800],
                                          ),
                                        ),
                                      )
                                    : Container()
                              ],
                            )));
                  }),
            );
          }
        },
      ),
    );
  }

  handleInterests(DocumentSnapshot snapshot) {
    if (interestSet.contains(snapshot.documentID)) {
      for (var element in interests.documents) {
        if (element.data['productId'] == snapshot.documentID) {
          element.reference.delete();
          snapshot.reference.updateData(
              {'interested_count': --snapshot.data['interested_count']});
          break;
        }
      }
    } else {
      firestore.collection('interests').document().setData({
        'timestamp': DateTime.now().millisecondsSinceEpoch,
        'productId': snapshot.documentID,
        'author': usersnap.documentID,
      });
      snapshot.reference.updateData(
          {'interested_count': ++snapshot.data['interested_count']});
    }
  }

  Widget _buildSearchField() {
    return TextField(
      controller: _searchQueryController,
      autofocus: true,
      decoration: InputDecoration(
        hintText: "Search by name",
        border: InputBorder.none,
        hintStyle: TextStyle(color: Colors.white70),
      ),
      style: TextStyle(color: Colors.white, fontSize: 16.0),
    );
  }

  List<Widget> _buildActions() {
    if (_isSearching) {
      return <Widget>[
        IconButton(
          icon: const Icon(Icons.close),
          onPressed: () {
            if (_searchQueryController != null) {
              setState(() {
                _isSearching = false;
                _searchQueryController.text = "";
              });
              // getScenario(7, area, state, category);
            }
          },
        ),
      ];
    }

    return <Widget>[
      IconButton(
        icon: const Icon(Icons.search),
        onPressed: () {
          setState(() {
            _isSearching = true;
          });
        },
      ),
      IconButton(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => Filters(),
          ),
        ),
        icon: Icon(Icons.filter_list),
      )
    ];
  }

  /* void setInterested(
      DocumentSnapshot interestsnap, QuerySnapshot productsnap, int index) {
    setState(() {
      heartIndex = index;
    });
    int count = productsnap.documents[index].data['interested_count'];
    if (count == null) {
      count = 0;
    }
    if (interestsnap.data != null ||
        interestsnap.data['interested'].length > 0 ||
        interestsnap.data['interested'] != null) {
      Map map = new HashMap();
      map = interestsnap.data['interested'];
      if (map.containsValue(productsnap.documents[index].documentID)) {
        count = count > 0 ? count - 1 : 0;
        updateCount(count, productsnap.documents[index].documentID.toString());
        var key = map.keys.firstWhere(
            (element) =>
                map[element] == productsnap.documents[index].documentID,
            orElse: () => null);
        if (key != null) {
          map.remove(key);
          interestsnap.reference.updateData({'interested': map});
        } else {
          utils.toast(context, 'Something went wrong',
              bgColor: utils.randomGenerator());
        }
      } else {
        flareControls.play("like");
        count = count + 1;
        updateCount(count, productsnap.documents[index].documentID.toString());
        map[Timestamp.now().toDate().toString()] =
            productsnap.documents[index].documentID.toString();
        interestsnap.reference.updateData({'interested': map});
      }
    } else {
      flareControls.play("like");
      count = count + 1;
      updateCount(count, productsnap.documents[index].documentID.toString());
      interestsnap.reference.setData({
        'interested': {
          Timestamp.now().toDate().toString():
              productsnap.documents[index].documentID
        }
      });
    }
  } */

  /*  void updateCount(int count, String pid) {
    firestore
        .collection('products')
        .document(pid)
        .updateData({'interested_count': count});
  }
 */
  handleState() => (mounted) ? setState(() => null) : null;
}
