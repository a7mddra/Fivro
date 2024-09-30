import 'package:car_rental_a7md/rentee/car_card.dart';
import 'package:car_rental_a7md/resources/auth_methods.dart';
import 'package:car_rental_a7md/utils/distance.dart';
import 'package:car_rental_a7md/utils/utils.dart';
import 'package:car_rental_a7md/views/about.dart';
import 'package:car_rental_a7md/views/login.dart';
import 'package:car_rental_a7md/views/profile.dart';
import 'package:car_rental_a7md/widgets/refresh.dart';
import 'package:car_rental_a7md/widgets/shimmer.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:latlong2/latlong.dart';
import 'package:location/location.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:ui';

class Home1 extends StatefulWidget {
  const Home1({super.key});

  @override
  State<Home1> createState() => _Home1State();
}

class _Home1State extends State<Home1> with TickerProviderStateMixin {
  LatLng currLoc = const LatLng(0, 0);
  bool isLoading = false;
  bool sort = false;
  bool settings = false;
  bool mode = false;
  bool sor1 = false;
  bool sor2 = true;
  bool sor3 = false;
  List<Map<String, dynamic>> carsList = [];
  var userData = {};

  @override
  void initState() {
    super.initState();
    getLoc();
    getCData();
    getUData();
  }

  void _hide() {
    setState(() {
      sort = false;
      settings = false;
    });
  }

  Future<void> getLoc() async {
    try {
      LocationData locationData = await Location().getLocation();
      setState(() {
        currLoc = LatLng(locationData.latitude!, locationData.longitude!);
      });
    } on Exception {
      currLoc = const LatLng(0, 0);
    }
  }

  Future<void> getCData() async {
    setState(() {
      isLoading = true;
    });

    try {
      QuerySnapshot snapshot =
          await FirebaseFirestore.instance.collection('cars').get();

      carsList = snapshot.docs
          .map((doc) => doc.data() as Map<String, dynamic>)
          .toList();
      if (sor1) {
        carsList.sort((a, b) {
          int distA = calcDist(currLoc.latitude, currLoc.longitude,
                  double.parse(a['lat']), double.parse(a['lng']))
              .toInt();
          int distB = calcDist(currLoc.latitude, currLoc.longitude,
                  double.parse(b['lat']), double.parse(b['lng']))
              .toInt();
          return distA.compareTo(distB);
        });
      } else if (sor2) {
        carsList.sort((a, b) {
          DateTime dateA = a['date'].toDate();
          DateTime dateB = b['date'].toDate();
          return dateB.compareTo(dateA);
        });
      } else {
        carsList.sort((a, b) {
          int priceA = a['price'];
          int priceB = b['price'];
          return priceA.compareTo(priceB);
        });
      }

      setState(() {
        isLoading = false;
      });
    } catch (e) {
      // ignore: use_build_context_synchronously
      showSnackBar(context, 'Error: $e');
    }
  }

  Future<void> getUData() async {
    setState(() {
      isLoading = true;
    });

    try {
      var userSnap = await FirebaseFirestore.instance
          .collection('users')
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .get();

      setState(() {
        userData = userSnap.data()!;
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
            Padding(
              padding: const EdgeInsets.only(top: 80),
              child: (isLoading || carsList.isEmpty)
                  ? ListView(children: [
                      Container(
                          height: MediaQuery.of(context).size.width - 30,
                          width: MediaQuery.of(context).size.width - 40,
                          margin: const EdgeInsets.only(
                              left: 20, right: 20, top: 10),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: Loading(
                              isLoading: true,
                              loadedContent: Container(),
                              loadingContent: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const SizedBox(height: 10),
                                  Stack(
                                    children: [
                                      Row(
                                        children: [
                                          const SizedBox(width: 10),
                                          const CircleAvatar(
                                              radius: 20,
                                              backgroundColor: Colors.white),
                                          const SizedBox(width: 10),
                                          Container(
                                              width: 90,
                                              height: 20,
                                              decoration: BoxDecoration(
                                                color: Colors.white,
                                                borderRadius:
                                                    BorderRadius.circular(13),
                                              )),
                                        ],
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.only(top: 6),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.end,
                                          children: [
                                            Container(
                                                height: 20 * 1.3,
                                                width: 120,
                                                decoration: BoxDecoration(
                                                  color: Colors.white,
                                                  borderRadius:
                                                      BorderRadius.circular(13),
                                                )),
                                            const SizedBox(width: 10),
                                          ],
                                        ),
                                      )
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Center(
                                    child: Container(
                                      height:
                                          (MediaQuery.of(context).size.width -
                                                  80) *
                                              2 /
                                              3.1,
                                      width: MediaQuery.of(context).size.width -
                                          60,
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(15),
                                      ),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(10),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        const SizedBox(height: 5),
                                        Row(
                                          children: [
                                            Container(
                                                width: 70,
                                                height: 30,
                                                decoration: BoxDecoration(
                                                  color: Colors.white,
                                                  borderRadius:
                                                      BorderRadius.circular(13),
                                                )),
                                            const SizedBox(width: 8),
                                            Container(
                                              width: 30,
                                              height: 25,
                                              decoration: const BoxDecoration(
                                                color: Colors.white,
                                                shape: BoxShape.circle,
                                              ),
                                            ),
                                            const SizedBox(width: 8),
                                            Container(
                                                width: 65,
                                                height: 20,
                                                decoration: BoxDecoration(
                                                  color: Colors.white,
                                                  borderRadius:
                                                      BorderRadius.circular(13),
                                                )),
                                          ],
                                        ),
                                        const SizedBox(height: 13),
                                        Stack(
                                          children: [
                                            Container(
                                                width: 100,
                                                height: 22,
                                                decoration: BoxDecoration(
                                                  color: Colors.white,
                                                  borderRadius:
                                                      BorderRadius.circular(13),
                                                )),
                                            Column(
                                              children: [
                                                const SizedBox(height: 3),
                                                Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.end,
                                                  children: [
                                                    Container(
                                                        width: 85,
                                                        height: 18,
                                                        decoration:
                                                            BoxDecoration(
                                                          color: Colors.white,
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(13),
                                                        )),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ))),
                      Container(
                          height: MediaQuery.of(context).size.width - 10,
                          width: MediaQuery.of(context).size.width - 40,
                          margin: const EdgeInsets.only(
                              left: 20, right: 20, top: 10),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: Loading(
                              isLoading: true,
                              loadedContent: Container(),
                              loadingContent: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const SizedBox(height: 10),
                                  Stack(
                                    children: [
                                      Row(
                                        children: [
                                          const SizedBox(width: 10),
                                          const CircleAvatar(
                                              radius: 20,
                                              backgroundColor: Colors.white),
                                          const SizedBox(width: 10),
                                          Container(
                                              width: 90,
                                              height: 20,
                                              decoration: BoxDecoration(
                                                color: Colors.white,
                                                borderRadius:
                                                    BorderRadius.circular(13),
                                              )),
                                        ],
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.only(top: 6),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.end,
                                          children: [
                                            Container(
                                                height: 20 * 1.3,
                                                width: 120,
                                                decoration: BoxDecoration(
                                                  color: Colors.white,
                                                  borderRadius:
                                                      BorderRadius.circular(13),
                                                )),
                                            const SizedBox(width: 10),
                                          ],
                                        ),
                                      )
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Center(
                                    child: Container(
                                      height:
                                          (MediaQuery.of(context).size.width -
                                                  80) *
                                              2 /
                                              3.1,
                                      width: MediaQuery.of(context).size.width -
                                          60,
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(15),
                                      ),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(10),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        const SizedBox(height: 5),
                                        Row(
                                          children: [
                                            Container(
                                                width: 70,
                                                height: 30,
                                                decoration: BoxDecoration(
                                                  color: Colors.white,
                                                  borderRadius:
                                                      BorderRadius.circular(13),
                                                )),
                                            const SizedBox(width: 8),
                                            Container(
                                              width: 30,
                                              height: 25,
                                              decoration: const BoxDecoration(
                                                color: Colors.white,
                                                shape: BoxShape.circle,
                                              ),
                                            ),
                                            const SizedBox(width: 8),
                                            Container(
                                                width: 65,
                                                height: 20,
                                                decoration: BoxDecoration(
                                                  color: Colors.white,
                                                  borderRadius:
                                                      BorderRadius.circular(13),
                                                )),
                                          ],
                                        ),
                                        const SizedBox(height: 13),
                                        Stack(
                                          children: [
                                            Container(
                                                width: 100,
                                                height: 22,
                                                decoration: BoxDecoration(
                                                  color: Colors.white,
                                                  borderRadius:
                                                      BorderRadius.circular(13),
                                                )),
                                            Column(
                                              children: [
                                                const SizedBox(height: 3),
                                                Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.end,
                                                  children: [
                                                    Container(
                                                        width: 85,
                                                        height: 18,
                                                        decoration:
                                                            BoxDecoration(
                                                          color: Colors.white,
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(13),
                                                        )),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ))),
                      Container(
                          height: MediaQuery.of(context).size.width - 10,
                          width: MediaQuery.of(context).size.width - 40,
                          margin: const EdgeInsets.only(
                              left: 20, right: 20, top: 10),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: Loading(
                              isLoading: true,
                              loadedContent: Container(),
                              loadingContent: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const SizedBox(height: 10),
                                  Stack(
                                    children: [
                                      Row(
                                        children: [
                                          const SizedBox(width: 10),
                                          const CircleAvatar(
                                              radius: 20,
                                              backgroundColor: Colors.white),
                                          const SizedBox(width: 10),
                                          Container(
                                              width: 90,
                                              height: 20,
                                              decoration: BoxDecoration(
                                                color: Colors.white,
                                                borderRadius:
                                                    BorderRadius.circular(13),
                                              )),
                                        ],
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.only(top: 6),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.end,
                                          children: [
                                            Container(
                                                height: 20 * 1.3,
                                                width: 120,
                                                decoration: BoxDecoration(
                                                  color: Colors.white,
                                                  borderRadius:
                                                      BorderRadius.circular(13),
                                                )),
                                            const SizedBox(width: 10),
                                          ],
                                        ),
                                      )
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Center(
                                    child: Container(
                                      height:
                                          (MediaQuery.of(context).size.width -
                                                  80) *
                                              2 /
                                              3.1,
                                      width: MediaQuery.of(context).size.width -
                                          60,
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(15),
                                      ),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(10),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        const SizedBox(height: 5),
                                        Row(
                                          children: [
                                            Container(
                                                width: 70,
                                                height: 30,
                                                decoration: BoxDecoration(
                                                  color: Colors.white,
                                                  borderRadius:
                                                      BorderRadius.circular(13),
                                                )),
                                            const SizedBox(width: 8),
                                            Container(
                                              width: 30,
                                              height: 25,
                                              decoration: const BoxDecoration(
                                                color: Colors.white,
                                                shape: BoxShape.circle,
                                              ),
                                            ),
                                            const SizedBox(width: 8),
                                            Container(
                                                width: 65,
                                                height: 20,
                                                decoration: BoxDecoration(
                                                  color: Colors.white,
                                                  borderRadius:
                                                      BorderRadius.circular(13),
                                                )),
                                          ],
                                        ),
                                        const SizedBox(height: 13),
                                        Stack(
                                          children: [
                                            Container(
                                                width: 100,
                                                height: 22,
                                                decoration: BoxDecoration(
                                                  color: Colors.white,
                                                  borderRadius:
                                                      BorderRadius.circular(13),
                                                )),
                                            Column(
                                              children: [
                                                const SizedBox(height: 3),
                                                Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.end,
                                                  children: [
                                                    Container(
                                                        width: 85,
                                                        height: 18,
                                                        decoration:
                                                            BoxDecoration(
                                                          color: Colors.white,
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(13),
                                                        )),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ))),
                    ])
                  : ListView.builder(
                      itemCount: carsList.length,
                      itemBuilder: (context, index) {
                        int dist = calcDist(
                                currLoc.latitude,
                                currLoc.longitude,
                                double.parse(carsList[index]['lat']),
                                double.parse(carsList[index]['lng']))
                            .toInt();
                        String date = DateFormat.yMMMd()
                            .format(carsList[index]['date'].toDate());

                        var carData = carsList[index];

                        return CarCard(
                          model: carData['model'],
                          price: carData['price'],
                          dist: dist,
                          loc1: currLoc,
                          loc2: LatLng(double.parse(carData['lat']),
                              double.parse(carData['lng'])),
                          imageUrl: carData['carUrl'],
                          profUrl: carData['profUrl'],
                          uName: carData['uName'],
                          date: date,
                          id: carData['uid'],
                          books: carData['books'],
                          uid: userData['uid'],
                          state: carData['state'],
                        );
                      },
                    ),
            ),
            Column(
              children: [
                Container(
                  height: MediaQuery.of(context).size.height * 2.1 / 14.5,
                  width: MediaQuery.of(context).size.width,
                  color: Colors.white,
                )
              ],
            ),
            Column(
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
                                settings = !settings;
                                sort = false; // Hide second widget
                              });
                            },
                            style: ElevatedButton.styleFrom(
                                foregroundColor: Colors.black,
                                backgroundColor: settings
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
                                sort = !sort;
                                settings = false;
                              });
                            },
                            style: ElevatedButton.styleFrom(
                              foregroundColor: Colors.black,
                              backgroundColor: sort
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
                            child: const Row(
                              children: [
                                SizedBox(
                                  width: 20,
                                ),
                                Icon(
                                  Icons.sort,
                                  color: Colors.black,
                                  size: 30,
                                ),
                                SizedBox(
                                  width: 8,
                                ),
                                Text(
                                  "Sort",
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
                              await getLoc();
                              await getCData();
                            },
                            isLoading: isLoading,
                          )),
                    ],
                  ),
                ),
              ],
            ),
            if (sort)
              Positioned(
                right: 20,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.end,
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
                            height: ((MediaQuery.of(context).size.height -
                                        (((MediaQuery.of(context).size.width -
                                                        40) *
                                                    0.5 -
                                                10) *
                                            1.125) -
                                        355) *
                                    7 /
                                    5) *
                                0.55,
                            width:
                                (MediaQuery.of(context).size.width - 40) * 0.65,
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
                                      onPressed: () async {
                                        setState(() {
                                          sor1 = true;
                                          sor2 = false;
                                          sor3 = false;
                                        });
                                        await getLoc();
                                        await getCData();
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: sor1
                                            ? const Color.fromARGB(30, 0, 0, 0)
                                            : Colors.transparent,
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
                                          Icons.near_me,
                                          color:
                                              Color.fromARGB(255, 92, 92, 92),
                                          size: 30,
                                        ),
                                        SizedBox(
                                          width: 10,
                                        ),
                                        Text("Nearest",
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
                                        setState(() {
                                          sor1 = false;
                                          sor2 = true;
                                          sor3 = false;
                                        });
                                        await getLoc();
                                        await getCData();
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: sor2
                                            ? const Color.fromARGB(30, 0, 0, 0)
                                            : Colors.transparent,
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
                                          FontAwesomeIcons.clock,
                                          color:
                                              Color.fromARGB(255, 92, 92, 92),
                                          size: 25,
                                        ),
                                        SizedBox(
                                          width: 15,
                                        ),
                                        Text("Newest",
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
                                        setState(() {
                                          sor1 = false;
                                          sor2 = false;
                                          sor3 = true;
                                        });
                                        await getLoc();
                                        await getCData();
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: sor3
                                            ? const Color.fromARGB(30, 0, 0, 0)
                                            : Colors.transparent,
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
                                          FontAwesomeIcons.creditCard,
                                          color:
                                              Color.fromARGB(255, 92, 92, 92),
                                          size: 25,
                                        ),
                                        SizedBox(
                                          width: 15,
                                        ),
                                        Text("Cheapest",
                                            style: TextStyle(
                                              color: Colors.black,
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
            if (settings)
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
