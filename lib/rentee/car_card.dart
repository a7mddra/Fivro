import 'package:car_rental_a7md/rentee/book.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:latlong2/latlong.dart';

class CarCard extends StatelessWidget {
  final String model;
  final int price;
  final int dist;
  final String imageUrl;
  final String profUrl;
  final String uName;
  final String date;
  final LatLng loc1;
  final LatLng loc2;
  final String id;
  final List books;
  final String uid;
  final bool state;

  const CarCard({
    super.key,
    required this.model,
    required this.price,
    required this.dist,
    required this.imageUrl,
    required this.profUrl,
    required this.uName,
    required this.date,
    required this.loc1,
    required this.loc2,
    required this.id,
    required this.books,
    required this.uid,
    required this.state,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 20, right: 20, top: 10),
      child: InkWell(
        focusColor: Colors.transparent,
        hoverColor: Colors.transparent,
        highlightColor: Colors.transparent,
        splashColor: Colors.transparent,
        overlayColor: WidgetStateColor.transparent,
        borderRadius: BorderRadius.circular(20),
        mouseCursor:
            state ? SystemMouseCursors.click : SystemMouseCursors.basic,
        onTap: () {
          if (state) {
            Navigator.of(context).push(MaterialPageRoute(
                builder: (context) => Book(
                      model: model,
                      price: price,
                      imageUrl: imageUrl,
                      profUrl: profUrl,
                      uName: uName,
                      loc1: loc1,
                      loc2: loc2,
                      dist: dist,
                      id: id,
                      uid: uid,
                    )));
          }
        },
        child: Card(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 10),
              Stack(
                children: [
                  Row(
                    children: [
                      const SizedBox(width: 10),
                      CircleAvatar(
                        radius: 20,
                        backgroundImage: NetworkImage(profUrl),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        uName,
                        style: const TextStyle(
                          color: Colors.black,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text(
                          state ? "Available" : "Unavailable",
                          style: TextStyle(
                              fontSize: 20,
                              color: state ? Colors.green : Colors.red,
                              fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(width: 10),
                      ],
                    ),
                  )
                ],
              ),
              const SizedBox(height: 8),
              Center(
                child: SizedBox(
                  height: (MediaQuery.of(context).size.width - 80) * 2 / 3.1,
                  width: MediaQuery.of(context).size.width - 80,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(15),
                    child: Image.network(imageUrl, fit: BoxFit.cover),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          model,
                          style: const TextStyle(
                              fontSize: 25, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(width: 15),
                        const Icon(Icons.near_me, color: Colors.black87),
                        const SizedBox(width: 8),
                        Text(
                          dist >= 1e6
                              ? "${(dist / 1e6).toStringAsFixed(1)} Mm"
                              : dist >= 1000
                                  ? "${(dist / 1000).toStringAsFixed(1)}k Km"
                                  : "$dist Km",
                          style: const TextStyle(
                              color: Colors.black87,
                              fontSize: 20,
                              fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Stack(
                      children: [
                        Text(
                          "$price \$/day",
                          style: const TextStyle(
                              color: Colors.black87,
                              fontSize: 20,
                              fontWeight: FontWeight.bold),
                        ),
                        Column(
                          children: [
                            const SizedBox(height: 8),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Text(
                                  date,
                                ),
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
          ),
        ),
      ),
    );
  }
}
