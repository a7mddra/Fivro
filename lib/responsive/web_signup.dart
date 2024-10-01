import 'package:car_rental_a7md/responsive/responsive_layout_screen.dart';
import 'package:car_rental_a7md/responsive/mob_screen_layout.dart';
import 'package:car_rental_a7md/responsive/web_screen_layout.dart';
import 'package:car_rental_a7md/widgets/text_feild_input.dart';
import 'package:car_rental_a7md/resources/auth_methods.dart';
import 'package:car_rental_a7md/utils/utils.dart';
import 'package:car_rental_a7md/views/login.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'dart:typed_data';

class WebSignUp extends StatefulWidget {
  const WebSignUp({super.key});

  @override
  State<WebSignUp> createState() => _WebSignUpState();
}

class _WebSignUpState extends State<WebSignUp> with WidgetsBindingObserver {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();
  Uint8List? _image;
  String _type = '';
  String error = '';
  bool isLoading = false;
  bool isBack = false;
  bool first = false;
  bool second = false;

  @override
  void dispose() {
    super.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _fullNameController.dispose();
    _ageController.dispose();
  }

  void selectImage() async {
    Uint8List? img = await pickImage(ImageSource.gallery);
    if (img != null) {
      setState(() {
        _image = img;
      });
    }
  }

  void signUpUser() async {
    setState(() {
      isLoading = true;
    });
    if (_emailController.text.isEmpty ||
        _fullNameController.text.isEmpty ||
        _ageController.text.isEmpty ||
        _passwordController.text.isEmpty ||
        _type == '') {
      setState(() {
        error = 'Please enter all required fields.';
        isLoading = false;
      });
      return;
    }

    int age = int.parse(_ageController.text);
    String res = await AuthMethods().signUpUser(
      email: _emailController.text,
      fullName: _fullNameController.text,
      age: age,
      password: _passwordController.text,
      file: _image!,
      type: _type,
    );

    if (res == 'Success') {
      setState(() {
        isBack = true;
        error = 'Please verify your email before logging in.';
      });
    } else {
      setState(() {
        error = res;
      });
    }

    setState(() {
      isLoading = false;
    });
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: isBack
          ? Stack(children: [
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
                      width: 455,
                      child: TextFeildInput(
                          textEditingController: _emailController,
                          hintText: "Email",
                          textInputType: TextInputType.emailAddress),
                    ),
                    const SizedBox(height: 10),
                    SizedBox(
                      width: 455,
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
                      width: 455,
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
                            text: "Email not sent? ",
                            style: const TextStyle(
                                fontSize: 17, color: Colors.black),
                            children: [
                              TextSpan(
                                text: "Resend it",
                                style: const TextStyle(
                                    fontSize: 17,
                                    color: Colors.blue,
                                    fontWeight: FontWeight.bold),
                                recognizer: TapGestureRecognizer()
                                  ..onTap = () async {
                                    await AuthMethods()
                                        .resendVerificationEmail(context);
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
            ])
          : Stack(
              children: [
                Padding(
                    padding: const EdgeInsets.only(top: 10, left: 10),
                    child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Positioned(
                            top: MediaQuery.of(context).padding.top - 10,
                            left: 10,
                            child: CircleAvatar(
                              backgroundColor: Colors.white,
                              radius: 20,
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
                        ])),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Stack(
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(bottom: 20),
                              child: _image != null
                                  ? CircleAvatar(
                                      radius: 70,
                                      backgroundImage: MemoryImage(_image!))
                                  : const CircleAvatar(
                                      radius: 70,
                                      backgroundImage:
                                          AssetImage('assets/images/user.png'),
                                    ),
                            ),
                            Positioned(
                              bottom: 15,
                              left: 95,
                              child: CircleAvatar(
                                backgroundColor:
                                    const Color.fromARGB(250, 224, 224, 224),
                                radius: 19,
                                child: IconButton(
                                  icon: const Icon(
                                    Icons.photo_camera,
                                    color: Colors.black,
                                    size: 24,
                                  ),
                                  onPressed: selectImage,
                                  alignment: Alignment.center,
                                ),
                              ),
                            )
                          ],
                        ),
                        SizedBox(
                          width: 455,
                          child: TextFeildInput(
                              textEditingController: _emailController,
                              hintText: "Email",
                              textInputType: TextInputType.emailAddress),
                        ),
                        const SizedBox(height: 10),
                        SizedBox(
                          width: 455,
                          child: TextFeildInput(
                            textEditingController: _fullNameController,
                            hintText: "Full Name",
                            textInputType: TextInputType.name,
                          ),
                        ),
                        const SizedBox(height: 10),
                        SizedBox(
                          width: 455,
                          child: TextFeildInput(
                            textEditingController: _ageController,
                            hintText: "Age",
                            textInputType: TextInputType.number,
                          ),
                        ),
                        const SizedBox(height: 10),
                        SizedBox(
                          width: 455,
                          child: TextFeildInput(
                            textEditingController: _passwordController,
                            hintText: "Password",
                            textInputType: TextInputType.text,
                            isPass: true,
                          ),
                        ),
                        const SizedBox(height: 15),
                        const SizedBox(
                          width: 455,
                          child: Text(
                            "What Brings You Here?",
                            style: TextStyle(fontSize: 17, color: Colors.black),
                            textAlign: TextAlign.start,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            SizedBox(
                                width: 195,
                                height: 47,
                                child: ElevatedButton(
                                    onPressed: () {
                                      setState(() {
                                        first = true;
                                        second = false;
                                        _type = "Rentee";
                                      });
                                    },
                                    style: ElevatedButton.styleFrom(
                                        foregroundColor:
                                            first ? Colors.white : Colors.black,
                                        backgroundColor:
                                            first ? Colors.black : Colors.white,
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(14),
                                        )),
                                    child: const Text(
                                      'To Rent A Car',
                                      style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.normal),
                                      textAlign: TextAlign.center,
                                    ))),
                            const SizedBox(
                              width: 10,
                            ),
                            SizedBox(
                                width: 250,
                                height: 47,
                                child: ElevatedButton(
                                    onPressed: () {
                                      setState(() {
                                        first = false;
                                        second = true;
                                        _type = "Renter";
                                      });
                                    },
                                    style: ElevatedButton.styleFrom(
                                        foregroundColor: second
                                            ? Colors.white
                                            : Colors.black,
                                        backgroundColor: second
                                            ? Colors.black
                                            : Colors.white,
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(14),
                                        )),
                                    child: const Text(
                                      'To Earn Money Renting',
                                      style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.normal),
                                      textAlign: TextAlign.center,
                                    ))),
                          ],
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(top: 12),
                              child: SizedBox(
                                height: 47,
                                width: 195,
                                child: ElevatedButton(
                                  onPressed: signUpUser,
                                  style: ElevatedButton.styleFrom(
                                    foregroundColor: Colors.white,
                                    backgroundColor: Colors.black,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                  child: const Text(
                                    "Sign up",
                                    style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.w500,
                                        fontFamily: 'be'),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(
                              width: 10,
                            ),
                            SizedBox(
                              height: 75,
                              width: 250,
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
                                      padding: const EdgeInsets.only(top: 26),
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
                          ],
                        ),
                        RichText(
                          text: TextSpan(
                            text: "Have an account? ",
                            style: const TextStyle(
                                fontSize: 17, color: Colors.black),
                            children: [
                              TextSpan(
                                text: "Log in",
                                style: const TextStyle(
                                    fontSize: 17,
                                    color: Colors.blue,
                                    fontWeight: FontWeight.bold),
                                recognizer: TapGestureRecognizer()
                                  ..onTap = () {
                                    Navigator.of(context).pushReplacement(
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                const Login()));
                                  },
                              )
                            ],
                          ),
                        )
                      ],
                    ),
                  ],
                ),
              ],
            ),
    );
  }
}
