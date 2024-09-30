import 'package:cloud_firestore/cloud_firestore.dart';

class Car {
  final String model;
  final String uid;
  final String carId;
  final int price;
  final DateTime date;
  final String carUrl;
  final String lat;
  final String lng;
  final bool state;
  final String profUrl;
  final String uName;
  final List books;

  const Car({
    required this.model,
    required this.uid,
    required this.carId,
    required this.price,
    required this.date,
    required this.carUrl,
    required this.lat,
    required this.lng,
    required this.state,
    required this.profUrl,
    required this.uName,
    required this.books,
  });

  Map<String, dynamic> toJson() => {
        'model': model,
        'uid': uid,
        'carId': carId,
        'price': price,
        'date': date,
        'carUrl': carUrl,
        'lat': lat,
        'lng': lng,
        'state': state,
        'profUrl': profUrl,
        'uName': uName,
        'books': books,
      };

  static Car fromSnap(DocumentSnapshot snap) {
    var snapshot = snap.data() as Map<String, dynamic>;
    return Car(
        model: snapshot['model'],
        uid: snapshot['uid'],
        carId: snapshot['carId'],
        price: snapshot['price'],
        date: snapshot['date'],
        carUrl: snapshot['carUrl'],
        lat: snapshot['lat'],
        lng: snapshot['lng'],
        state: snapshot['state'],
        profUrl: snapshot['profUrl'],
        uName: snapshot['uName'],
        books: snapshot['books']);
  }
}
