// ignore_for_file: use_build_context_synchronously

import 'package:car_rental_a7md/utils/utils.dart';
import 'package:car_rental_a7md/widgets/shimmer.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:ui';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class Book extends StatefulWidget {
  final String model;
  final int price;
  final String imageUrl;
  final String profUrl;
  final String uName;
  final LatLng loc1;
  final LatLng loc2;
  final int dist;
  final String id;
  final String uid;

  const Book(
      {super.key,
      required this.model,
      required this.price,
      required this.imageUrl,
      required this.profUrl,
      required this.uName,
      required this.loc1,
      required this.loc2,
      required this.dist,
      required this.id,
      required this.uid});

  @override
  State<Book> createState() => _BookState();
}

class _BookState extends State<Book> {
  List<LatLng> routePoints = [];
  List<Marker> markers = [];
  final String orsApiKey =
      "5b3ce3597851110001cf6248ee8d201ffe224151b349c5a03a61edad";
  bool isLoading = false;
  bool iisLoading = false;
  int isBooked = 2;
  var carData = {};
  List books = [];

  @override
  void initState() {
    super.initState();
    markers.add(Marker(
        point: widget.loc1,
        child: const Icon(
          Icons.location_on,
          color: Colors.red,
          size: 40,
        )));
    _getRoute();
    initCData();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    initCData();
  }

  Future<void> _getRoute() async {
    setState(() {
      isLoading = true;
    });
    final start = widget.loc1;
    final destination = widget.loc2;
    final response = await http.get(
      Uri.parse(
          'https://api.openrouteservice.org/v2/directions/driving-car?api_key=$orsApiKey&start=${start.longitude},${start.latitude}&end=${destination.longitude},${destination.latitude}'),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final List<dynamic> coords =
          data['features'][0]['geometry']['coordinates'];
      setState(() {
        routePoints =
            coords.map((coord) => LatLng(coord[1], coord[0])).toList();
        markers.add(
          Marker(
            width: 80.0,
            height: 80.0,
            point: destination,
            child: const Icon(Icons.location_on, color: Colors.red, size: 40.0),
          ),
        );
      });
    }
  }

  initCData() async {
    try {
      setState(() {
        isLoading = true;
      });
      var carSnap = await FirebaseFirestore.instance
          .collection('cars')
          .doc(widget.id)
          .get();

      if (carSnap.exists && carSnap.data() != null) {
        carData = carSnap.data()!;
        setState(() {
          books = carData['books'];
          isBooked = carData['books'].contains(widget.uid) ? 1 : 0;
        });
      } else {
        showSnackBar(context, 'No data found for this car.');
      }
    } catch (e) {
      showSnackBar(context, e.toString());
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<String> _book(String carId, String uid) async {
    String res = "An Error has occurred :/";
    try {
      if (isBooked == 1) {
        FirebaseFirestore.instance.collection('cars').doc(carId).update({
          'books': FieldValue.arrayRemove([uid])
        });
        setState(() {
          isBooked = 0;
        });
      } else {
        FirebaseFirestore.instance.collection('cars').doc(carId).update({
          'books': FieldValue.arrayUnion([uid])
        });
        setState(() {
          isBooked = 1;
        });
      }
      res = 'success';
    } catch (err) {
      res = err.toString();
    }
    return res;
  }

  @override
  Widget build(BuildContext context) {
    if (isBooked == 2) {
      setState(() {
        isLoading = true;
      });
    }
    if (routePoints != [] && isBooked != 2 && carData != {}) {
      setState(() {
        isLoading = false;
      });
    }
    return Scaffold(
        backgroundColor: Colors.white,
        body: SizedBox(
            height: double.infinity,
            width: double.infinity,
            child: Column(children: [
              Stack(alignment: Alignment.topCenter, children: [
                Loading(
                  isLoading: isLoading,
                  loadingContent: Image.asset(
                    'assets/images/map.png',
                    height: MediaQuery.of(context).size.height * 0.53 + 163,
                    width: MediaQuery.of(context).size.width,
                    scale: 0.5,
                  ),
                  loadedContent: SizedBox(
                    height: MediaQuery.of(context).size.height * 0.53 + 163,
                    width: MediaQuery.of(context).size.width,
                    child: FlutterMap(
                      options: MapOptions(
                        initialCameraFit: CameraFit.bounds(
                          bounds: LatLngBounds(widget.loc1, widget.loc2),
                          padding: const EdgeInsets.only(
                              left: 50, right: 50, top: 150, bottom: 90),
                        ),
                      ),
                      children: [
                        TileLayer(
                          urlTemplate:
                              "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
                          subdomains: const ['a', 'b', 'c'],
                        ),
                        PolylineLayer(
                          polylines: [
                            Polyline(
                              points: routePoints,
                              strokeWidth: 4.0,
                              color: Colors.blue,
                            ),
                          ],
                        ),
                        MarkerLayer(
                          markers: markers,
                        ),
                      ],
                    ),
                  ),
                ),
                Column(children: [
                  ClipRRect(
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                      child: Container(
                        height: 123,
                        width: MediaQuery.of(context).size.width,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.85),
                          border: Border.all(
                            color: Colors.black.withOpacity(0.3),
                          ),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.only(top: 34),
                          child: Row(
                            children: [
                              const SizedBox(
                                width: 15,
                              ),
                              SizedBox(
                                height: 50,
                                width: 80,
                                child: ElevatedButton(
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                  },
                                  style: ElevatedButton.styleFrom(
                                      shadowColor: Colors.transparent,
                                      backgroundColor: Colors.transparent,
                                      alignment: Alignment.center),
                                  child: const Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Padding(
                                        padding: EdgeInsets.only(left: 3.0),
                                        child: Icon(
                                          Icons.arrow_back_ios,
                                          color: Colors.black,
                                          size: 22,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              const Expanded(
                                child: Center(
                                  child: Text("Car Details",
                                      style: TextStyle(
                                          fontSize: 22,
                                          color: Colors.black,
                                          fontWeight: FontWeight.bold)),
                                ),
                              ),
                              const SizedBox(
                                width: 85,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.53,
                  ),
                  Stack(children: [
                    Container(
                      height: MediaQuery.of(context).size.height * 0.47 - 123,
                      width: MediaQuery.of(context).size.width,
                      decoration: const BoxDecoration(
                          color: Color.fromARGB(255, 39, 39, 39),
                          borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(40),
                              topRight: Radius.circular(40))),
                      child: Row(
                        children: [
                          SizedBox(
                            width: MediaQuery.of(context).size.width * 0.5,
                            child: Padding(
                              padding: const EdgeInsets.only(left: 25),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  SizedBox(
                                    width: MediaQuery.of(context).size.width *
                                        1 /
                                        3,
                                    child: Column(
                                      children: [
                                        const SizedBox(height: 20),
                                        Text(
                                          widget.model,
                                          style: const TextStyle(
                                              fontFamily: 'be',
                                              fontSize: 40,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.white),
                                        ),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            const Icon(Icons.near_me,
                                                color: Colors.white70),
                                            const SizedBox(width: 8),
                                            Text(
                                              widget.dist >= 1e6
                                                  ? "${(widget.dist / 1e6).toStringAsFixed(1)} Mm"
                                                  : widget.dist >= 1000
                                                      ? "${(widget.dist / 1000).toStringAsFixed(1)}k Km"
                                                      : "${widget.dist} Km",
                                              style: const TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 20,
                                                  fontWeight: FontWeight.bold),
                                            ),
                                          ],
                                        )
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          SizedBox(
                            width: MediaQuery.of(context).size.width * 0.5,
                            child: Padding(
                              padding: const EdgeInsets.only(right: 25),
                              child: Column(
                                children: [
                                  const SizedBox(height: 20),
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(15),
                                    child: Image.network(widget.imageUrl,
                                        fit: BoxFit.cover),
                                  ),
                                ],
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
                    Column(
                      children: [
                        SizedBox(
                          height:
                              123 + MediaQuery.of(context).size.height * 0.02,
                        ),
                        Container(
                          height:
                              MediaQuery.of(context).size.height * 0.45 - 246,
                          width: MediaQuery.of(context).size.width,
                          decoration: const BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(40),
                                  topRight: Radius.circular(40))),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Padding(
                                    padding: EdgeInsets.only(bottom: 5),
                                    child: Icon(
                                      FontAwesomeIcons.dollarSign,
                                      size: 40,
                                    ),
                                  ),
                                  const SizedBox(
                                    width: 1,
                                  ),
                                  Text(
                                    widget.price.toString(),
                                    style: const TextStyle(
                                        fontFamily: 'be',
                                        fontSize: 40,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  const SizedBox(
                                    width: 8,
                                  ),
                                  const Text(
                                    "/day",
                                    style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.normal),
                                  ),
                                ],
                              ),
                              const SizedBox(
                                width: 15,
                              ),
                              SizedBox(
                                  width:
                                      MediaQuery.of(context).size.width * 0.4,
                                  height: 54,
                                  child: Loading(
                                    isLoading: isLoading,
                                    loadingContent: ElevatedButton(
                                        onPressed: () {},
                                        style: ElevatedButton.styleFrom(
                                            foregroundColor: Colors.white,
                                            backgroundColor: Colors.white,
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(50),
                                            )),
                                        child: const Text(
                                          '',
                                          style: TextStyle(
                                              fontSize: 19,
                                              fontWeight: FontWeight.normal),
                                        )),
                                    loadedContent: ElevatedButton(
                                        onPressed: () async {
                                          await _book(widget.id, widget.uid);
                                        },
                                        style: ElevatedButton.styleFrom(
                                            foregroundColor: Colors.white,
                                            backgroundColor: isBooked == 1
                                                ? Colors.red
                                                : isBooked == 0
                                                    ? Colors.black
                                                    : Colors.grey[300],
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(50),
                                            )),
                                        child: Text(
                                          isBooked == 1
                                              ? 'Cancel'
                                              : isBooked == 0
                                                  ? 'Book now'
                                                  : "",
                                          style: const TextStyle(
                                              fontSize: 19,
                                              fontWeight: FontWeight.normal),
                                        )),
                                  ))
                            ],
                          ),
                        ),
                      ],
                    ),
                  ]),
                ]),
              ])
            ])));
  }
}
