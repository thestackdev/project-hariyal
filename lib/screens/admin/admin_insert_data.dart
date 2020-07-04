import 'dart:io';
import 'dart:math';
import 'package:flutter/services.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_absolute_path/flutter_absolute_path.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:multi_image_picker/multi_image_picker.dart';
import 'package:permission_handler/permission_handler.dart';

class AdminInsertData extends StatefulWidget {
  @override
  _AdminInsertDataState createState() => _AdminInsertDataState();
}

class _AdminInsertDataState extends State<AdminInsertData> {
  List<Asset> images = [];
  List<Asset> resultList = [];
  List<File> imageFiles = [];
  String selectedCategory;
  String selectedState;
  String selectedArea;
  String title;
  String description;
  bool loading = false;
  String price;
  final _storage = FirebaseStorage.instance.ref().child('products');

  @override
  Widget build(BuildContext context) {
    return loading
        ? Center(
            child: CircularProgressIndicator(),
          )
        : ListView(
            children: <Widget>[
              GridView.count(
                physics: NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                crossAxisCount: 3,
                children: List.generate(images.length + 1, (index) {
                  if (index == images.length) {
                    return Container(
                      margin: EdgeInsets.all(9),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(9),
                        color: Colors.grey.shade300,
                      ),
                      child: IconButton(
                        onPressed: () async {
                          if (await Permission.camera.request().isGranted &&
                              await Permission.storage.request().isGranted) {
                            try {
                              resultList = await MultiImagePicker.pickImages(
                                maxImages: 5,
                                enableCamera: true,
                                selectedAssets: images,
                                cupertinoOptions: CupertinoOptions(
                                  takePhotoIcon: "Pick Images",
                                ),
                                materialOptions: MaterialOptions(
                                  startInAllView: true,
                                  actionBarColor: "#abcdef",
                                  actionBarTitle: "Pick Images",
                                  allViewTitle: "Pick Images",
                                  useDetailsView: false,
                                  selectCircleStrokeColor: "#000000",
                                ),
                              );
                            } on Exception catch (e) {
                              Fluttertoast.showToast(msg: e.toString());
                            }

                            if (!mounted) return;

                            setState(() {
                              images = resultList;
                            });
                          } else {
                            await Permission.camera.request();
                            await Permission.storage.request();
                          }
                        },
                        icon: Icon(MdiIcons.plusOutline,
                            color: Colors.red.shade300),
                      ),
                    );
                  }
                  Asset asset = images[index];
                  return Container(
                    margin: EdgeInsets.all(9),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(9),
                      color: Colors.grey.shade300,
                    ),
                    child: AssetThumb(
                      asset: asset,
                      width: 270,
                      height: 270,
                    ),
                  );
                }),
              ),
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 27, vertical: 9),
                child: DropdownButtonFormField<String>(
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
                      setState(() {
                        selectedCategory = newValue;
                      });
                    },
                    items: <String>['Electronics', 'Furniture']
                        .map<DropdownMenuItem<String>>((e) {
                      return DropdownMenuItem<String>(
                          value: e,
                          child: Text(
                            e.toString(),
                          ));
                    }).toList()),
              ),
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 27, vertical: 9),
                child: DropdownButtonFormField<String>(
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
                      setState(() {
                        selectedState = newValue;
                      });
                    },
                    items: <String>['Telangana', 'AndhraPradesh']
                        .map<DropdownMenuItem<String>>((e) {
                      return DropdownMenuItem<String>(
                          value: e,
                          child: Text(
                            e.toString(),
                          ));
                    }).toList()),
              ),
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 27, vertical: 9),
                child: DropdownButtonFormField<String>(
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
                      setState(() {
                        selectedArea = newValue;
                      });
                    },
                    items: <String>['Hyderabad', 'Secundrabad']
                        .map<DropdownMenuItem<String>>((e) {
                      return DropdownMenuItem<String>(
                          value: e,
                          child: Text(
                            e.toString(),
                          ));
                    }).toList()),
              ),
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 27, vertical: 9),
                child: TextField(
                  onChanged: (value) {
                    price = value;
                  },
                  maxLines: 1,
                  keyboardType: TextInputType.numberWithOptions(decimal: true),
                  decoration: InputDecoration(
                    labelText: 'Price',
                    isDense: true,
                    labelStyle: TextStyle(
                      color: Colors.red.shade300,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      letterSpacing: 1.0,
                    ),
                    contentPadding: EdgeInsets.all(18),
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
                ),
              ),
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 27, vertical: 9),
                child: TextField(
                  onChanged: (value) {
                    title = value;
                  },
                  maxLines: 1,
                  keyboardType: TextInputType.text,
                  decoration: InputDecoration(
                    labelText: 'Title',
                    isDense: true,
                    labelStyle: TextStyle(
                      color: Colors.red.shade300,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      letterSpacing: 1.0,
                    ),
                    contentPadding: EdgeInsets.all(18),
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
                ),
              ),
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 27, vertical: 9),
                child: TextField(
                  onChanged: (value) {
                    description = value;
                  },
                  maxLines: 5,
                  keyboardType: TextInputType.text,
                  decoration: InputDecoration(
                    alignLabelWithHint: true,
                    labelText: 'Description',
                    isDense: true,
                    labelStyle: TextStyle(
                      color: Colors.red.shade300,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      letterSpacing: 1.0,
                    ),
                    contentPadding: EdgeInsets.all(18),
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
                ),
              ),
              SizedBox(
                height: 18,
              ),
              Center(
                child: RaisedButton(
                  padding: EdgeInsets.symmetric(horizontal: 30),
                  elevation: 0,
                  onPressed: () async {
                    if (images.length >
                            0 /* &&
                        selectedCategory != null &&
                        selectedArea != null &&
                        selectedState != null &&
                        title != null &&
                        description != null */
                        ) {
                      images.forEach((element) async {
                        try {
                          final ByteData result =
                              await element.getByteData(quality: 50);
                          final res = await File(
                                  await FlutterAbsolutePath.getAbsolutePath(
                                      element.identifier))
                              .writeAsBytes(result.buffer.asUint8List(
                                  result.offsetInBytes, result.lengthInBytes));
                          _storage
                              .child(Random().nextDouble().toString())
                              .putFile(File(res.path))
                              .onComplete
                              .then((value) {
                            value.ref.getDownloadURL().then((value) async {});
                          });
                        } catch (e) {
                          Fluttertoast.showToast(msg: e.toString());
                        }
                      });
                    } else {
                      Fluttertoast.showToast(msg: 'Invalid Selections');
                    }
                  },
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(9),
                  ),
                  color: Colors.red.shade300,
                  child: Text(
                    'Push Data',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              SizedBox(
                height: 50,
              ),
            ],
          );
  }
}
