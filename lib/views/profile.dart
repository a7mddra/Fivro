import 'dart:typed_data';
import 'dart:ui';
import 'package:car_rental_a7md/resources/auth_methods.dart';
import 'package:car_rental_a7md/resources/storage_methods.dart';
import 'package:car_rental_a7md/utils/utils.dart';
import 'package:car_rental_a7md/views/singin.dart';
import 'package:car_rental_a7md/widgets/msg.dart';
import 'package:car_rental_a7md/widgets/updage.dart';
import 'package:car_rental_a7md/widgets/updmail.dart';
import 'package:car_rental_a7md/widgets/updnam.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lottie/lottie.dart';

class Profile extends StatefulWidget {
  const Profile({
    super.key,
  });
  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  var userData = {};
  Widget? pro;
  Uint8List? img;
  String? nam;
  String? mail;
  String? pass;
  int? age;
  bool isUpdate = false;
  String error = '';
  bool isMail = false;
  User user = FirebaseAuth.instance.currentUser!;
  getUData() async {
    try {
      var userSnap = await FirebaseFirestore.instance
          .collection('users')
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .get();

      userData = userSnap.data()!;
      setState(() {
        pro = Image.network(userData['photoUrl'], fit: BoxFit.cover);
        nam = userData['fullName'];
        mail = userData['email'];
        pass = userData['password'];
        age = userData['age'];
      });
    } catch (e) {
      // ignore: use_build_context_synchronously
      showSnackBar(context, e.toString());
    }
  }

  @override
  void initState() {
    super.initState();
    getUData();
  }

  _selectImage(BuildContext parentContext) async {
    Uint8List? file = await pickImage(ImageSource.gallery);
    if (file != null) {
      setState(() {
        img = file;
        pro = Image.memory(file, fit: BoxFit.cover);
      });
    }
  }

  Future<void> updateUData(String fullName, int age, String type) async {
    setState(() {
      isUpdate = true;
    });
    try {
      var userDocRef = FirebaseFirestore.instance
          .collection('users')
          .doc(FirebaseAuth.instance.currentUser!.uid);
      String imgUrl = userData['photoUrl'];
      if (img != null) {
        imgUrl = await StorageMethods()
            .uploadImageToStorage('profilePics', img!, false);
      }
      Map<String, dynamic> newData = {
        'age': age,
        'fullName': fullName,
        'photoUrl': imgUrl,
        'type': type,
        'uid': FirebaseAuth.instance.currentUser!.uid,
      };
      await userDocRef.update(newData);
      setState(() {
        error = "your profile details updated.";
        isUpdate = false;
        Future.delayed(const Duration(milliseconds: 1300), () {
          setState(() {
            //error = '';
          });
        });
      });
    } catch (e) {
      setState(() {
        error = e.toString();
        isUpdate = false;
      });
    }
  }

  Future<void> _openUpdnamDialog(String? name) async {
    final result = await showGeneralDialog<Map<String, dynamic>>(
      context: context,
      barrierDismissible: true,
      barrierLabel: '',
      barrierColor: Colors.transparent,
      transitionDuration: const Duration(milliseconds: 100),
      pageBuilder: (BuildContext context, Animation<double> animation,
          Animation<double> secondaryAnimation) {
        return Center(
          child: Container(
              height: MediaQuery.of(context).size.height,
              width: MediaQuery.of(context).size.width,
              color: Colors.transparent,
              child: Updnam(
                name: name,
              )),
        );
      },
    );

    if (result != null) {
      setState(() {
        nam = result['Name'];
      });
    }
  }

  Future<void> _openUpdmailDialog(String? email) async {
    final result = await showGeneralDialog<Map<String, dynamic>>(
      context: context,
      barrierDismissible: true,
      barrierLabel: '',
      barrierColor: Colors.transparent,
      transitionDuration: const Duration(milliseconds: 100),
      pageBuilder: (BuildContext context, Animation<double> animation,
          Animation<double> secondaryAnimation) {
        return Center(
          child: Container(
              height: MediaQuery.of(context).size.height,
              width: MediaQuery.of(context).size.width,
              color: Colors.transparent,
              child: Updmail(
                email: email,
              )),
        );
      },
    );

    if (result != null) {
      setState(() {
        mail = result['Email'];
        isMail = true;
      });
    }
  }

  Future<void> updateUserEmail(String newEmail, bool f) async {
    try {
      AuthCredential credential = EmailAuthProvider.credential(
        email: user.email!,
        password: userData['password'],
      );
      if (f == true) {
        await user.reauthenticateWithCredential(credential);
        await user.verifyBeforeUpdateEmail(newEmail);
        await AuthMethods().signOut();

        FirebaseAuth.instance.authStateChanges().listen((User? updatedUser) {
          if (updatedUser != null && updatedUser.emailVerified) {
            FirebaseFirestore.instance
                .collection('users')
                .doc(updatedUser.uid)
                .update({
              'email': newEmail,
            });
          }
        });
        // ignore: use_build_context_synchronously
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
              builder: (context) => const SignIn(
                  error: "Please verify your email before logging in.")),
        );
      }
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

  Future<void> _openUpdageDialog(int? uage) async {
    final result = await showGeneralDialog<Map<String, dynamic>>(
      context: context,
      barrierDismissible: true,
      barrierLabel: '',
      barrierColor: Colors.transparent,
      transitionDuration: const Duration(milliseconds: 100),
      pageBuilder: (BuildContext context, Animation<double> animation,
          Animation<double> secondaryAnimation) {
        return Center(
          child: Container(
              height: MediaQuery.of(context).size.height,
              width: MediaQuery.of(context).size.width,
              color: Colors.transparent,
              child: Updage(
                age: uage,
              )),
        );
      },
    );

    if (result != null) {
      setState(() {
        age = int.parse(result['Age']);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final Widget pro_ = pro ?? Container();
    final String nam_ = nam ?? '';
    final String mail_ = mail ?? ' ';
    final int age_ = age ?? 0;
    final String pass_ = pass ?? ' ';

    return Scaffold(
      backgroundColor: Colors.white,
      body: SizedBox(
        height: double.infinity,
        width: double.infinity,
        child: Column(children: [
          Stack(alignment: Alignment.topCenter, children: [
            Padding(
              padding: const EdgeInsets.only(top: 10),
              child: SizedBox(
                height: MediaQuery.of(context).size.height * 0.5,
                width: MediaQuery.of(context).size.width,
                child: ClipRect(
                  child: pro_,
                ),
              ),
            ),
            Column(
              children: [
                ClipRRect(
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                    child: Container(
                      height: MediaQuery.of(context).size.height * 0.11,
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
                                child: Text("Profile Settings",
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
                Stack(children: [
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.31,
                  ),
                  Padding(
                    padding: const EdgeInsets.all(13),
                    child: Align(
                      alignment: Alignment.topRight,
                      child: CircleAvatar(
                        backgroundColor: const Color.fromARGB(148, 0, 0, 0),
                        radius: 19,
                        child: IconButton(
                          icon: const Icon(
                            Icons.edit,
                            color: Colors.white,
                            size: 24,
                          ),
                          onPressed: () {
                            _selectImage(context);
                          },
                          alignment: Alignment.center,
                        ),
                      ),
                    ),
                  ),
                ]),
                Padding(
                  padding: const EdgeInsets.only(top: 10),
                  child: Container(
                    height: MediaQuery.of(context).size.height * 0.08,
                    width: MediaQuery.of(context).size.width,
                    color: const Color.fromARGB(123, 0, 0, 0),
                    child: Row(
                      children: [
                        const SizedBox(
                          width: 10,
                        ),
                        Text(nam_,
                            style: const TextStyle(
                                fontSize: 25,
                                fontFamily: 'be',
                                color: Colors.white)),
                        const SizedBox(
                          width: 10,
                        ),
                        CircleAvatar(
                          backgroundColor: const Color.fromARGB(148, 0, 0, 0),
                          radius: 19,
                          child: IconButton(
                            icon: const Icon(
                              Icons.edit,
                              color: Colors.white,
                              size: 24,
                            ),
                            onPressed: () {
                              _openUpdnamDialog(nam ?? '');
                            },
                            alignment: Alignment.center,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ]),
          const SizedBox(
            height: 10,
          ),
          SizedBox(
            width: MediaQuery.of(context).size.width - 20,
            height: 78.3,
            child: ElevatedButton(
              onPressed: () {
                _openUpdmailDialog(mail ?? '');
              },
              style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  disabledForegroundColor: Colors.transparent,
                  disabledBackgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  surfaceTintColor: Colors.transparent,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                  alignment: Alignment.centerLeft,
                  padding: const EdgeInsets.all(0)),
              child: Row(
                children: [
                  const SizedBox(
                    width: 10,
                  ),
                  const Icon(
                    FontAwesomeIcons.at,
                    color: Colors.black54,
                    size: 29,
                  ),
                  const SizedBox(
                    width: 20,
                  ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                          mail_.length > 17
                              ? '${mail_.substring(0, 17)}...'
                              : mail_,
                          style: const TextStyle(
                              color: Colors.black,
                              fontSize: 23,
                              fontWeight: FontWeight.normal,
                              fontFamily: 'be')),
                      const Text("Email",
                          style: TextStyle(
                              color: Color.fromARGB(255, 190, 190, 190),
                              fontSize: 20,
                              fontWeight: FontWeight.normal,
                              fontFamily: 'be')),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(
            height: 7,
          ),
          SizedBox(
            width: MediaQuery.of(context).size.width - 20,
            height: 78.3,
            child: ElevatedButton(
              onPressed: () {
                showGeneralDialog(
                  context: context,
                  barrierDismissible: true,
                  barrierLabel: '',
                  barrierColor: Colors.transparent,
                  transitionDuration: const Duration(milliseconds: 100),
                  pageBuilder: (BuildContext context,
                      Animation<double> animation,
                      Animation<double> secondaryAnimation) {
                    return Center(
                      child: Container(
                        height: MediaQuery.of(context).size.height,
                        width: MediaQuery.of(context).size.width,
                        color: Colors.transparent,
                        child: MsgWidget(
                          title: 'Reset your Password?',
                          description: "We'll send a password reset email.",
                          action1: 'Cancel',
                          action2: 'Confirm',
                          onAction1: () {
                            Navigator.of(context).pop();
                          },
                          onAction2: () {
                            Navigator.of(context).pop();
                            sendPasswordReset(user.email!);
                            Navigator.of(context).pushReplacement(
                              MaterialPageRoute(
                                  builder: (context) => const SignIn(
                                      error:
                                          "Check your inbox for a password reset email.")),
                            );
                          },
                        ),
                      ),
                    );
                  },
                );
              },
              style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  disabledForegroundColor: Colors.transparent,
                  disabledBackgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  surfaceTintColor: Colors.transparent,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                  alignment: Alignment.centerLeft,
                  padding: const EdgeInsets.all(0)),
              child: Row(
                children: [
                  const SizedBox(
                    width: 5,
                  ),
                  const Icon(
                    Icons.lock_outline,
                    color: Colors.black54,
                    size: 35,
                  ),
                  const SizedBox(
                    width: 17,
                  ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                          pass_.length > 3
                              ? '*' * (pass_.length - 3) +
                                  pass_.substring(pass_.length - 3)
                              : pass_,
                          style: const TextStyle(
                              color: Colors.black,
                              fontSize: 23,
                              fontWeight: FontWeight.normal,
                              fontFamily: 'be')),
                      const Text("Password",
                          style: TextStyle(
                              color: Color.fromARGB(255, 190, 190, 190),
                              fontSize: 20,
                              fontWeight: FontWeight.normal,
                              fontFamily: 'be')),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(
            height: 7,
          ),
          SizedBox(
            width: MediaQuery.of(context).size.width - 20,
            height: 78.3,
            child: ElevatedButton(
              onPressed: () {
                _openUpdageDialog(age ?? 0);
              },
              style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  disabledForegroundColor: Colors.transparent,
                  disabledBackgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  surfaceTintColor: Colors.transparent,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                  alignment: Alignment.centerLeft,
                  padding: const EdgeInsets.all(0)),
              child: Row(
                children: [
                  const SizedBox(
                    width: 10,
                  ),
                  const Icon(
                    FontAwesomeIcons.clock,
                    color: Colors.black54,
                    size: 28.5,
                  ),
                  const SizedBox(
                    width: 20,
                  ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(age_.toString(),
                          style: const TextStyle(
                              color: Colors.black,
                              fontSize: 23,
                              fontWeight: FontWeight.normal,
                              fontFamily: 'be')),
                      const Text("Age",
                          style: TextStyle(
                              color: Color.fromARGB(255, 190, 190, 190),
                              fontSize: 20,
                              fontWeight: FontWeight.normal,
                              fontFamily: 'be')),
                    ],
                  ),
                ],
              ),
            ),
          ),
          SizedBox(
            height: 75,
            child: isUpdate
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
                        style: const TextStyle(fontSize: 17, color: Colors.red),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
          ),
          SizedBox(
              width: MediaQuery.of(context).size.width - 40,
              height: 54,
              child: ElevatedButton(
                  onPressed: () {
                    updateUData(
                      nam!,
                      age!,
                      userData['type'],
                    );
                    updateUserEmail(mail!, isMail);
                  },
                  style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.white,
                      backgroundColor: Colors.black,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      )),
                  child: const Text(
                    "Update your profile details",
                    style:
                        TextStyle(fontSize: 20, fontWeight: FontWeight.normal),
                  ))),
        ]),
      ),
    );
  }
}
