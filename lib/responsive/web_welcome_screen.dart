import 'package:car_rental_a7md/views/login.dart';
import 'package:flutter/material.dart';

class WebWelcomeScreen extends StatelessWidget {
  const WebWelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.only(bottom: 15),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment:
              CrossAxisAlignment.center, // Align items vertically
          children: [
            Flexible(
              flex: 1, // Allow image to take only necessary space
              child: Image.asset(
                'assets/images/onboarding.png',
                alignment: Alignment.centerLeft,
              ),
            ),
            const SizedBox(
                width: 20), // Add a gap between the image and the column
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Premium Cars.\nEnjoy the luxury",
                  style: TextStyle(
                      color: Colors.black,
                      fontFamily: 'be',
                      fontSize: 35.0,
                      fontWeight: FontWeight.bold),
                  textAlign: TextAlign.left,
                ),
                const SizedBox(height: 10),
                const Text(
                  'Premium and prestige car daily rental. \nExperience the thrill at a lower price',
                  style: TextStyle(color: Colors.grey, fontSize: 16),
                ),
                const SizedBox(height: 20),
                SizedBox(
                    width: 341,
                    height: 54,
                    child: ElevatedButton(
                        onPressed: () {
                          Navigator.of(context).push(MaterialPageRoute(
                              builder: (context) => const Login()));
                        },
                        style: ElevatedButton.styleFrom(
                            foregroundColor: Colors.white,
                            backgroundColor: Colors.black,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            )),
                        child: const Text(
                          "Let's Go",
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.normal),
                        )))
              ],
            ),
            const SizedBox(width: 40),
            Flexible(
              flex: 1, // Allow image to take only necessary space
              child: Image.asset(
                'assets/images/onboarding2.png',
                alignment: Alignment.centerLeft,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
