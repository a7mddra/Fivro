import 'package:car_rental_a7md/transition/zoomout.dart';
import 'package:car_rental_a7md/views/login.dart';
import 'package:flutter/material.dart';

class MobWelcomeScreen extends StatelessWidget {
  const MobWelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.only(bottom: 15),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 2,
              child: Container(
                decoration: const BoxDecoration(
                    image: DecorationImage(
                        image: AssetImage('assets/images/onboarding.png'),
                        fit: BoxFit.cover)),
              ),
            ),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.only(left: 20),
                    child: Column(
                      children: [
                        Text(
                          "Premium Cars.\nEnjoy the luxury",
                          style: TextStyle(
                              color: Colors.black,
                              fontFamily: 'be',
                              fontSize: 40,
                              fontWeight: FontWeight.bold),
                          textAlign: TextAlign.left,
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        Text(
                          'Premium and prestige car daily rental. \nExperience the thrill at a lower price',
                          style: TextStyle(color: Colors.grey, fontSize: 16),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(
                    height: 29,
                  ),
                  Align(
                    alignment: Alignment.center,
                    child: SizedBox(
                        width: 341,
                        height: 54,
                        child: ElevatedButton(
                            onPressed: () {
                              Navigator.of(context).push(ZoomOut(
                                page: const Login(),
                              ));
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
                            ))),
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
