import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_data_stream_builder/flutter_data_stream_builder.dart';
import 'package:flutter_money_formatter/flutter_money_formatter.dart';
import 'package:lazy_load_scrollview/lazy_load_scrollview.dart';
import 'package:provider/provider.dart';
import 'package:share/share.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:the_project_hariyal/screens/filters.dart';
import 'package:the_project_hariyal/screens/user_detail.dart';
import 'package:the_project_hariyal/services/auth_services.dart';
import 'package:the_project_hariyal/utils.dart';

import 'booked_items.dart';
import 'edit_profile.dart';
import 'interested_items.dart';
import 'product_info.dart';
import 'widgets/network_image.dart';

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> with TickerProviderStateMixin {
  Firestore firestore = Firestore.instance;
  Utils utils = Utils();
  Set interestSet = {};
  QuerySnapshot interests;
  DocumentSnapshot userSnap;
  bool loading = true;

  TextEditingController _searchQueryController = new TextEditingController();
  bool _isSearching = false, heartVisibility = false;

  int count = 4, heartIndex = 0;
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

  void changeScreen(screen) {
    Navigator.of(context).pop();
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => screen,
      ),
    );
  }

  Future<void> checkSubscription(uid) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      if (!prefs.getBool("subscribed")) {
        FirebaseMessaging().subscribeToTopic(uid);
        await prefs.setBool("subscribed", true);
      }
    } catch (e) {
      print("Something Went Wrong, SharedPreferences is null");
    }
  }

  @override
  Widget build(BuildContext context) {
    try {
      userSnap = context.watch<DocumentSnapshot>();
      interests = context.watch<QuerySnapshot>();

      if (userSnap == null || interests == null)
        return Container(
          color: Colors.white,
          child: utils.loadingIndicator(),
        );

      checkUserProfile(userSnap.documentID);
      checkSubscription(userSnap.documentID);

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
                    utils.camelCase(userSnap.data['name']),
                    textScaleFactor: 2,
                  ),
                ),
              ),
              SizedBox(height: 30),
              utils.drawerTile(
                label: 'Edit Profile',
                onTap: () => changeScreen(EditProfile(
                  uid: userSnap.documentID,
                )),
              ),
              utils.drawerTile(
                label: 'Booked Items',
                onTap: () => changeScreen(BookedItems(userSnap.documentID)),
              ),
              utils.drawerTile(
                label: 'Interested Items',
                onTap: () => changeScreen(InterestedItems()),
              ),
              utils.drawerTile(
                  label: 'Refer a Friend',
                  onTap: () {
                    RenderBox box = context.findRenderObject();
                    Share.share('TODO APP LINK & Description',
                        subject: 'Share to friend',
                        sharePositionOrigin:
                            box.globalToLocal(Offset.zero) & box.size);
                  }),
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
                              onPressed: () async {
                                loading = true;
                                handleState();
                                try {
                                  SharedPreferences prefs =
                                      await SharedPreferences.getInstance();
                                  if (!prefs.getBool("subscribed")) {
                                    FirebaseMessaging().unsubscribeFromTopic(
                                        userSnap.documentID);
                                    await prefs.setBool("subscribed", false);
                                  }
                                } catch (e) {
                                  print(
                                      "Something Went Wrong, SharedPreferences is null");
                                }
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
                  isEqualTo: userSnap.data['search']['category'] == 'default'
                      ? null
                      : userSnap.data['search']['category'])
              .where('category.subCategory',
                  isEqualTo: userSnap.data['search']['subCategory'] == 'default'
                      ? null
                      : userSnap.data['search']['subCategory'])
              .where('location.state',
                  isEqualTo: userSnap.data['search']['state'] == 'default'
                      ? null
                      : userSnap.data['search']['state'])
              .where('location.area',
                  isEqualTo: userSnap.data['search']['area'] == 'default'
                      ? null
                      : userSnap.data['search']['area'])
              .snapshots(),
          builder: (context, productsnap) {
            if (productsnap.documents.length == 0) {
              return utils.nullWidget(
                'No products found with the search criteria',
              );
            } else {
              loading = false;
              return LazyLoadScrollView(
                isLoading: loading,
                onEndOfPage: () {
                  count += 4;
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
                        amount: double.parse(productsnap.documents[index]
                                ['price']
                            .toString()
                            .replaceAll(",", "")),
                      );
                      return GestureDetector(
                          behavior: HitTestBehavior.translucent,
                          onTap: () {
                            loading = true;
                            handleState();
                            FocusScope.of(context).unfocus();
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (_) => ProductInfo(
                                          docId: productsnap
                                              .documents[index].documentID,
                                        )));
                          },
                          child: Card(
                              elevation: 6,
                              child: Column(
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
                                              handleInterests(
                                                  productsnap.documents[index]);
                                              heartIndex = index;
                                              handleState();
                                            },
                                            icon: interestSet.contains(
                                                    productsnap.documents[index]
                                                        .documentID)
                                                ? Icon(
                                                    Icons.favorite,
                                                    color: Colors.red[800],
                                                  )
                                                : Icon(Icons.favorite_border)),
                                        title: Text(
                                          '${fmf.output.compactSymbolOnRight.toString()}',
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      )
                                    ],
                                  ),
                                ],
                              )));
                    }),
              );
            }
          },
        ),
      );
    } catch (e) {
      return Scaffold(
        body: utils.errorWidget(e.toString()),
      );
    }
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
        'author': userSnap.documentID,
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

  handleState() => (mounted) ? setState(() => null) : null;
}
