// ignore_for_file: use_build_context_synchronously
import 'dart:typed_data';
import 'package:car_rental_a7md/rentee/home.dart';
import 'package:car_rental_a7md/renter/home.dart';
import 'package:car_rental_a7md/renter/homee.dart';
import 'package:car_rental_a7md/utils/utils.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'package:http/http.dart' as http;

class MobScreenLayout extends StatefulWidget {
  const MobScreenLayout({super.key});

  @override
  State<MobScreenLayout> createState() => _MobScreenLayoutState();
}

class _MobScreenLayoutState extends State<MobScreenLayout> {
  var userData = {};
  var carData = {};
  bool isLoading = false;
  Widget? car;
  Uint8List? img;
  String? mod;
  int? pri;
  ImageProvider<Object>? pro;
  String? nam;
  LatLng? loc;
  bool? stt;

  @override
  void initState() {
    super.initState();
    getUData();
  }

  Future<Uint8List?> urlToUint8List(String imageUrl) async {
    try {
      final response = await http.get(Uri.parse(imageUrl));

      if (response.statusCode == 200) {
        return response.bodyBytes;
      } else {
        return null;
      }
    } catch (e) {
      return null;
    }
  }

  getUData() async {
    setState(() {
      isLoading = true;
    });

    try {
      User? user = FirebaseAuth.instance.currentUser;

      if (user != null) {
        var userSnap = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();
        
        if (userSnap.exists) {
          userData = userSnap.data()!;

          setState(() {
            pro = NetworkImage(userData['photoUrl']);
            nam = userData['fullName'];
          });

          if (userData['type'] == "Rentee") {
            Navigator.of(context)
                .pushReplacement(_noAnimationPageRoute(const Home1()));
          } else {
            await getCData();
          }
        } else {
          showSnackBar(context, 'User data not found.');
        }
      } else {
        showSnackBar(context, 'User not authenticated');
      }
    } catch (e) {
      showSnackBar(context, e.toString());
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  getCData() async {
    try {
      setState(() {
        isLoading = true;
      });

      QuerySnapshot carSnap = await FirebaseFirestore.instance.collection('cars').get();

      if (carSnap.docs.isEmpty) {
        Navigator.of(context)
            .pushReplacement(_noAnimationPageRoute(const Home2()));
        return;
      }

      var currentUserCarDoc = await FirebaseFirestore.instance
          .collection('cars')
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .get();

      if (!currentUserCarDoc.exists) {
        Navigator.of(context)
            .pushReplacement(_noAnimationPageRoute(const Home2()));
        return;
      }

      setState(() {
        carData = currentUserCarDoc.data() as Map<String, dynamic>;
      });

      Uint8List? file = await urlToUint8List(carData['carUrl']);
      setState(() {
        car = Image.network(
          carData['carUrl'],
          fit: BoxFit.cover,
        );
        mod = carData['model'];
        pri = carData['price'];
        loc = LatLng(double.parse(carData['lat']), double.parse(carData['lng']));
        stt = carData['state'];
        img = file;
      });

      Navigator.of(context).pushReplacement(_noAnimationPageRoute(Home(
        car: car,
        img: img,
        mod: mod,
        pri: pri,
        pro: pro,
        nam: nam,
        loc: loc,
        stt: stt,
      )));

    } catch (e) {
      showSnackBar(context, e.toString());
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: isLoading
          ? const Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Expanded(
                  child: Center(
                    child: Text(
                      "Fivro",
                      style: TextStyle(
                        color: Colors.black,
                        fontFamily: 'be',
                        fontSize: 35,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                Text("Fivro App © 1.0.0",
                    style: TextStyle(
                        color: Color.fromARGB(255, 190, 190, 190),
                        fontSize: 17,
                        fontWeight: FontWeight.normal,
                        fontFamily: 'be')),
                SizedBox(height: 8),
              ],
            )
          : Container(),
    );
  }

  PageRouteBuilder _noAnimationPageRoute(Widget page) {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionDuration: Duration.zero,
      reverseTransitionDuration: Duration.zero,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return child;
      },
    );
  }
}