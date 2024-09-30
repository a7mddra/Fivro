import 'package:cloud_firestore/cloud_firestore.dart';

class User {
  final String email;
  final String uid;
  final String fullName;
  final int age;
  final String password;
  final String photoUrl;
  final String type;

  const User({
    required this.email,
    required this.uid,
    required this.fullName,
    required this.age,
    required this.password,
    required this.photoUrl,
    required this.type,
  });

  Map<String, dynamic> toJson() => {
        'email': email,
        'uid': uid,
        'fullName': fullName,
        'age': age,
        'password': password,
        'photoUrl': photoUrl,
        'type': type,
      };

  static User fromSnap(DocumentSnapshot snap) {
    var snapshot = snap.data() as Map<String, dynamic>;
    return User(
        email: snapshot['email'],
        uid: snapshot['uid'],
        fullName: snapshot['fullName'],
        age: snapshot['age'],
        password: snapshot['password'],
        photoUrl: snapshot['photoUrl'],
        type: snapshot['type']);
  }
}
