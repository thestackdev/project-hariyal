import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:multi_image_picker/multi_image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:the_project_hariyal/services/upload_product.dart';

class PushData extends StatefulWidget {
  @override
  _PushDataState createState() => _PushDataState();
}

class _PushDataState extends State<PushData> {
  List<Asset> images = [];
  String selectedCategory;
  String selectedState;
  String selectedArea;
  List categoryList = [];
  List areasList = [];
  List statesList = [];
  List showroomList = [];
  String adressId;

  String uid;

  final price = TextEditingController();
  final title = TextEditingController();
  final description = TextEditingController();
  final showroomAdressController = TextEditingController();

  @override
  void initState() {
    Firestore.instance.collection('extras').getDocuments().then(
      (value) {
        value.documents.forEach((element) {
          if (element.documentID == 'category') {
            setState(() {
              element.data['category_array'].forEach((result) {
                categoryList.add(result);
              });
            });
          } else if (element.documentID == 'areas') {
            setState(() {
              element.data['areas_array'].forEach((result) {
                areasList.add(result);
              });
            });
          } else if (element.documentID == 'states') {
            setState(() {
              element.data['states_array'].forEach((result) {
                statesList.add(result);
              });
            });
          }
        });
      },
    );
    Firestore.instance.collection('showrooms').getDocuments().then((value) {
      setState(() {
        value.documents.forEach((element) {
          showroomList.add(element);
        });
      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
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
                        images = await MultiImagePicker.pickImages(
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

                      this.setState(() {});
                    } else {
                      Fluttertoast.showToast(msg: 'Insufficient Permissions');
                    }
                  },
                  icon: Icon(MdiIcons.plusOutline, color: Colors.red.shade300),
                ),
              );
            }
            return Container(
              margin: EdgeInsets.all(9),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(9),
                color: Colors.grey.shade300,
              ),
              child: AssetThumb(
                asset: images[index],
                quality: 50,
                width: 270,
                height: 270,
              ),
            );
          }),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 27, vertical: 9),
          child: DropdownButtonFormField(
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
                setState(
                  () {
                    selectedCategory = newValue;
                  },
                );
              },
              items: categoryList.map<DropdownMenuItem<String>>(
                (e) {
                  return DropdownMenuItem<String>(
                    value: e,
                    child: Text(
                      e.toString(),
                    ),
                  );
                },
              ).toList()),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 27, vertical: 9),
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
              items: statesList.map<DropdownMenuItem<String>>((e) {
                return DropdownMenuItem<String>(
                    value: e,
                    child: Text(
                      e,
                    ));
              }).toList()),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 27, vertical: 9),
          child: DropdownButtonFormField(
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
              items: areasList.map<DropdownMenuItem<String>>((e) {
                return DropdownMenuItem<String>(
                    value: e,
                    child: Text(
                      e.toString(),
                    ));
              }).toList()),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 27, vertical: 9),
          child: DropdownButtonFormField(
            decoration: InputDecoration(
              labelText: 'Showroom',
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
                showroomList.forEach((element) {
                  if (element['name'] == newValue) {
                    setState(() {
                      showroomAdressController.text = element['adress'];
                      adressId = element.documentID;
                    });
                    return false;
                  } else {
                    return true;
                  }
                });
              });
            },
            items: showroomList.map(
                  (value) {
                return DropdownMenuItem(
                  value: value['name'],
                  child: Text(value['name']),
                );
              },
            ).toList(),
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 27, vertical: 9),
          child: TextField(
            readOnly: true,
            maxLines: null,
            controller: showroomAdressController,
            keyboardType: TextInputType.numberWithOptions(decimal: true),
            decoration: InputDecoration(
              labelText: 'Showroom Adress',
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
          padding: const EdgeInsets.symmetric(horizontal: 27, vertical: 9),
          child: TextField(
            controller: price,
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
          padding: const EdgeInsets.symmetric(horizontal: 27, vertical: 9),
          child: TextField(
            controller: title,
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
          padding: const EdgeInsets.symmetric(horizontal: 27, vertical: 9),
          child: TextField(
            controller: description,
            maxLines: null,
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
            elevation: 7,
            onPressed: () async {
              FocusScope.of(context).unfocus();
              showDialog(
                context: context,
                barrierDismissible: false,
                builder: (context) {
                  return Dialog(
                    elevation: 18,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: Padding(
                      padding: EdgeInsets.all(27),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          CircularProgressIndicator(),
                          Text("Just a sec..."),
                        ],
                      ),
                    ),
                  );
                },
              );
              if (images.length > 0 &&
                  selectedCategory != null &&
                  selectedArea != null &&
                  selectedState != null &&
                  title != null &&
                  description != null) {
                await PushProduct().uploadProduct(
                  images,
                  selectedCategory,
                  selectedState,
                  selectedArea,
                  price.text,
                  title.text,
                  description.text,
                  uid,
                  adressId,
                );
                setState(() {
                  images.clear();
                  price.clear();
                  title.clear();
                  description.clear();
                });
                Navigator.pop(context);
              } else {
                Navigator.pop(context);
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
        SizedBox(height: 50),
      ],
    );
  }
}
