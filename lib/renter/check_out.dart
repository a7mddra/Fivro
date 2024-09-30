import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CheckOut extends StatefulWidget {
  final String email;
  final String uid;
  final String carId;
  const CheckOut(
      {super.key, required this.email, required this.uid, required this.carId});

  @override
  State<CheckOut> createState() => _CheckOutState();
}

class _CheckOutState extends State<CheckOut> {
  bool copy = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          Positioned(
            top: 40,
            left: 20,
            child: SizedBox(
              height: 55,
              width: 55,
              child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.black,
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      padding: const EdgeInsets.all(0)),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Icon(
                    Icons.arrow_back_ios_new,
                    color: Colors.black,
                  )),
            ),
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                "Contact with the rentee via",
                style: TextStyle(
                  fontFamily: 'be',
                  fontSize: 25,
                ),
              ),
              const SizedBox(
                height: 10,
              ),
              Text(
                widget.email,
                style: const TextStyle(
                  fontFamily: 'be',
                  fontSize: 15,
                ),
              ),
              const SizedBox(
                height: 10,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    height: 55,
                    width: 140,
                    child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                            foregroundColor: Colors.white,
                            backgroundColor: Colors.blue,
                            shadowColor: Colors.transparent,
                            padding: const EdgeInsets.all(0)),
                        onPressed: () {
                          Clipboard.setData(ClipboardData(text: widget.email));
                          setState(() {
                            copy = !copy;
                          });
                        },
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.copy,
                              color: Colors.white,
                            ),
                            const SizedBox(
                              width: 10,
                            ),
                            Text(
                              copy ? "Copied" : "Copy",
                              style: const TextStyle(
                                  fontSize: 19, color: Colors.white),
                            )
                          ],
                        )),
                  ),
                  const SizedBox(
                    width: 10,
                  ),
                  SizedBox(
                    height: 55,
                    width: 140,
                    child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                            foregroundColor: Colors.black,
                            backgroundColor:
                                const Color.fromARGB(255, 243, 32, 17),
                            shadowColor: Colors.transparent,
                            padding: const EdgeInsets.all(0)),
                        onPressed: () async {
                          await FirebaseFirestore.instance
                              .collection('cars')
                              .doc(widget.carId)
                              .update({
                            'books': FieldValue.arrayRemove([widget.uid])
                          });
                          // ignore: use_build_context_synchronously
                          Navigator.of(context).pop();
                        },
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.delete,
                              color: Colors.white,
                            ),
                            SizedBox(
                              width: 10,
                            ),
                            Text(
                              "Remove",
                              style:
                                  TextStyle(fontSize: 19, color: Colors.white),
                            )
                          ],
                        )),
                  ),
                ],
              )
            ],
          ),
        ],
      ),
    );
  }
}
