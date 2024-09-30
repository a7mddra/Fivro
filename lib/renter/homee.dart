import 'package:car_rental_a7md/renter/order_card.dart';
import 'package:car_rental_a7md/resources/auth_methods.dart';
import 'package:car_rental_a7md/resources/storage_methods.dart';
import 'package:car_rental_a7md/utils/utils.dart';
import 'package:car_rental_a7md/views/about.dart';
import 'package:car_rental_a7md/views/login.dart';
import 'package:car_rental_a7md/widgets/refresh.dart';
import 'package:car_rental_a7md/widgets/shimmer.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:car_rental_a7md/views/profile.dart';
import 'package:car_rental_a7md/widgets/map.dart';
import 'package:car_rental_a7md/widgets/updmod.dart';
import 'package:car_rental_a7md/widgets/updpri.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:image_picker/image_picker.dart';
import 'package:latlong2/latlong.dart';
import 'package:lottie/lottie.dart';
import 'dart:typed_data';
import 'dart:ui';

class Home extends StatefulWidget {
  final Widget? car;
  final Uint8List? img;
  final String? mod;
  final int? pri;
  final ImageProvider<Object>? pro;
  final String? nam;
  final LatLng? loc;
  final bool? stt;

  const Home({
    super.key,
    required this.car,
    required this.img,
    required this.mod,
    required this.pri,
    required this.pro,
    required this.nam,
    required this.loc,
    required this.stt,
  });

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  bool isUpdate = false;
  bool isLoading = false;
  bool isOpressed = false;
  bool isSpressed = false;
  bool mode = false;
  String error = '';
  Widget? car;
  Uint8List? img;
  String? mod;
  int? pri;
  ImageProvider<Object>? pro;
  String? nam;
  LatLng? loc;
  bool? stt;
  var userData = {};
  var carData = {};
  var ordersList = [];
  var uData = {};

  @override
  void initState() {
    super.initState();
    getUData();
    getCData();
    img = widget.img;
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
        pro = NetworkImage(userData['photoUrl']);
        nam = userData['fullName'];
        isLoading = false;
      });
    } catch (e) {
      // ignore: use_build_context_synchronously
      showSnackBar(context, e.toString());
    }
  }

  getCData() async {
    try {
      setState(() {
        isLoading = true;
      });
      var carSnap = await FirebaseFirestore.instance
          .collection('cars')
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .get();

      carData = carSnap.data()!;
      setState(() {
        car = Image.network(
          carData['carUrl'],
          fit: BoxFit.cover,
        );
        mod = carData['model'];
        pri = carData['price'];
        ordersList = carData['books'];
        loc =
            LatLng(double.parse(carData['lat']), double.parse(carData['lng']));
        stt = carData['state'];
        isLoading = false;
      });
      await fetchOrders(ordersList);
    } catch (e) {
      // ignore: use_build_context_synchronously
      showSnackBar(context, e.toString());
    }
  }

  Future<void> fetchOrders(List orders) async {
    var orderDetails = [];

    for (String uid in orders) {
      try {
        var userSnap =
            await FirebaseFirestore.instance.collection('users').doc(uid).get();
        orderDetails.add(userSnap.data()!);
      } catch (e) {
        // ignore: use_build_context_synchronously
        showSnackBar(context, e.toString());
      }
    }

    setState(() {
      ordersList = orderDetails;
      isLoading = false;
    });
  }

  Future<void> _openUpdmodDialog(String? carModel) async {
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
              child: Updmod(carModel: carModel)),
        );
      },
    );

    if (result != null) {
      setState(() {
        mod = result['model'];
      });
    }
  }

  Future<void> _openUpdpriDialog(int? pricePerDay) async {
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
                pri: pricePerDay,
              )),
        );
      },
    );

    if (result != null) {
      setState(() {
        pri = int.parse(result['price']);
      });
    }
  }

  Future<void> _openMapDialog(LatLng? selectedLoc) async {
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
                initialLocation: selectedLoc,
              )),
        );
      },
    );

    if (result != null) {
      setState(() {
        loc = result['loc'];
      });
    }
  }

  Future<void> updateCData(String model, int price, String latitude,
      String longitude, bool state) async {
    setState(() {
      isUpdate = true;
    });
    try {
      var userDocRef = FirebaseFirestore.instance
          .collection('cars')
          .doc(FirebaseAuth.instance.currentUser!.uid);
      String imgUrl =
          await StorageMethods().uploadImageToStorage('carsPics', img!, true);
      Map<String, dynamic> newData = {
        'model': model,
        'price': price,
        'carUrl': imgUrl,
        'lat': latitude,
        'lng': longitude,
        'state': state,
      };
      await userDocRef.update(newData);
      setState(() {
        error = "your car details updated.";
        isUpdate = false;
        Future.delayed(const Duration(milliseconds: 1300), () {
          setState(() {
            error = '';
          });
        });
      });
    } catch (e) {
      setState(() {
        error = e.toString();
        isUpdate = false;
      });
    }
  }

  _selectImage(BuildContext parentContext) async {
    Uint8List? file = await pickImage(ImageSource.gallery);
    if (file != null) {
      setState(() {
        img = file;
        car = Image.memory(file, fit: BoxFit.cover);
      });
    }
  }

  void _hide() {
    setState(() {
      isOpressed = false;
      isSpressed = false;
    });
  }

  getData(String id) async {
    setState(() {
      isLoading = true;
    });
    try {
      var userSnap =
          await FirebaseFirestore.instance.collection('users').doc(id).get();

      setState(() {
        uData = userSnap.data()!;
        isLoading = false;
      });
    } catch (e) {
      // ignore: use_build_context_synchronously
      showSnackBar(context, e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget car_ = car ?? widget.car!;
    String mod_ = mod ?? widget.mod!;
    int pri_ = pri ?? widget.pri!;
    ImageProvider<Object> pro_ = pro ?? widget.pro!;
    String nam_ = nam ?? widget.nam!;
    bool stt_ = stt ?? widget.stt!;
    final Uri url = Uri.parse('https://t.me/a7mddra');

    return Scaffold(
      backgroundColor: Colors.white,
      body: InkWell(
          focusColor: Colors.transparent,
          hoverColor: Colors.transparent,
          highlightColor: Colors.transparent,
          splashColor: Colors.transparent,
          overlayColor: WidgetStateColor.transparent,
          mouseCursor: SystemMouseCursors.basic,
          onTap: () {
            _hide();
          },
          child: Stack(children: [
            Column(
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
                              width:
                                  MediaQuery.of(context).size.width * 0.5 - 50,
                              child: ElevatedButton(
                                  onPressed: () {
                                    setState(() {
                                      isSpressed = !isSpressed;
                                      isOpressed = false; // Hide second widget
                                    });
                                  },
                                  style: ElevatedButton.styleFrom(
                                      foregroundColor: Colors.black,
                                      backgroundColor: isSpressed
                                          ? const Color.fromARGB(
                                              255, 240, 240, 240)
                                          : Colors.white,
                                      overlayColor: const Color.fromARGB(
                                          255, 117, 117, 117),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(40),
                                      ),
                                      elevation: 0,
                                      shadowColor: Colors.transparent,
                                      padding: const EdgeInsets.only(left: 0)),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
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
                              width:
                                  MediaQuery.of(context).size.width * 0.5 - 50,
                              child: ElevatedButton(
                                  onPressed: () {
                                    setState(() {
                                      isOpressed = !isOpressed;
                                      isSpressed = false; // Hide second widget
                                    });
                                  },
                                  style: ElevatedButton.styleFrom(
                                    foregroundColor: Colors.black,
                                    backgroundColor: isOpressed
                                        ? const Color.fromARGB(
                                            255, 240, 240, 240)
                                        : Colors.white,
                                    overlayColor: const Color.fromARGB(
                                        255, 117, 117, 117),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(40),
                                    ),
                                    elevation: 0,
                                    shadowColor: Colors.transparent,
                                    padding: const EdgeInsets.only(left: 0),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      ordersList.isEmpty
                                          ? SvgPicture.asset(
                                              'assets/icons/bell.svg',
                                              height: 24.0,
                                              width: 24.0,
                                            )
                                          : SvgPicture.asset(
                                              'assets/icons/belll.svg',
                                              height: 27,
                                              width: 27,
                                            ),
                                      const SizedBox(
                                        width: 8,
                                      ),
                                      const Text(
                                        "Orders",
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
                                width: 55,
                                child: Refresh(
                                  logic: () async {
                                    _hide();
                                    await getUData();
                                    await getCData();
                                  },
                                  isLoading: isLoading,
                                )),
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
                            color: const Color(0xFFF3F3F3),
                            borderRadius: BorderRadius.circular(20)),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            const SizedBox(
                              height: 20,
                            ),
                            Loading(
                              isLoading: isLoading,
                              loadingContent: Container(
                                height: (MediaQuery.of(context).size.height -
                                        (((MediaQuery.of(context).size.width -
                                                        40) *
                                                    0.5 -
                                                10) *
                                            1.125) -
                                        355) *
                                    0.6,
                                width: MediaQuery.of(context).size.width - 80,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(20),
                                  color: Colors.white,
                                ),
                              ),
                              loadedContent: SizedBox(
                                height: (MediaQuery.of(context).size.height -
                                        (((MediaQuery.of(context).size.width -
                                                        40) *
                                                    0.5 -
                                                10) *
                                            1.125) -
                                        355) *
                                    0.6,
                                width: MediaQuery.of(context).size.width - 80,
                                child: Stack(fit: StackFit.expand, children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(20),
                                    child: car_,
                                  ),
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
                                    Loading(
                                      isLoading: isLoading,
                                      loadingContent: Container(
                                        height: 1.3 * 19 + 5,
                                        width:
                                            MediaQuery.of(context).size.width -
                                                80,
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(15),
                                          color: Colors.white,
                                        ),
                                      ),
                                      loadedContent: Row(
                                        children: [
                                          Text('Car Model: $mod_',
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
                                                _openUpdmodDialog(mod);
                                              },
                                              alignment: Alignment.center,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    SizedBox(
                                      height: isLoading ? 10 : 2,
                                    ),
                                    Loading(
                                      isLoading: isLoading,
                                      loadingContent: Container(
                                        height: 1.3 * 19 + 5,
                                        width:
                                            MediaQuery.of(context).size.width -
                                                80,
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(15),
                                          color: Colors.white,
                                        ),
                                      ),
                                      loadedContent: Row(
                                        children: [
                                          Text('Price per Day: $pri_',
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
                                                _openUpdpriDialog(pri);
                                              }, //_openUpdpriDialog,
                                              alignment: Alignment.center,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                              height:
                                  ((MediaQuery.of(context).size.width - 40) *
                                              0.5 -
                                          10) *
                                      1.125,
                              width: (MediaQuery.of(context).size.width - 40) *
                                      0.5 -
                                  10,
                              decoration: BoxDecoration(
                                  color: const Color(0xFFF3F3F3),
                                  borderRadius: BorderRadius.circular(20)),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Loading(
                                    isLoading: isLoading,
                                    loadingContent: const CircleAvatar(
                                      radius: 40,
                                      backgroundColor: Colors.white,
                                    ),
                                    loadedContent: CircleAvatar(
                                      radius: 40,
                                      backgroundImage: pro_,
                                      backgroundColor: const Color.fromARGB(
                                          255, 221, 221, 221),
                                    ),
                                  ),
                                  const SizedBox(height: 20),
                                  Loading(
                                    isLoading: isLoading,
                                    loadingContent: Container(
                                      width: 0.5 *
                                          (((MediaQuery.of(context).size.width -
                                                          40) *
                                                      0.5 -
                                                  10) *
                                              1.125),
                                      height: 19 * 1.3 + 5,
                                      decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius:
                                              BorderRadius.circular(17)),
                                    ),
                                    loadedContent: Text(nam_,
                                        style: const TextStyle(
                                            fontSize: 19,
                                            fontWeight: FontWeight.bold)),
                                  )
                                ],
                              )),
                          const SizedBox(
                            width: 20,
                          ),
                          Stack(children: [
                            Loading(
                              isLoading: isLoading,
                              loadingContent: Container(
                                height:
                                    ((MediaQuery.of(context).size.width - 40) *
                                                0.5 -
                                            10) *
                                        1.125,
                                width:
                                    (MediaQuery.of(context).size.width - 40) *
                                            0.5 -
                                        10,
                                decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(20)),
                              ),
                              loadedContent: Container(
                                height:
                                    ((MediaQuery.of(context).size.width - 40) *
                                                0.5 -
                                            10) *
                                        1.125,
                                width:
                                    (MediaQuery.of(context).size.width - 40) *
                                            0.5 -
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
                            ),
                            SizedBox(
                              height:
                                  ((MediaQuery.of(context).size.width - 40) *
                                              0.5 -
                                          10) *
                                      1.125,
                              width: (MediaQuery.of(context).size.width - 40) *
                                      0.5 -
                                  10,
                              child: ElevatedButton(
                                onPressed: () async {
                                  _openMapDialog(loc);
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
                          ])
                        ],
                      ),
                      const SizedBox(height: 20),
                      Loading(
                        isLoading: isLoading,
                        loadingContent: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              height: 19 * 1.3 + 5,
                              width: MediaQuery.of(context).size.width - 150,
                              decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(15)),
                            ),
                            const SizedBox(
                              width: 50,
                            ),
                            CupertinoSwitch(
                                value: true,
                                onChanged: (bool value) {
                                  setState(() {});
                                }),
                          ],
                        ),
                        loadedContent: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(
                              width: MediaQuery.of(context).size.width - 100,
                              child: const Text("Is your car available now?",
                                  style: TextStyle(
                                      fontSize: 19,
                                      fontWeight: FontWeight.bold)),
                            ),
                            SizedBox(
                              child: CupertinoSwitch(
                                  value: stt_,
                                  onChanged: (bool value) {
                                    setState(() {
                                      stt = value;
                                    });
                                  }),
                            ),
                          ],
                        ),
                      ),
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
                              onPressed: () {
                                updateCData(
                                    mod!,
                                    pri!,
                                    loc!.latitude.toString(),
                                    loc!.longitude.toString(),
                                    stt!);
                              },
                              style: ElevatedButton.styleFrom(
                                  foregroundColor: Colors.white,
                                  backgroundColor: Colors.black,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(14),
                                  )),
                              child: const Text(
                                "Update your car details",
                                style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.normal),
                              )))
                    ]),
              ],
            ),
            if (isOpressed)
              Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Padding(
                    padding: EdgeInsets.only(top: 60),
                    child: SizedBox(
                      height: 63,
                    ),
                  ),
                  Center(
                    child: InkWell(
                      focusColor: Colors.transparent,
                      hoverColor: Colors.transparent,
                      highlightColor: Colors.transparent,
                      splashColor: Colors.transparent,
                      overlayColor: WidgetStateColor.transparent,
                      mouseCursor: SystemMouseCursors.basic,
                      onTap: () {},
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                          child: Container(
                            height: MediaQuery.of(context).size.height - 230,
                            width: MediaQuery.of(context).size.width - 36,
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.8),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: Colors.black.withOpacity(0.3),
                              ),
                            ),
                            child: Column(
                              children: [
                                Expanded(
                                    child: Loading(
                                        isLoading: isLoading,
                                        loadingContent: ListView(children: [
                                          Padding(
                                            padding: const EdgeInsets.only(
                                              top: 10,
                                              right: 30,
                                              left: 30,
                                            ),
                                            child: SizedBox(
                                              height: 60,
                                              width: MediaQuery.of(context)
                                                      .size
                                                      .width -
                                                  36,
                                              child: Row(
                                                children: [
                                                  const CircleAvatar(
                                                    radius: 30,
                                                    backgroundColor:
                                                        Colors.white,
                                                  ),
                                                  const SizedBox(
                                                    width: 15,
                                                  ),
                                                  Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Container(
                                                        height: 15 * 1.3,
                                                        width: 150,
                                                        decoration: BoxDecoration(
                                                            color: Colors.white,
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        14)),
                                                      ),
                                                      const SizedBox(
                                                        height: 15,
                                                      ),
                                                      Container(
                                                        height: 15 * 1.3,
                                                        width: 200,
                                                        decoration: BoxDecoration(
                                                            color: Colors.white,
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        14)),
                                                      )
                                                    ],
                                                  )
                                                ],
                                              ),
                                            ),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.only(
                                              top: 10,
                                              right: 30,
                                              left: 30,
                                            ),
                                            child: SizedBox(
                                              height: 60,
                                              width: MediaQuery.of(context)
                                                      .size
                                                      .width -
                                                  36,
                                              child: Row(
                                                children: [
                                                  const CircleAvatar(
                                                    radius: 30,
                                                    backgroundColor:
                                                        Colors.white,
                                                  ),
                                                  const SizedBox(
                                                    width: 15,
                                                  ),
                                                  Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Container(
                                                        height: 15 * 1.3,
                                                        width: 150,
                                                        decoration: BoxDecoration(
                                                            color: Colors.white,
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        14)),
                                                      ),
                                                      const SizedBox(
                                                        height: 15,
                                                      ),
                                                      Container(
                                                        height: 15 * 1.3,
                                                        width: 200,
                                                        decoration: BoxDecoration(
                                                            color: Colors.white,
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        14)),
                                                      )
                                                    ],
                                                  )
                                                ],
                                              ),
                                            ),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.only(
                                              top: 10,
                                              right: 30,
                                              left: 30,
                                            ),
                                            child: SizedBox(
                                              height: 60,
                                              width: MediaQuery.of(context)
                                                      .size
                                                      .width -
                                                  36,
                                              child: Row(
                                                children: [
                                                  const CircleAvatar(
                                                    radius: 30,
                                                    backgroundColor:
                                                        Colors.white,
                                                  ),
                                                  const SizedBox(
                                                    width: 15,
                                                  ),
                                                  Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Container(
                                                        height: 15 * 1.3,
                                                        width: 150,
                                                        decoration: BoxDecoration(
                                                            color: Colors.white,
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        14)),
                                                      ),
                                                      const SizedBox(
                                                        height: 15,
                                                      ),
                                                      Container(
                                                        height: 15 * 1.3,
                                                        width: 200,
                                                        decoration: BoxDecoration(
                                                            color: Colors.white,
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        14)),
                                                      )
                                                    ],
                                                  )
                                                ],
                                              ),
                                            ),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.only(
                                              top: 10,
                                              right: 30,
                                              left: 30,
                                            ),
                                            child: SizedBox(
                                              height: 60,
                                              width: MediaQuery.of(context)
                                                      .size
                                                      .width -
                                                  36,
                                              child: Row(
                                                children: [
                                                  const CircleAvatar(
                                                    radius: 30,
                                                    backgroundColor:
                                                        Colors.white,
                                                  ),
                                                  const SizedBox(
                                                    width: 15,
                                                  ),
                                                  Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Container(
                                                        height: 15 * 1.3,
                                                        width: 150,
                                                        decoration: BoxDecoration(
                                                            color: Colors.white,
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        14)),
                                                      ),
                                                      const SizedBox(
                                                        height: 15,
                                                      ),
                                                      Container(
                                                        height: 15 * 1.3,
                                                        width: 200,
                                                        decoration: BoxDecoration(
                                                            color: Colors.white,
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        14)),
                                                      )
                                                    ],
                                                  )
                                                ],
                                              ),
                                            ),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.only(
                                              top: 10,
                                              right: 30,
                                              left: 30,
                                            ),
                                            child: SizedBox(
                                              height: 60,
                                              width: MediaQuery.of(context)
                                                      .size
                                                      .width -
                                                  36,
                                              child: Row(
                                                children: [
                                                  const CircleAvatar(
                                                    radius: 30,
                                                    backgroundColor:
                                                        Colors.white,
                                                  ),
                                                  const SizedBox(
                                                    width: 15,
                                                  ),
                                                  Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Container(
                                                        height: 15 * 1.3,
                                                        width: 150,
                                                        decoration: BoxDecoration(
                                                            color: Colors.white,
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        14)),
                                                      ),
                                                      const SizedBox(
                                                        height: 15,
                                                      ),
                                                      Container(
                                                        height: 15 * 1.3,
                                                        width: 200,
                                                        decoration: BoxDecoration(
                                                            color: Colors.white,
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        14)),
                                                      )
                                                    ],
                                                  )
                                                ],
                                              ),
                                            ),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.only(
                                              top: 10,
                                              right: 30,
                                              left: 30,
                                            ),
                                            child: SizedBox(
                                              height: 60,
                                              width: MediaQuery.of(context)
                                                      .size
                                                      .width -
                                                  36,
                                              child: Row(
                                                children: [
                                                  const CircleAvatar(
                                                    radius: 30,
                                                    backgroundColor:
                                                        Colors.white,
                                                  ),
                                                  const SizedBox(
                                                    width: 15,
                                                  ),
                                                  Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Container(
                                                        height: 15 * 1.3,
                                                        width: 150,
                                                        decoration: BoxDecoration(
                                                            color: Colors.white,
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        14)),
                                                      ),
                                                      const SizedBox(
                                                        height: 15,
                                                      ),
                                                      Container(
                                                        height: 15 * 1.3,
                                                        width: 200,
                                                        decoration: BoxDecoration(
                                                            color: Colors.white,
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        14)),
                                                      )
                                                    ],
                                                  )
                                                ],
                                              ),
                                            ),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.only(
                                              top: 10,
                                              right: 30,
                                              left: 30,
                                            ),
                                            child: SizedBox(
                                              height: 60,
                                              width: MediaQuery.of(context)
                                                      .size
                                                      .width -
                                                  36,
                                              child: Row(
                                                children: [
                                                  const CircleAvatar(
                                                    radius: 30,
                                                    backgroundColor:
                                                        Colors.white,
                                                  ),
                                                  const SizedBox(
                                                    width: 15,
                                                  ),
                                                  Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Container(
                                                        height: 15 * 1.3,
                                                        width: 150,
                                                        decoration: BoxDecoration(
                                                            color: Colors.white,
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        14)),
                                                      ),
                                                      const SizedBox(
                                                        height: 15,
                                                      ),
                                                      Container(
                                                        height: 15 * 1.3,
                                                        width: 200,
                                                        decoration: BoxDecoration(
                                                            color: Colors.white,
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        14)),
                                                      )
                                                    ],
                                                  )
                                                ],
                                              ),
                                            ),
                                          ),
                                          const SizedBox(height: 50),
                                        ]),
                                        loadedContent: ordersList.isEmpty
                                            ? Column(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  SizedBox(
                                                    child: Lottie.asset(
                                                      'assets/animations/empty.json',
                                                      height: 250,
                                                      width: 250,
                                                    ),
                                                  ),
                                                  const Text(
                                                    "Looks like you don't have\nany orders yet.",
                                                    style: TextStyle(
                                                      color: Colors.black,
                                                      fontSize: 19,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                    textAlign: TextAlign.center,
                                                  ),
                                                  const SizedBox(height: 50),
                                                ],
                                              )
                                            : ListView.builder(
                                                itemCount: ordersList.length,
                                                itemBuilder: (context, index) {
                                                  var order = ordersList[index];
                                                  return OrderCard(
                                                    img: order['photoUrl'],
                                                    name: order['fullName'],
                                                    email: order['email'],
                                                    uid: order['uid'],
                                                    carId: FirebaseAuth.instance
                                                        .currentUser!.uid,
                                                  );
                                                },
                                              ))),
                                const Align(
                                  alignment: Alignment.bottomCenter,
                                  child: Text("Fivro App © 1.0.0",
                                      style: TextStyle(
                                          color: Color.fromARGB(
                                              255, 172, 172, 172),
                                          fontSize: 17,
                                          fontWeight: FontWeight.normal,
                                          fontFamily: 'be')),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  )
                ],
              ),
            if (isSpressed)
              Padding(
                padding: const EdgeInsets.only(left: 20),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Padding(
                      padding: EdgeInsets.only(top: 60),
                      child: SizedBox(
                        height: 63,
                      ),
                    ),
                    InkWell(
                      focusColor: Colors.transparent,
                      hoverColor: Colors.transparent,
                      highlightColor: Colors.transparent,
                      splashColor: Colors.transparent,
                      overlayColor: WidgetStateColor.transparent,
                      mouseCursor: SystemMouseCursors.basic,
                      onTap: () {},
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                          child: Container(
                            height: (MediaQuery.of(context).size.height -
                                    (((MediaQuery.of(context).size.width - 40) *
                                                0.5 -
                                            10) *
                                        1.125) -
                                    355) *
                                7 /
                                5,
                            width:
                                (MediaQuery.of(context).size.width - 40) * 0.85,
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.8),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: Colors.black.withOpacity(0.3),
                              ),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                const SizedBox(
                                  height: 3,
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(4.0),
                                  child: SizedBox(
                                    height: 55,
                                    child: ElevatedButton(
                                      onPressed: () {
                                        Navigator.of(context).push(
                                            MaterialPageRoute(
                                                builder: (context) =>
                                                    const Profile()));
                                        _hide();
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.transparent,
                                        shadowColor: Colors.transparent,
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(14),
                                        ),
                                        padding:
                                            const EdgeInsets.only(left: 10),
                                      ),
                                      child: const Row(children: [
                                        Icon(
                                          Icons.account_circle_rounded,
                                          color:
                                              Color.fromARGB(255, 92, 92, 92),
                                          size: 30,
                                        ),
                                        SizedBox(
                                          width: 15,
                                        ),
                                        Text("Profile Settings",
                                            style: TextStyle(
                                              color: Colors.black,
                                              fontSize: 19,
                                              fontWeight: FontWeight.bold,
                                            ))
                                      ]),
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(4.0),
                                  child: SizedBox(
                                    height: 55,
                                    child: ElevatedButton(
                                      onPressed: () {
                                        setState(() {
                                          mode = !mode;
                                        });
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.transparent,
                                        shadowColor: Colors.transparent,
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(14),
                                        ),
                                        padding:
                                            const EdgeInsets.only(left: 10),
                                      ),
                                      child: Row(children: [
                                        const Icon(
                                          Icons.dark_mode_sharp,
                                          color:
                                              Color.fromARGB(255, 92, 92, 92),
                                          size: 30,
                                        ),
                                        const SizedBox(
                                          width: 15,
                                        ),
                                        const Text("Dark mode",
                                            style: TextStyle(
                                              color: Colors.black,
                                              fontSize: 19,
                                              fontWeight: FontWeight.bold,
                                            )),
                                        const SizedBox(
                                          width: 60,
                                        ),
                                        Switch(
                                            value: mode,
                                            onChanged: (bool value) {
                                              setState(() {
                                                mode = !mode;
                                              });
                                            })
                                      ]),
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(4.0),
                                  child: SizedBox(
                                    height: 55,
                                    child: ElevatedButton(
                                      onPressed: () async {
                                        await launchUrl(url);
                                        _hide();
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.transparent,
                                        shadowColor: Colors.transparent,
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(14),
                                        ),
                                        padding:
                                            const EdgeInsets.only(left: 10),
                                      ),
                                      child: const Row(children: [
                                        Icon(
                                          Icons.help_rounded,
                                          color:
                                              Color.fromARGB(255, 92, 92, 92),
                                          size: 30,
                                        ),
                                        SizedBox(
                                          width: 15,
                                        ),
                                        Text("Help & Support",
                                            style: TextStyle(
                                              color: Colors.black,
                                              fontSize: 19,
                                              fontWeight: FontWeight.bold,
                                            ))
                                      ]),
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(4.0),
                                  child: SizedBox(
                                    height: 55,
                                    child: ElevatedButton(
                                      onPressed: () async {
                                        await launchUrl(url);
                                        _hide();
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.transparent,
                                        shadowColor: Colors.transparent,
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(14),
                                        ),
                                        padding:
                                            const EdgeInsets.only(left: 10),
                                      ),
                                      child: const Row(children: [
                                        Icon(
                                          Icons.bug_report_sharp,
                                          color:
                                              Color.fromARGB(255, 92, 92, 92),
                                          size: 30,
                                        ),
                                        SizedBox(
                                          width: 15,
                                        ),
                                        Text("Report a bug",
                                            style: TextStyle(
                                              color: Colors.black,
                                              fontSize: 19,
                                              fontWeight: FontWeight.bold,
                                            ))
                                      ]),
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(4.0),
                                  child: SizedBox(
                                    height: 55,
                                    child: ElevatedButton(
                                      onPressed: () {
                                        Navigator.of(context).push(
                                            MaterialPageRoute(
                                                builder: (context) =>
                                                    const About()));
                                        _hide();
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: const Color.fromARGB(
                                            0, 116, 51, 51),
                                        shadowColor: Colors.transparent,
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(14),
                                        ),
                                        padding:
                                            const EdgeInsets.only(left: 10),
                                      ),
                                      child: const Row(children: [
                                        Icon(
                                          Icons.info_rounded,
                                          color:
                                              Color.fromARGB(255, 92, 92, 92),
                                          size: 30,
                                        ),
                                        SizedBox(
                                          width: 15,
                                        ),
                                        Text("about developer",
                                            style: TextStyle(
                                              color: Colors.black,
                                              fontSize: 19,
                                              fontWeight: FontWeight.bold,
                                            ))
                                      ]),
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(4.0),
                                  child: SizedBox(
                                    height: 55,
                                    child: ElevatedButton(
                                      onPressed: () async {
                                        await AuthMethods().signOut();
                                        _hide();
                                        // ignore: use_build_context_synchronously
                                        Navigator.of(context)
                                            .pushReplacement(MaterialPageRoute(
                                          builder: (context) => const Login(),
                                        ));
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.transparent,
                                        shadowColor: Colors.transparent,
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(14),
                                        ),
                                        padding:
                                            const EdgeInsets.only(left: 10),
                                      ),
                                      child: const Row(children: [
                                        Icon(
                                          Icons.logout,
                                          color: Colors.red,
                                          size: 30,
                                        ),
                                        SizedBox(
                                          width: 15,
                                        ),
                                        Text("Logout",
                                            style: TextStyle(
                                              color: Colors.red,
                                              fontSize: 19,
                                              fontWeight: FontWeight.bold,
                                            ))
                                      ]),
                                    ),
                                  ),
                                ),
                                const SizedBox(
                                  height: 4,
                                ),
                                const Center(
                                  child: Text("Fivro App © 1.0.0",
                                      style: TextStyle(
                                          color: Color.fromARGB(
                                              255, 190, 190, 190),
                                          fontSize: 17,
                                          fontWeight: FontWeight.normal,
                                          fontFamily: 'be')),
                                )
                              ],
                            ),
                          ),
                        ),
                      ),
                    )
                  ],
                ),
              ),
          ])),
    );
  }
}
