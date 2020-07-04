import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image/image.dart';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_absolute_path/flutter_absolute_path.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:path_provider/path_provider.dart';

class PushProduct {
  List imageUrls = [];
  final _storage = FirebaseStorage.instance.ref().child('products');
  Firestore _reference = Firestore.instance;

  uploadProduct(
    images,
    category,
    state,
    area,
    price,
    title,
    description,
    uid,
  ) async {
    imageUrls.clear();
    await Future.forEach(images, (element) async {
      imageUrls.add(await uploadProductImages(element));
    });

    final docID = DateTime.now().microsecondsSinceEpoch.toString();

    await _reference.collection('products').document(docID).setData({
      'title': title,
      'description': description,
      'images': imageUrls,
      'location': {
        'state': state.toLowerCase(),
        'area': area.toLowerCase(),
      },
      'category': category.toLowerCase(),
      'author': uid,
      'isSold': false,
    });
    await _reference
        .collection('admin')
        .document(uid)
        .collection('products')
        .document(docID)
        .setData({
      'dateTime': docID,
    });
  }

  uploadProductImages(images) async {
    Image file = decodeImage(
        File(await FlutterAbsolutePath.getAbsolutePath(images.identifier))
            .readAsBytesSync());

    final filePath = await getTemporaryDirectory();

    var compressedImage =
        File('${filePath.path}/${DateTime.now().millisecondsSinceEpoch}.jpg')
          ..writeAsBytesSync(encodeJpg(file, quality: 50));

    try {
      return _storage
          .child(DateTime.now().microsecondsSinceEpoch.toString())
          .putFile(File(compressedImage.path))
          .onComplete
          .then((value) {
        return value.ref.getDownloadURL();
      });
    } catch (e) {
      Fluttertoast.showToast(msg: e.toString());
      return null;
    }
  }
}
