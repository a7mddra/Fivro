/*import 'dart:typed_data';
import 'package:car_rental_a7md/utils/utils.dart';
import 'package:car_rental_a7md/widgets/map.dart';
import 'package:car_rental_a7md/widgets/updmod.dart';
import 'package:car_rental_a7md/widgets/updpri.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:image_picker/image_picker.dart';
import 'package:latlong2/latlong.dart';
import 'package:lottie/lottie.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> with SingleTickerProviderStateMixin {
  bool isAdded = false;
  bool isLoading = false;
  bool isAvailable = false;
  bool isUpdate = false;
  bool isUimg = false;
  var userData = {};
  var carData = {};
  String error = '';
  String carModel = '';
  String pricePerDay = '';
  Widget? img;
  Uint8List? imageFile;
  LatLng? _selectedLoc;
  User currentUser = FirebaseAuth.instance.currentUser!;

  Future<void> _openMapDialog() async {
    final result = await showGeneralDialog<Map<String, dynamic>>(
      context: context,
      barrierDismissible: true,
      barrierLabel: '',
      barrierColor: Colors.transparent,
      transitionDuration: const Duration(milliseconds: 100),
      pageBuilder: (BuildContext context, Animation<double> animation,
          Animation<double> secondaryAnimation) {
        return Center(
          child: Container(
              height: MediaQuery.of(context).size.height,
              width: MediaQuery.of(context).size.width,
              color: Colors.transparent,
              child: MapWidget(
                initialLocation: _selectedLoc,
              )),
        );
      },
    );

    if (result != null) {
      setState(() {
        _selectedLoc = result['loc'];
      });
    }
  }

  Future<void> _openUpdmodDialog(String mod) async {
    final result = await showGeneralDialog<Map<String, dynamic>>(
      context: context,
      barrierDismissible: true,
      barrierLabel: '',
      barrierColor: Colors.transparent,
      transitionDuration: const Duration(milliseconds: 100),
      pageBuilder: (BuildContext context, Animation<double> animation,
          Animation<double> secondaryAnimation) {
        return Center(
          child: Container(
              height: MediaQuery.of(context).size.height,
              width: MediaQuery.of(context).size.width,
              color: Colors.transparent,
              child: Updmod(carModel: mod)),
        );
      },
    );

    if (result != null) {
      setState(() {
        carModel = result['model'];
      });
    }
  }

  Future<void> _openUpdpriDialog(String pri) async {
    final result = await showGeneralDialog<Map<String, dynamic>>(
      context: context,
      barrierDismissible: true,
      barrierLabel: '',
      barrierColor: Colors.transparent,
      transitionDuration: const Duration(milliseconds: 100),
      pageBuilder: (BuildContext context, Animation<double> animation,
          Animation<double> secondaryAnimation) {
        return Center(
          child: Container(
              height: MediaQuery.of(context).size.height,
              width: MediaQuery.of(context).size.width,
              color: Colors.transparent,
              child: Updpri(
                price: pri,
              )),
        );
      },
    );

    if (result != null) {
      setState(() {
        pricePerDay = result['price'];
      });
    }
  }

  @override
  void initState() {
    super.initState();
    getUData();
    getCData();
    if (!isLoading) {
      setState(() {
        if (carData['lat'] != '' && carData['lng'] != '') {
          _selectedLoc = LatLng(
              double.parse(carData['lat']), double.parse(carData['lng']));
        }
      });
    }
  }

  getUData() async {
    setState(() {
      isLoading = true;
    });
    try {
      var userSnap = await FirebaseFirestore.instance
          .collection('users')
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .get();

      userData = userSnap.data()!;
      setState(() {
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      // ignore: use_build_context_synchronously
      showSnackBar(context, e.toString());
    }
  }

  getCData() async {
    setState(() {
      isLoading = true;
    });
    try {
      var userSnap = await FirebaseFirestore.instance
          .collection('cars')
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .get();

      carData = userSnap.data()!;
      setState(() {
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      // ignore: use_build_context_synchronously
      showSnackBar(context, e.toString());
    }
  }

  _selectImage(BuildContext parentContext) async {
    Uint8List? file = await pickImage(ImageSource.gallery);
    if (file != null) {
      setState(() {
        isUimg = true;
        imageFile = file;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: isLoading
          ? Stack(
              children: [
                Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 60),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(2.0),
                            child: SizedBox(
                                height: 55,
                                width: MediaQuery.of(context).size.width * 0.5 -
                                    40,
                                child: Container(
                                  decoration: BoxDecoration(
                                      color: const Color.fromARGB(
                                          255, 221, 221, 221),
                                      borderRadius: BorderRadius.circular(40)),
                                )),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(2.0),
                            child: SizedBox(
                                height: 55,
                                width: MediaQuery.of(context).size.width * 0.5 -
                                    40,
                                child: Container(
                                  decoration: BoxDecoration(
                                      color: const Color.fromARGB(
                                          255, 221, 221, 221),
                                      borderRadius: BorderRadius.circular(40)),
                                )),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(
                      height: 8,
                    ),
                    Container(
                      height: MediaQuery.of(context).size.height -
                          (((MediaQuery.of(context).size.width - 40) * 0.5 -
                                  10) *
                              1.125) -
                          355,
                      width: MediaQuery.of(context).size.width - 40,
                      decoration: BoxDecoration(
                          color: const Color.fromARGB(255, 221, 221, 221),
                          borderRadius: BorderRadius.circular(20)),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                            height: ((MediaQuery.of(context).size.width - 40) *
                                        0.5 -
                                    10) *
                                1.125,
                            width:
                                (MediaQuery.of(context).size.width - 40) * 0.5 -
                                    10,
                            decoration: BoxDecoration(
                                color: const Color.fromARGB(255, 221, 221, 221),
                                borderRadius: BorderRadius.circular(20)),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                const CircleAvatar(
                                  radius: 40,
                                  backgroundColor:
                                      Color.fromARGB(255, 221, 221, 221),
                                ),
                                const SizedBox(height: 20),
                                Container(
                                  height: 20,
                                  width:
                                      (MediaQuery.of(context).size.width - 40) *
                                              0.5 -
                                          30,
                                  color:
                                      const Color.fromARGB(255, 221, 221, 221),
                                )
                              ],
                            )),
                        const SizedBox(
                          width: 20,
                        ),
                        Container(
                          height:
                              ((MediaQuery.of(context).size.width - 40) * 0.5 -
                                      10) *
                                  1.125,
                          width:
                              (MediaQuery.of(context).size.width - 40) * 0.5 -
                                  10,
                          decoration: BoxDecoration(
                              color: const Color.fromARGB(255, 221, 221, 221),
                              borderRadius: BorderRadius.circular(20)),
                        )
                      ],
                    ),
                    const SizedBox(height: 30),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Container(
                          height: 30,
                          width: MediaQuery.of(context).size.width - 180,
                          decoration: BoxDecoration(
                              color: const Color.fromARGB(255, 221, 221, 221),
                              borderRadius: BorderRadius.circular(40)),
                        ),
                        const SizedBox(width: 80),
                        Container(
                          height: 20,
                          width: 60,
                          decoration: BoxDecoration(
                              color: const Color.fromARGB(255, 221, 221, 221),
                              borderRadius: BorderRadius.circular(40)),
                        )
                      ],
                    ),
                    const SizedBox(
                      height: 75,
                      child: Padding(
                        padding: EdgeInsets.only(top: 26),
                        child: Align(
                          alignment: Alignment.topCenter,
                          child: Text(
                            '',
                          ),
                        ),
                      ),
                    ),
                    Container(
                      width: MediaQuery.of(context).size.width - 40,
                      height: 54,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(14),
                        color: const Color.fromARGB(255, 221, 221, 221),
                      ),
                    ),
                  ],
                )
              ],
            )
          : Stack(
              children: [
                Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 60),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          SizedBox(
                            height: 55,
                            width: MediaQuery.of(context).size.width * 0.5 - 40,
                            child: ElevatedButton(
                                onPressed: () {},
                                style: ElevatedButton.styleFrom(
                                  foregroundColor: Colors.black,
                                  backgroundColor: Colors.white,
                                  overlayColor:
                                      const Color.fromARGB(255, 117, 117, 117),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(40),
                                  ),
                                  elevation: 0,
                                  shadowColor: Colors.transparent,
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    SvgPicture.asset(
                                      'assets/icons/gear.svg',
                                      height: 24.0,
                                      width: 24.0,
                                    ),
                                    const SizedBox(
                                      width: 8,
                                    ),
                                    const Text(
                                      "Settings",
                                      style: TextStyle(
                                        color: Colors.black,
                                        fontSize: 19,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                )),
                          ),
                          SizedBox(
                            height: 55,
                            width: MediaQuery.of(context).size.width * 0.5,
                            child: ElevatedButton(
                                onPressed: () {},
                                style: ElevatedButton.styleFrom(
                                  foregroundColor: Colors.black,
                                  backgroundColor: Colors.white,
                                  overlayColor:
                                      const Color.fromARGB(255, 117, 117, 117),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(40),
                                  ),
                                  elevation: 0,
                                  shadowColor: Colors.transparent,
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    SvgPicture.asset(
                                      'assets/icons/bell.svg',
                                      height: 24.0,
                                      width: 24.0,
                                    ),
                                    const SizedBox(
                                      width: 8,
                                    ),
                                    const Text(
                                      "Notifications",
                                      style: TextStyle(
                                        color: Colors.black,
                                        fontSize: 19,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                )),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(
                      height: 8,
                    ),
                    /*Container(
                      height: MediaQuery.of(context).size.height -
                          (((MediaQuery.of(context).size.width - 40) * 0.5 -
                                  10) *
                              1.125) -
                          355,
                      width: MediaQuery.of(context).size.width - 40,
                      decoration: BoxDecoration(
                          color: const Color(0xFFF3F3F3),
                          borderRadius: BorderRadius.circular(20)),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          const SizedBox(
                            height: 20,
                          ),
                          SizedBox(
                            height: (MediaQuery.of(context).size.height -
                                    (((MediaQuery.of(context).size.width - 40) *
                                                0.5 -
                                            10) *
                                        1.125) -
                                    355) *
                                0.6,
                            width: MediaQuery.of(context).size.width - 80,
                            child: Stack(fit: StackFit.expand, children: [
                              ClipRRect(
                                  borderRadius: BorderRadius.circular(20),
                                  child: isUimg
                                      ? Image.memory(
                                          imageFile!,
                                          fit: BoxFit.cover,
                                        )
                                      : carData['carUrl'] != null
                                          ? Image.network(
                                              carData['carUrl'],
                                              fit: BoxFit.cover,
                                            )
                                          : Container()),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Align(
                                  alignment: Alignment.topRight,
                                  child: CircleAvatar(
                                    backgroundColor: const Color.fromARGB(
                                        146, 243, 243, 243),
                                    radius: 19,
                                    child: IconButton(
                                      icon: const Icon(
                                        Icons.edit,
                                        color: Colors.black,
                                        size: 24,
                                      ),
                                      onPressed: () {
                                        _selectImage(context);
                                      },
                                      alignment: Alignment.center,
                                    ),
                                  ),
                                ),
                              ),
                            ]),
                          ),
                          const SizedBox(
                            height: 20,
                          ),
                          Row(
                            children: [
                              const SizedBox(
                                width: 20,
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Text(
                                          'Car Model: ${carData['model'] ?? carModel}',
                                          style: const TextStyle(
                                              fontSize: 19,
                                              fontWeight: FontWeight.bold)),
                                      const SizedBox(
                                        width: 20,
                                      ),
                                      CircleAvatar(
                                        backgroundColor:
                                            const Color(0xFFF3F3F3),
                                        radius: 19,
                                        child: IconButton(
                                          icon: const Icon(
                                            Icons.edit,
                                            color: Colors.black,
                                            size: 24,
                                          ),
                                          onPressed: () {
                                            _openUpdmodDialog(
                                                carData['model'] ?? carModel);
                                          },
                                          alignment: Alignment.center,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(
                                    height: 2,
                                  ),
                                  Row(
                                    children: [
                                      Text(
                                          'Price per Day: ${carData['price'] ?? pricePerDay}',
                                          style: const TextStyle(
                                              fontSize: 19,
                                              fontWeight: FontWeight.bold)),
                                      const SizedBox(
                                        width: 20,
                                      ),
                                      CircleAvatar(
                                        backgroundColor:
                                            const Color(0xFFF3F3F3),
                                        radius: 19,
                                        child: IconButton(
                                          icon: const Icon(
                                            Icons.edit,
                                            color: Colors.black,
                                            size: 24,
                                          ),
                                          onPressed: () {
                                            _openUpdpriDialog(
                                                carData['price'] ??
                                                    pricePerDay);
                                          },
                                          alignment: Alignment.center,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),*/
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                            height: ((MediaQuery.of(context).size.width - 40) *
                                        0.5 -
                                    10) *
                                1.125,
                            width:
                                (MediaQuery.of(context).size.width - 40) * 0.5 -
                                    10,
                            decoration: BoxDecoration(
                                color: const Color(0xFFF3F3F3),
                                borderRadius: BorderRadius.circular(20)),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                CircleAvatar(
                                  radius: 40,
                                  backgroundImage: userData['photoUrl'] != null
                                      ? NetworkImage(userData['photoUrl'])
                                      : null,
                                  backgroundColor:
                                      const Color.fromARGB(255, 221, 221, 221),
                                ),
                                const SizedBox(height: 20),
                                Text(userData['fullName'] ?? 'Unknown',
                                    style: const TextStyle(
                                        fontSize: 19,
                                        fontWeight: FontWeight.bold))
                              ],
                            )),
                        const SizedBox(
                          width: 20,
                        ),
                        /*Stack(children: [
                          Container(
                            height: ((MediaQuery.of(context).size.width - 40) *
                                        0.5 -
                                    10) *
                                1.125,
                            width:
                                (MediaQuery.of(context).size.width - 40) * 0.5 -
                                    10,
                            decoration: BoxDecoration(
                                color: const Color(0xFFF3F3F3),
                                borderRadius: BorderRadius.circular(20)),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(20),
                              child: Transform.scale(
                                scale: 1,
                                alignment: Alignment.center,
                                child: Image.asset(
                                  'assets/images/maps.png',
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                          ),
                          SizedBox(
                            height: ((MediaQuery.of(context).size.width - 40) *
                                        0.5 -
                                    10) *
                                1.125,
                            width:
                                (MediaQuery.of(context).size.width - 40) * 0.5 -
                                    10,
                            child: ElevatedButton(
                              onPressed: () async {
                                _openMapDialog();
                              },
                              child: null,
                              style: ElevatedButton.styleFrom(
                                foregroundColor: Colors.transparent,
                                backgroundColor: Colors.transparent,
                                shadowColor: Colors.transparent,
                                overlayColor: Colors.transparent,
                              ),
                            ),
                          ),
                        ])*/
                      ],
                    ),
                    const SizedBox(height: 20),
                    /*Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: MediaQuery.of(context).size.width - 100,
                          child: const Text("Is your car available now?",
                              style: TextStyle(
                                  fontSize: 19, fontWeight: FontWeight.bold)),
                        ),
                        SizedBox(
                          child: CupertinoSwitch(
                              value: carData['state'] ?? isAvailable,
                              onChanged: (bool value) {
                                setState(() {
                                  isAvailable = value;
                                });
                              }),
                        ),
                      ],
                    ),*/
                    SizedBox(
                      height: 75,
                      child: isUpdate
                          ? Padding(
                              padding: const EdgeInsets.only(top: 12),
                              child: Lottie.asset(
                                'assets/animations/loading.json',
                                height: 47,
                                width: 47,
                              ),
                            )
                          : Padding(
                              padding: const EdgeInsets.only(top: 26),
                              child: Align(
                                alignment: Alignment.topCenter,
                                child: Text(
                                  error,
                                  style: const TextStyle(
                                      fontSize: 17, color: Colors.red),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ),
                    ),
                    SizedBox(
                        width: MediaQuery.of(context).size.width - 40,
                        height: 54,
                        child: ElevatedButton(
                            onPressed: () {},
                            style: ElevatedButton.styleFrom(
                                foregroundColor: Colors.white,
                                backgroundColor: Colors.black,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                )),
                            child: const Text(
                              "Update your car details",
                              style: TextStyle(
                                  fontSize: 20, fontWeight: FontWeight.normal),
                            ))),
                  ],
                )
              ],
            ),
    );
  }
}
*/
