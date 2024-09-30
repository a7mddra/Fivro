import 'dart:typed_data';
import 'dart:ui';
import 'package:car_rental_a7md/widgets/shimmer.dart';
import 'package:car_rental_a7md/renter/homee.dart';
import 'package:car_rental_a7md/resources/auth_methods.dart';
import 'package:car_rental_a7md/resources/firestore_methods.dart';
import 'package:car_rental_a7md/utils/utils.dart';
import 'package:car_rental_a7md/views/about.dart';
import 'package:car_rental_a7md/views/login.dart';
import 'package:car_rental_a7md/views/profile.dart';
import 'package:car_rental_a7md/widgets/form.dart';
import 'package:car_rental_a7md/widgets/map.dart';
import 'package:car_rental_a7md/widgets/refresh.dart';
import 'package:car_rental_a7md/widgets/updmod.dart';
import 'package:car_rental_a7md/widgets/updpri.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:image_picker/image_picker.dart';
import 'package:latlong2/latlong.dart';
import 'package:location/location.dart';
import 'package:lottie/lottie.dart';
import 'package:url_launcher/url_launcher.dart';

class Home2 extends StatefulWidget {
  const Home2({super.key});

  @override
  State<Home2> createState() => _Home2State();
}

class _Home2State extends State<Home2> with TickerProviderStateMixin {
  bool isLoading = false;
  bool isAvailable = false;
  bool isOpressed = false;
  bool isSpressed = false;
  bool isPost = false;
  bool mode = false;
  var userData = {};
  String error = '';
  AnimationController? _controller1;
  Animation<double>? _animation1;
  String carModel = '';
  int pricePerDay = 0;
  String profUrl = '';
  String uName = '';
  Uint8List? imageFile;
  LatLng? currLoc;
  LatLng? _selectedLoc;
  User currentUser = FirebaseAuth.instance.currentUser!;

  @override
  void initState() {
    _controller1 =
        AnimationController(duration: const Duration(seconds: 4), vsync: this);
    _animation1 = Tween<double>(begin: 1.8, end: 1).animate(_controller1!)
      ..addListener(() {
        setState(() {});
      });
    _controller1!.forward();
    super.initState();
    getData();
  }

  @override
  void dispose() {
    super.dispose();
    _controller1!.forward();
  }

  Future<void> _getLocation() async {
    try {
      LocationData locationData = await Location().getLocation();
      currLoc = LatLng(locationData.latitude!, locationData.longitude!);
      setState(() {});
    } on Exception {
      currLoc = null;
    }
  }

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
                initialLocation: _selectedLoc ?? currLoc,
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

  Future<void> _openFormDialog() async {
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
              child: const FormWidget()),
        );
      },
    );

    if (result != null) {
      setState(() {
        carModel = result['model'];
        pricePerDay = result['price'];
        imageFile = result['file'];
      });
    }
  }

  Future<void> _openUpdmodDialog() async {
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
        carModel = result['model'];
      });
    }
  }

  Future<void> _openUpdpriDialog() async {
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
        pricePerDay = result['price'];
      });
    }
  }

Future<void> getData() async {
  setState(() {
    isLoading = true;
  });

  try {
    User? user = FirebaseAuth.instance.currentUser;

    // Ensure that the user is logged in
    if (user == null) {
      setState(() {
        isLoading = false;
      });
      showSnackBar(context, 'User not authenticated');
      return;
    }

    var userSnap = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .get();

    // Check if user data exists
    if (!userSnap.exists) {
      setState(() {
        isLoading = false;
      });
      showSnackBar(context, 'User data not found');
      return;
    }

    setState(() {
      userData = userSnap.data()!;
      profUrl = userData['photoUrl'];
      uName = userData['fullName'];
    });
    
  } catch (e) {
    showSnackBar(context, 'Error fetching user data: ${e.toString()}');
  } finally {
    setState(() {
      isLoading = false;
    });
  }
}


  _selectImage(BuildContext parentContext) async {
    Uint8List? file = await pickImage(ImageSource.gallery);
    if (file != null) {
      setState(() {
        imageFile = file;
      });
    }
  }

  void post(String uid) async {
    setState(() {
      isPost = true;
    });

    if (carModel == '' || pricePerDay == 0 || imageFile == null) {
      setState(() {
        error = 'Please enter all required fields.';
        isPost = false;
      });
      return;
    } else if (profUrl == '' || uName == '') {
      setState(() {
        error = 'An Error has occurred :/';
        isPost = false;
      });
      return;
    }

    if (carModel != '' &&
        pricePerDay != 0 &&
        imageFile != null &&
        _selectedLoc == null) {
      setState(() {
        error = 'Please pick your car location.';
        isPost = false;
      });
      return;
    }

    try {
      FirestoreMethods firestoreMethods = FirestoreMethods();
      String res = await firestoreMethods.upload(
          carModel,
          pricePerDay,
          uid,
          imageFile!,
          "${_selectedLoc!.latitude}",
          "${_selectedLoc!.longitude}",
          isAvailable,
          profUrl,
          uName);
      if (res == "Success") {
        setState(() {
          isPost = false;
        });
        if (context.mounted) {
          showSnackBar(
            // ignore: use_build_context_synchronously
            context,
            "Your car has been listed successfully!\nKeep an eye on your orders for incoming orders from rentees.",
          );
        }
        Navigator.pushReplacement(
          // ignore: use_build_context_synchronously
          context,
          PageRouteBuilder(
            pageBuilder: (context, _, __) => Home(
              car: Image.memory(
                imageFile!,
                fit: BoxFit.cover,
              ),
              img: imageFile!,
              mod: carModel,
              pri: pricePerDay,
              pro: userData['photoUrl'] != null
                  ? NetworkImage(userData['photoUrl'])
                  : null,
              nam: userData['fullName'] != '' ? userData['fullName'] : '',
              loc: _selectedLoc ?? currLoc,
              stt: isAvailable,
            ),
            transitionDuration: Duration.zero,
            reverseTransitionDuration: Duration.zero,
          ),
        );
      } else {
        setState(() {
          isPost = false;
        });
        if (context.mounted) {
          // ignore: use_build_context_synchronously
          showSnackBar(context, res);
        }
      }
    } catch (err) {
      setState(() {
        isPost = false;
      });
      showSnackBar(
        // ignore: use_build_context_synchronously
        context,
        err.toString(),
      );
    }
  }

  void _hide() {
    setState(() {
      isOpressed = false;
      isSpressed = false;
    });
  }

  @override
  Widget build(BuildContext context) {
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
                        width: MediaQuery.of(context).size.width * 0.5 - 50,
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
                                    ? const Color.fromARGB(255, 240, 240, 240)
                                    : Colors.white,
                                overlayColor:
                                    const Color.fromARGB(255, 117, 117, 117),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(40),
                                ),
                                elevation: 0,
                                shadowColor: Colors.transparent,
                                padding: const EdgeInsets.only(left: 0)),
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
                        width: MediaQuery.of(context).size.width * 0.5 - 50,
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
                                  ? const Color.fromARGB(255, 240, 240, 240)
                                  : Colors.white,
                              overlayColor:
                                  const Color.fromARGB(255, 117, 117, 117),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(40),
                              ),
                              elevation: 0,
                              shadowColor: Colors.transparent,
                              padding: const EdgeInsets.only(left: 0),
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
                              await getData();
                            },
                            isLoading: isLoading,
                          )),
                    ],
                  ),
                ),
                const SizedBox(
                  height: 8,
                ),
                Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
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
                          child: carModel != ''
                              ? Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    const SizedBox(
                                      height: 20,
                                    ),
                                    SizedBox(
                                      height:
                                          (MediaQuery.of(context).size.height -
                                                  (((MediaQuery.of(context)
                                                                      .size
                                                                      .width -
                                                                  40) *
                                                              0.5 -
                                                          10) *
                                                      1.125) -
                                                  355) *
                                              0.6,
                                      width: MediaQuery.of(context).size.width -
                                          80,
                                      child: Stack(
                                          fit: StackFit.expand,
                                          children: [
                                            ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(20),
                                              child: Image.memory(
                                                imageFile!,
                                                fit: BoxFit.cover,
                                              ),
                                            ),
                                            Padding(
                                              padding:
                                                  const EdgeInsets.all(8.0),
                                              child: Align(
                                                alignment: Alignment.topRight,
                                                child: CircleAvatar(
                                                  backgroundColor:
                                                      const Color.fromARGB(
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
                                                      _hide();
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
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              children: [
                                                Text('Car Model: $carModel',
                                                    style: const TextStyle(
                                                        fontSize: 19,
                                                        fontWeight:
                                                            FontWeight.bold)),
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
                                                    onPressed:
                                                        _openUpdmodDialog,
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
                                                    'Price per Day: $pricePerDay',
                                                    style: const TextStyle(
                                                        fontSize: 19,
                                                        fontWeight:
                                                            FontWeight.bold)),
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
                                                    onPressed:
                                                        _openUpdpriDialog,
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
                                )
                              : ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    foregroundColor: Colors.transparent,
                                    backgroundColor: Colors.transparent,
                                    shadowColor: Colors.transparent,
                                    overlayColor: Colors.transparent,
                                  ),
                                  onPressed: () {
                                    _openFormDialog();
                                    _hide();
                                  },
                                  child: const Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.add_circle_outline,
                                        size: 50,
                                        color: Colors.black,
                                      ),
                                      SizedBox(
                                        height: 8,
                                      ),
                                      Text(
                                        "Add A Car",
                                        style: TextStyle(
                                          color: Colors.black,
                                          fontSize: 19,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      )
                                    ],
                                  ),
                                )),
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
                                      backgroundImage: userData['photoUrl'] !=
                                              null
                                          ? NetworkImage(userData['photoUrl'])
                                          : null,
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
                                    loadedContent: Text(
                                        isLoading ? '' : userData['fullName'],
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
                                  child: userData['photoUrl'] != null
                                      ? Transform.scale(
                                          scale: _animation1!.value,
                                          alignment: Alignment.center,
                                          child: Image.asset(
                                            'assets/images/maps.png',
                                            fit: BoxFit.cover,
                                          ),
                                        )
                                      : null,
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
                                  if (_selectedLoc == null) {
                                    await _getLocation();
                                  }
                                  _openMapDialog();
                                  _hide();
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
                      Row(
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
                                value: isAvailable,
                                onChanged: (bool value) {
                                  setState(() {
                                    isAvailable = value;
                                  });
                                  _hide();
                                }),
                          ),
                        ],
                      ),
                      SizedBox(
                        height: 75,
                        child: isPost
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
                                post(currentUser.uid);
                                _hide();
                              },
                              style: ElevatedButton.styleFrom(
                                  foregroundColor: Colors.white,
                                  backgroundColor: Colors.black,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(14),
                                  )),
                              child: const Text(
                                "List your car",
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
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
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
                                          fontWeight: FontWeight.bold,
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                      const SizedBox(height: 50),
                                    ],
                                  ),
                                ),
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
