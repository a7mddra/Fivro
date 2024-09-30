import 'dart:typed_data';
import 'package:car_rental_a7md/models/car.dart';
import 'package:car_rental_a7md/resources/storage_methods.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';

class FirestoreMethods {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<String> upload(
    String model,
    int price,
    String uid,
    Uint8List file,
    String lat,
    String lng,
    bool state,
    String purl,
    String unam,
  ) async {
    String res = "An Error has occurred :/";
    try {
      String photoUrl =
          await StorageMethods().uploadImageToStorage('carsPics', file, true);
      String carId = const Uuid().v1();
      Car car = Car(
          model: model,
          uid: uid,
          carId: carId,
          price: price,
          date: DateTime.now(),
          lat: lat,
          lng: lng,
          carUrl: photoUrl,
          state: state,
          profUrl: purl,
          uName: unam,
          books: []);
      await _firestore
          .collection('cars')
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .set(car.toJson());
      res = "Success";
    } catch (err) {
      res = err.toString();
    }
    return res;
  }
}
