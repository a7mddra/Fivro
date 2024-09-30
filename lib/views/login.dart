import 'package:car_rental_a7md/responsive/mob_signup.dart';
import 'package:car_rental_a7md/responsive/responsive_layout_screen.dart';
import 'package:car_rental_a7md/responsive/web_screen_layout.dart';
import 'package:car_rental_a7md/responsive/mob_screen_layout.dart';
import 'package:car_rental_a7md/responsive/web_signup.dart';
import 'package:car_rental_a7md/widgets/text_feild_input.dart';
import 'package:car_rental_a7md/resources/auth_methods.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> with WidgetsBindingObserver {
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
      // ignore: use_build_context_synchronously
      Navigator.of(context).pushReplacement(MaterialPageRoute(
          builder: (context) => const ResponsiveLayout(
              webScreenLayout: WebScreenLayout(),
              mobScreenLayout: MobScreenLayout())));
    }

    setState(() {
      isLoading = false;
    });

    setState(() {
      error = res != 'Success' ? res : '';
    });
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
              ShaderMask(
                shaderCallback: (bounds) => const LinearGradient(
                  colors: [Colors.blue, Colors.purple, Colors.red],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ).createShader(bounds),
                child: const Text(
                  "Let's Go",
                  style: TextStyle(
                      fontSize: 100,
                      fontFamily: 'ce',
                      fontWeight: FontWeight.bold,
                      color: Colors.white),
                  textAlign: TextAlign.center,
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
              Padding(
                  padding: const EdgeInsets.only(bottom: 25),
                  child: RichText(
                    text: TextSpan(
                      text: "Don't have an account? ",
                      style: const TextStyle(fontSize: 17, color: Colors.black),
                      children: [
                        TextSpan(
                          text: "Sign up",
                          style: const TextStyle(
                              fontSize: 17,
                              color: Colors.blue,
                              fontWeight: FontWeight.bold),
                          recognizer: TapGestureRecognizer()
                            ..onTap = () {
                              Navigator.of(context).pushReplacement(
                                MaterialPageRoute(
                                    builder: (context) =>
                                        const ResponsiveLayout(
                                            webScreenLayout: WebSignUp(),
                                            mobScreenLayout: MobSignUp())),
                              );
                            },
                        )
                      ],
                    ),
                  )),
            ],
          ),
        ),
        Positioned(
          top: MediaQuery.of(context).padding.top + 10,
          left: 10,
          child: CircleAvatar(
            backgroundColor: Colors.white,
            radius: 20, // You can adjust this size as needed
            child: IconButton(
              icon: const Icon(
                Icons.arrow_back_ios_new,
                color: Colors.black,
                size: 20,
              ),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
          ),
        ),
      ]),
    );
  }
}
