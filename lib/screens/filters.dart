import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_data_stream_builder/flutter_data_stream_builder.dart';
import 'package:provider/provider.dart';
import 'package:the_project_hariyal/utils.dart';

class Filters extends StatefulWidget {
  @override
  _FiltersState createState() => _FiltersState();
}

class _FiltersState extends State<Filters> {
  final Utils utils = Utils();
  Firestore firestore = Firestore.instance;
  String selectedCategory;
  String selectedState;
  String selectedArea;
  String selectedSubCategory;
  List subCategory = [];
  List areasList = [];
  Map categoryMap = {};
  Map locationsMap = {};

  @override
  Widget build(BuildContext context) {
    try {
      final DocumentSnapshot usersnap = context.watch<DocumentSnapshot>();

      return Scaffold(
        appBar: AppBar(
          title: Text('Filers'),
        ),
        body: DataStreamBuilder<QuerySnapshot>(
            loadingBuilder: (context) => utils.loadingIndicator(),
            stream: firestore.collection('extras').snapshots(),
            builder: (context, snapshot) {
              for (var map in snapshot.documents) {
                if (map.documentID == 'category') {
                  categoryMap['All'] = ['All'];
                  categoryMap.addAll(map.data);
                } else if (map.documentID == 'locations') {
                  locationsMap['All'] = ['All'];
                  locationsMap.addAll(map.data);
                }
              }
              if (selectedCategory != null) {
                subCategory = categoryMap[selectedCategory];
              }
              if (selectedState != null) {
                areasList = locationsMap[selectedState];
              }
              return Container(
                padding: EdgeInsets.all(12),
                margin: EdgeInsets.all(12),
                child: ListView(
                  children: [
                    Divider(),
                    Text(
                      'Filter by',
                      style:
                          TextStyle(fontSize: 21, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    utils.productInputDropDown(
                        label: 'Category',
                        value: selectedCategory,
                        items: categoryMap.keys.toList(),
                        onChanged: (value) {
                          selectedCategory = value;
                          selectedSubCategory = null;
                          handleState();
                        }),
                    utils.productInputDropDown(
                        label: 'Sub-Category',
                        value: selectedSubCategory,
                        items: subCategory,
                        onChanged: (value) {
                          selectedSubCategory = value;
                          handleState();
                        }),
                    utils.productInputDropDown(
                        label: 'State',
                        value: selectedState,
                        items: locationsMap.keys.toList(),
                        onChanged: (value) {
                          selectedState = value;
                          selectedArea = null;
                          handleState();
                        }),
                    utils.productInputDropDown(
                        label: 'Area',
                        value: selectedArea,
                        items: areasList,
                        onChanged: (newValue) {
                          selectedArea = newValue;
                          handleState();
                        }),
                    Row(
                      children: <Widget>[
                        Container(
                          width: (MediaQuery.of(context).size.width / 2) - 40,
                          child: RaisedButton(
                            padding: EdgeInsets.symmetric(vertical: 12.0),
                            child: Text(
                              'Clear',
                              style:
                                  TextStyle(fontSize: 20, color: Colors.black),
                            ),
                            elevation: 2,
                            color: Colors.grey.shade300,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.all(
                                Radius.circular(6.0),
                              ),
                            ),
                            onPressed: () {
                              usersnap.reference.updateData({
                                'search': {
                                  'category': null,
                                  'subCategory': null,
                                  'state': null,
                                  'area': null,
                                }
                              });
                              Navigator.pop(context);
                            },
                          ),
                        ),
                        SizedBox(
                          width: 30,
                        ),
                        Container(
                          width: (MediaQuery.of(context).size.width / 2) - 40,
                          child: RaisedButton(
                            padding: EdgeInsets.symmetric(vertical: 12.0),
                            color: Colors.blueAccent[400],
                            elevation: 2,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.all(
                                Radius.circular(6.0),
                              ),
                            ),
                            child: Text(
                              'Done',
                              style:
                                  TextStyle(fontSize: 20, color: Colors.white),
                            ),
                            onPressed: () {
                              usersnap.reference.updateData({
                                'search': {
                                  'category': selectedCategory == 'All'
                                      ? null
                                      : selectedCategory,
                                  'subCategory': selectedSubCategory == 'All'
                                      ? null
                                      : selectedSubCategory,
                                  'state': selectedState == 'All'
                                      ? null
                                      : selectedState,
                                  'area': selectedArea == 'All'
                                      ? null
                                      : selectedArea,
                                }
                              });
                              Navigator.pop(context);
                            },
                          ),
                        ),
                      ],
                    )
                  ],
                ),
              );
            }),
      );
    } catch (e) {
      utils.errorWidget(e.toString());
    }
  }

  handleState() => (mounted) ? setState(() => null) : null;
}
