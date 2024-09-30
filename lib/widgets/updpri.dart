import 'dart:ui';
import 'package:car_rental_a7md/widgets/text_feild_input.dart';
import 'package:flutter/material.dart';

@immutable
class Updpri extends StatefulWidget {
  final int? pri;

  const Updpri({
    super.key,
    required this.pri,
  });

  @override
  State<Updpri> createState() => _UpdpriState();
}

class _UpdpriState extends State<Updpri> with WidgetsBindingObserver {
  late TextEditingController _priController;
  String error = '';
  @override
  void initState() {
    super.initState();
    _priController = TextEditingController(text: widget.pri.toString());
  }

  @override
  void dispose() {
    _priController.dispose();
    super.dispose();
  }

  void _confirmForm() {
    if (!RegExp(r'^\d+$').hasMatch(_priController.text)) {
      setState(() {
        error = 'Please type a valid number.';
      });
    } else {
      int pri = int.parse(_priController.text);
      if (pri < 5) {
        setState(() {
          error = 'Minmum price 5\$.';
        });
      } else {
        setState(() {
          error = '';
        });
        Navigator.of(context).pop({
          'price': _priController.text,
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Stack(children: [
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
          child: Stack(
            children: [
              Center(
                child: Padding(
                  padding: const EdgeInsets.only(top: 70),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                      child: Container(
                        height: 30 +
                            (2 / 14.5 * MediaQuery.of(context).size.height) +
                            30,
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
                            SizedBox(
                              width: MediaQuery.of(context).size.width - 36 * 2,
                              child: Material(
                                child: TextFeildInput(
                                  textEditingController: _priController,
                                  hintText: "price \$/day",
                                  textInputType: TextInputType.text,
                                ),
                              ),
                            ),
                            SizedBox(
                              height: 30,
                              child: Text(
                                error,
                                style: const TextStyle(
                                    fontSize: 17, color: Colors.red),
                                textAlign: TextAlign.center,
                              ),
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Container(
                                    height: MediaQuery.of(context).size.height *
                                        0.17 *
                                        1 /
                                        2.8,
                                    color: Colors.transparent,
                                    child: ElevatedButton(
                                      onPressed: () {
                                        Navigator.of(context).pop();
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.transparent,
                                        shadowColor:
                                            Colors.black.withOpacity(0),
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
                                const SizedBox(width: 0),
                                Expanded(
                                  child: Container(
                                    height: MediaQuery.of(context).size.height *
                                        0.17 *
                                        1 /
                                        2.8,
                                    color: Colors.transparent,
                                    child: ElevatedButton(
                                      onPressed: () {
                                        _confirmForm();
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.transparent,
                                        shadowColor:
                                            Colors.black.withOpacity(0),
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
            ],
          ),
        ),
      ]),
    );
  }
}
