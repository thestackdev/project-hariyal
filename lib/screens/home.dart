import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_money_formatter/flutter_money_formatter.dart';
import 'package:paginate_firestore/paginate_firestore.dart';
import 'package:provider/provider.dart';
import 'package:share/share.dart';
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
  Set interestSet = {};
  QuerySnapshot interests;
  DocumentSnapshot userSnap;

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

  void changeScreen(screen) {
    Navigator.of(context).pop();
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => screen,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    userSnap = context.watch<DocumentSnapshot>();
    interests = context.watch<QuerySnapshot>();

    if (userSnap == null || interests == null)
      return Container(
        color: Colors.white,
        child: utils.loadingIndicator(),
      );

    checkUserProfile(userSnap.documentID);

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
              onTap: () => changeScreen(BookedItems()),
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
      body: PaginateFirestore(
        emptyDisplay: utils.nullWidget('No products found !'),
        itemsPerPage: 10,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 0.6,
        ),
        itemBuilderType: PaginateBuilderType.GridView,
        query: firestore
            .collection('products')
            .orderBy('title')
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
                    : userSnap.data['search']['area']),
        itemBuilder: (index, context, productsnap) {
          if (productsnap.data == null) {
            return utils.nullWidget(
              'No products found with the search criteria',
            );
          }
          FlutterMoneyFormatter fmf = new FlutterMoneyFormatter(
            settings: MoneyFormatterSettings(
              symbol: 'INR',
              thousandSeparator: ",",
              symbolAndNumberSeparator: " ",
            ),
            amount: double.parse(
                productsnap.data['price'].toString().replaceAll(",", "")),
          );
          return GestureDetector(
              onTap: () {
                FocusScope.of(context).unfocus();
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => ProductDetail(
                              docId: productsnap.documentID,
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
                            borderRadius: BorderRadius.all(Radius.circular(6)),
                            child: Hero(
                              tag: productsnap.documentID,
                              child: PNetworkImage(
                                productsnap.data['images'][0],
                                fit: BoxFit.contain,
                              ),
                            ),
                          ),
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ListTile(
                            title: Text(
                              utils.camelCase(productsnap.data['title']),
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(fontSize: 18),
                            ),
                            subtitle: Text(
                              productsnap.data['description'],
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          ListTile(
                            trailing: IconButton(
                                onPressed: () {
                                  handleInterests(productsnap);
                                  heartIndex = index;
                                  handleState();
                                },
                                icon:
                                interestSet.contains(productsnap.documentID)
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
        'timestamp': DateTime
            .now()
            .millisecondsSinceEpoch,
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
