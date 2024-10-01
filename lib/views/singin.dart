import 'package:car_rental_a7md/resources/auth_methods.dart';
import 'package:car_rental_a7md/responsive/mob_screen_layout.dart';
import 'package:car_rental_a7md/responsive/responsive_layout_screen.dart';
import 'package:car_rental_a7md/responsive/web_screen_layout.dart';
import 'package:car_rental_a7md/widgets/text_feild_input.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class SignIn extends StatefulWidget {
  final String error;
  const SignIn({super.key, required this.error});

  @override
  State<SignIn> createState() => _SignInState();
}

class _SignInState extends State<SignIn> with WidgetsBindingObserver {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  String error = '';
  bool isLoading = false;

  @override
  void dispose() {
    super.dispose();
    _emailController.dispose();
    _passwordController.dispose();
  }

  void loginUser() async {
    setState(() {
      isLoading = true;
    });
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      setState(() {
        error = 'Please enter all required fields.';
        isLoading = false;
      });
      return;
    }

    String res = await AuthMethods().logInUser(
      email: _emailController.text,
      password: _passwordController.text,
    );

    if (res == 'Success') {
      User? currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser != null && currentUser.emailVerified) {
        await updateUData(_passwordController.text);
        Navigator.of(context).pushReplacement(MaterialPageRoute(
          builder: (context) => const ResponsiveLayout(
            webScreenLayout: WebScreenLayout(),
            mobScreenLayout: MobScreenLayout(),
          ),
        ));
      } else {
        setState(() {
          error = 'Please verify your email before logging in.';
          isLoading = false;
        });
      }
    } else {
      setState(() {
        error = res;
        isLoading = false;
      });
    }
  }

  Future<void> updateUData(String pass) async {
    try {
      var userDocRef = FirebaseFirestore.instance
          .collection('users')
          .doc(FirebaseAuth.instance.currentUser!.uid);
      Map<String, dynamic> newData = {
        'password': pass,
      };
      await userDocRef.update(newData);
    } catch (e) {
      setState(() {
        error = e.toString();
      });
    }
  }

  Future<void> sendPasswordReset(String email) async {
    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
    } catch (e) {
      setState(() {
        error = e.toString();
      });
    }
  }

  @override
  void initState() {
    super.initState();
    setState(() {
      error = widget.error;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        body: Stack(children: [
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Spacer(),
                Transform.scale(
                  scale: 2,
                  child: Lottie.asset(
                    'assets/animations/email.json',
                  ),
                ),
                const SizedBox(height: 50),
                SizedBox(
                  width: 350,
                  child: TextFeildInput(
                      textEditingController: _emailController,
                      hintText: "Email",
                      textInputType: TextInputType.emailAddress),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  width: 350,
                  child: TextFeildInput(
                    textEditingController: _passwordController,
                    hintText: "Password",
                    textInputType: TextInputType.text,
                    isPass: true,
                  ),
                ),
                const SizedBox(height: 15),
                SizedBox(
                  height: 47,
                  width: 350,
                  child: ElevatedButton(
                    onPressed: loginUser,
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.white,
                      backgroundColor: Colors.black,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text(
                      "Log in",
                      style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w500,
                          fontFamily: 'be'),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                RichText(
                  text: TextSpan(
                    text: "Forgot your password?",
                    style: const TextStyle(
                        fontSize: 17,
                        color: Colors.blue,
                        fontWeight: FontWeight.bold),
                    recognizer: TapGestureRecognizer()
                      ..onTap = () {
                        if (_emailController.text.isNotEmpty) {
                          sendPasswordReset(_emailController.text);
                        } else {
                          setState(() {
                            error = "Please enter your email";
                          });
                        }
                      },
                  ),
                ),
                SizedBox(
                  height: 75,
                  child: isLoading
                      ? Padding(
                          padding: const EdgeInsets.only(top: 12),
                          child: Lottie.asset(
                            'assets/animations/loading.json',
                            height: 47,
                            width: 47,
                          ),
                        )
                      : Padding(
                          padding: const EdgeInsets.only(top: 27),
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
                const Spacer(),
              ],
            ),
          ),
        ]));
  }
}
