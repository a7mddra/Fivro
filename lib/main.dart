import 'package:car_rental_a7md/responsive/responsive_layout_screen.dart';
import 'package:car_rental_a7md/responsive/mob_welcome_screen.dart';
import 'package:car_rental_a7md/responsive/web_welcome_screen.dart';
import 'package:car_rental_a7md/responsive/mob_screen_layout.dart';
import 'package:car_rental_a7md/responsive/web_screen_layout.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
// FOR ANDROID
/*
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
*/
//FOR WEB
import 'package:device_preview/device_preview.dart';
import 'package:flutter/foundation.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
      options: const FirebaseOptions(
    apiKey: 'AIzaSyAP8OEGz68NA3c_c5GMWmBN0ZWrfxiGrjU',
    appId: '1:384436575346:web:22b8d74faa7441af3636eb',
    messagingSenderId: '384436575346',
    projectId: 'car-rental-a7md-dc08d',
    authDomain: 'car-rental-a7md-dc08d.firebaseapp.com',
    databaseURL: 'https://car-rental-a7md-dc08d-default-rtdb.firebaseio.com',
    storageBucket: 'car-rental-a7md-dc08d.appspot.com',
    measurementId: 'G-P0RH1YE0G3',
  ));

  runApp(DevicePreview(
    enabled: !kReleaseMode,
    builder: (context) => const MyApp(),
  ));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      locale: DevicePreview.locale(context),
      builder: DevicePreview.appBuilder,
      debugShowCheckedModeBanner: false,
      //
      home: StreamBuilder(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.active) {
            if (snapshot.hasData) {
              User? user = FirebaseAuth.instance.currentUser;

              if (user != null && user.emailVerified) {
                return const ResponsiveLayout(
                    webScreenLayout: WebScreenLayout(),
                    mobScreenLayout: MobScreenLayout());
              } else {
                return const ResponsiveLayout(
                    webScreenLayout: WebWelcomeScreen(),
                    mobScreenLayout: MobWelcomeScreen());
              }
            } else if (snapshot.hasError) {
              return Center(
                child: Text(
                  '${snapshot.error}',
                  style: const TextStyle(color: Colors.red),
                ),
              );
            }
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: Lottie.asset(
                'assets/animations/loading.json',
                height: 47,
                width: 47,
              ),
            );
          }

          return const ResponsiveLayout(
              webScreenLayout: WebWelcomeScreen(),
              mobScreenLayout: MobWelcomeScreen());
        },
      ),
    );
  }
}
