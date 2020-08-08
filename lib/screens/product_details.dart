import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_data_stream_builder/flutter_data_stream_builder.dart';
import 'package:map_launcher/map_launcher.dart';
import 'package:the_project_hariyal/screens/widgets/network_image.dart';
import 'package:the_project_hariyal/utils.dart';

class ProductDetails extends StatefulWidget {
  final pid;

  ProductDetails(this.pid);

  @override
  _ProductDetailsState createState() => _ProductDetailsState();
}

class _ProductDetailsState extends State<ProductDetails>
    with TickerProviderStateMixin {
  List<Tab> tabList = List();
  TabController _tabController;
  Firestore firestore;
  Utils utils;

  @override
  void initState() {
    firestore = Firestore.instance;
    utils = new Utils();
    tabList.add(new Tab(
      text: 'Description',
    ));
    tabList.add(new Tab(
      text: 'Specifications',
    ));
    tabList.add(new Tab(
      text: 'More Info',
    ));
    _tabController = new TabController(vsync: this, length: tabList.length);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    try {
      return Scaffold(
        appBar: AppBar(
          title: Text('Product Details'),
        ),
        body: DataStreamBuilder<DocumentSnapshot>(
            stream: firestore
                .collection('products')
                .document(widget.pid)
                .snapshots(),
            builder: (context, snapshot) {
              return Column(
                children: <Widget>[
                  ListTile(
                    leading: PNetworkImage(snapshot['images'][0]),
                    title: Text(
                      utils.camelCase(snapshot['title']),
                      style: TextStyle(fontSize: 18),
                    ),
                    subtitle: Text(
                      snapshot['price'].toString(),
                      style: TextStyle(fontSize: 18),
                    ),
                  ),
                  new Container(
                    child: new TabBar(
                        controller: _tabController,
                        indicatorColor: Colors.blueAccent[700],
                        labelColor: Colors.blueAccent[700],
                        isScrollable: true,
                        labelStyle: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                        indicatorSize: TabBarIndicatorSize.tab,
                        tabs: tabList),
                  ),
                  Expanded(
                    child: TabBarView(
                      controller: _tabController,
                      children: tabList
                          .map((Tab tab) => _getPage(tab, snapshot))
                          .toList(),
                    ),
                  )
                ],
              );
            }),
      );
    } catch (e) {
      return utils.errorWidget(e.toString());
    }
  }

  Widget _getPage(Tab tab, DocumentSnapshot snapshot) {
    switch (tab.text) {
      case 'Description':
        return description(snapshot);
      case 'Specifications':
        return specification(snapshot);
      case 'More Info':
        return moreInfo(snapshot);
    }
  }

  Widget description(DocumentSnapshot snapshot) {
    return Container(
      padding: EdgeInsets.all(12),
      child: Text(
        snapshot['description'],
        style: TextStyle(fontSize: 18),
      ),
    );
  }

  Widget specification(DocumentSnapshot snapshot) {
    return snapshot['specifications'].length > 0
        ? ListView.builder(
            itemCount: snapshot['specifications'].length,
            itemBuilder: (BuildContext context, int index) {
              String key = snapshot['specifications'].keys.elementAt(index);
              return ListTile(
                title: Text(key),
                subtitle: Text(snapshot['specifications'][key]),
              );
            })
        : Center(
            child:
                Text('No Specifications found', style: TextStyle(fontSize: 18)),
          );
  }

  Widget moreInfo(DocumentSnapshot snapshot) {
    return DataStreamBuilder<DocumentSnapshot>(
      stream: firestore
          .collection('showrooms')
          .document(snapshot['address'])
          .snapshots(),
      builder: (context, addressSnap) {
        return Container(
          padding: EdgeInsets.all(12),
          child: Column(
            children: <Widget>[
              Row(
                children: <Widget>[
                  Container(
                    width: MediaQuery.of(context).size.width / 2.3,
                    child: Text('Category', style: TextStyle(fontSize: 18)),
                  ),
                  Expanded(
                    child: SelectableText(
                        utils.camelCase(snapshot['category']['category']),
                        style: TextStyle(fontSize: 18)),
                  ),
                ],
              ),
              SizedBox(
                height: 20,
              ),
              Row(
                children: <Widget>[
                  Container(
                    width: MediaQuery.of(context).size.width / 2.3,
                    child:
                        Text('Showroom Name', style: TextStyle(fontSize: 18)),
                  ),
                  Expanded(
                    child: SelectableText(utils.camelCase(addressSnap['name']),
                        style: TextStyle(fontSize: 18)),
                  ),
                ],
              ),
              SizedBox(
                height: 20,
              ),
              Row(
                children: <Widget>[
                  Container(
                    width: MediaQuery.of(context).size.width / 2.3,
                    child:
                        Text('Available Area', style: TextStyle(fontSize: 18)),
                  ),
                  Expanded(
                    child: SelectableText(utils.camelCase(addressSnap['area']),
                        style: TextStyle(fontSize: 18)),
                  ),
                ],
              ),
              SizedBox(
                height: 20,
              ),
              Row(
                children: <Widget>[
                  Container(
                    width: MediaQuery.of(context).size.width / 2.3,
                    child:
                        Text('Available State', style: TextStyle(fontSize: 18)),
                  ),
                  Expanded(
                    child: SelectableText(utils.camelCase(addressSnap['state']),
                        style: TextStyle(fontSize: 18)),
                  ),
                ],
              ),
              SizedBox(
                height: 20,
              ),
              Row(
                children: <Widget>[
                  Container(
                    width: MediaQuery.of(context).size.width / 2.3,
                    child: Text('Showroom Address',
                        style: TextStyle(fontSize: 18)),
                  ),
                  Expanded(
                    child: SelectableText(
                      utils.camelCase(addressSnap['address']),
                      style: TextStyle(fontSize: 18),
                    ),
                  ),
                ],
              ),
              SizedBox(
                height: 40,
              ),
              Container(
                decoration: BoxDecoration(
                    border: Border.all(color: Colors.black87),
                    borderRadius: BorderRadius.all(Radius.circular(6))),
                width: MediaQuery.of(context).size.width,
                child: FlatButton.icon(
                  icon: Icon(
                    Icons.call,
                    color: Colors.black,
                  ),
                  padding: EdgeInsets.symmetric(vertical: 12.0),
                  onPressed: () {
                    //login();
                  },
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(
                      Radius.circular(6.0),
                    ),
                  ),
                  label: Text(
                    'Call Showroom',
                    style: TextStyle(color: Colors.black, fontSize: 20),
                  ),
                ),
              ),
              SizedBox(
                height: 20,
              ),
              Container(
                width: MediaQuery.of(context).size.width,
                child: RaisedButton.icon(
                  icon: Icon(
                    Icons.location_on,
                    color: Colors.white,
                  ),
                  padding: EdgeInsets.symmetric(vertical: 12.0),
                  color: Colors.blueAccent[400],
                  onPressed: () async {
                    final availableMaps = await MapLauncher.installedMaps;
                    await availableMaps.first.showMarker(
                      coords: Coords(double.parse(snapshot['latitude']),
                          double.parse(snapshot['longitude'])),
                      title: "Ocean Beach",
                    );
                    /*if (await MapLauncher.isMapAvailable(MapType.google)) {
                      await MapLauncher.showMarker(
                        mapType: MapType.google,
                        coords: Coords(double.parse(snapshot['latitude']),
                            double.parse(snapshot['longitude'])),
                        title: addressSnap['name'],
                        description: 'Showroom Address',
                      );
                    }*/
                  },
                  elevation: 12,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(
                      Radius.circular(6.0),
                    ),
                  ),
                  label: Text(
                    'View showroom in maps',
                    style: TextStyle(color: Colors.white, fontSize: 20),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
