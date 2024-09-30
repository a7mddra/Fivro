import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:location/location.dart';
import 'package:lottie/lottie.dart' as lottie;

class MapWidget extends StatefulWidget {
  final LatLng? initialLocation;

  const MapWidget({super.key, required this.initialLocation});

  @override
  State<MapWidget> createState() => _MapWidgetState();
}

class _MapWidgetState extends State<MapWidget> with WidgetsBindingObserver {
  LatLng? _selectedLoc;
  LatLng? _userLoc;
  final MapController _mapController = MapController();

  @override
  void initState() {
    super.initState();
    _selectedLoc = widget.initialLocation;
    _userLoc = widget.initialLocation;
  }

  void _confirmLocation() {
    Navigator.of(context).pop({
      'loc': _selectedLoc,
    });
  }

  void _cancelSelection() {
    Navigator.of(context).pop(null);
  }

  Future<void> _resetLocation() async {
    try {
      LocationData locationData = await Location().getLocation();
      _userLoc = LatLng(locationData.latitude!, locationData.longitude!);

      setState(() {
        _selectedLoc = _userLoc;
      });

      _mapController.move(_userLoc!, 13.0);
    } on Exception {
      setState(() {
        _selectedLoc = _selectedLoc;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Stack(
        children: [
          InkWell(
            focusColor: Colors.transparent,
            hoverColor: Colors.transparent,
            highlightColor: Colors.transparent,
            splashColor: Colors.transparent,
            overlayColor: WidgetStateColor.transparent,
            mouseCursor: SystemMouseCursors.basic,
            onTap: () {
              Navigator.of(context).pop();
            },
            child: Container(
              height: MediaQuery.of(context).size.height,
              width: MediaQuery.of(context).size.width,
              color: const Color.fromARGB(32, 0, 0, 0),
            ),
          ),
          Padding(
            padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).size.height * 2.8 / 14.5),
            child: Center(
              child: Padding(
                padding: const EdgeInsets.only(top: 70),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                    child: Container(
                      height: MediaQuery.of(context).size.height - 190,
                      width: MediaQuery.of(context).size.width - 36,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.8),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: Colors.black.withOpacity(0.3),
                        ),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          const SizedBox(height: 10),
                          const Material(
                            color: Colors.transparent,
                            child: Text(
                              "Pick your car location",
                              style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 19,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                          const SizedBox(height: 10),
                          Expanded(
                            child: _selectedLoc != null
                                ? Stack(
                                    children: [
                                      FlutterMap(
                                        mapController: _mapController,
                                        options: MapOptions(
                                          initialCenter: _selectedLoc!,
                                          initialZoom: 13.0,
                                          onTap: (tapPos, latLng) {
                                            setState(() {
                                              _selectedLoc =
                                                  latLng; // Update marker
                                            });
                                          },
                                        ),
                                        children: [
                                          TileLayer(
                                            urlTemplate:
                                                "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
                                            subdomains: const ['a', 'b', 'c'],
                                          ),
                                          MarkerLayer(
                                            markers: [
                                              Marker(
                                                point: _selectedLoc!,
                                                child: const Icon(
                                                  Icons.location_on,
                                                  color: Colors.red,
                                                  size: 40,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                      Positioned(
                                        bottom: 20,
                                        right: 20,
                                        child: FloatingActionButton(
                                          backgroundColor: const Color.fromARGB(
                                              255, 240, 240, 240),
                                          elevation: 0,
                                          focusElevation: 0,
                                          hoverElevation: 0,
                                          onPressed: _resetLocation,
                                          child: const Icon(
                                            Icons.my_location,
                                            color: Colors.blue,
                                          ),
                                        ),
                                      ),
                                    ],
                                  )
                                : Center(
                                    child: lottie.Lottie.asset(
                                      'assets/animations/loading.json',
                                      height: 47,
                                      width: 47,
                                    ),
                                  ),
                          ),
                          const SizedBox(height: 10),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Container(
                                  height: 50,
                                  color: Colors.transparent,
                                  child: ElevatedButton(
                                    onPressed:
                                        _cancelSelection, // Cancel button
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.transparent,
                                      shadowColor: Colors.black.withOpacity(0),
                                      elevation: 0,
                                      shape: const RoundedRectangleBorder(
                                        borderRadius: BorderRadius.only(
                                          bottomLeft: Radius.circular(20),
                                        ),
                                      ),
                                    ),
                                    child: const Text(
                                      "Cancel",
                                      style: TextStyle(
                                        fontSize: 17,
                                        color: Color(0xFF007AFF),
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              Expanded(
                                child: Container(
                                  height: 50,
                                  color: Colors.transparent,
                                  child: ElevatedButton(
                                    onPressed:
                                        _confirmLocation, // Confirm location
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.transparent,
                                      shadowColor: Colors.black.withOpacity(0),
                                      elevation: 0,
                                      shape: const RoundedRectangleBorder(
                                        borderRadius: BorderRadius.only(
                                          bottomRight: Radius.circular(20),
                                        ),
                                      ),
                                    ),
                                    child: const Text(
                                      "Confirm",
                                      style: TextStyle(
                                        fontSize: 17,
                                        color: Color(0xFF007AFF),
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
