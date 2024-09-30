import 'dart:typed_data';
import 'dart:ui';
import 'package:car_rental_a7md/utils/utils.dart';
import 'package:car_rental_a7md/widgets/text_feild_input.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class FormWidget extends StatefulWidget {
  const FormWidget({
    super.key,
  });

  @override
  State<FormWidget> createState() => _FormWidgetState();
}

class _FormWidgetState extends State<FormWidget> with WidgetsBindingObserver {
  final TextEditingController _modelController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  Uint8List? _file;
  String error = '';
  bool isError = false;

  @override
  void dispose() {
    _modelController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  _selectImage() async {
    Uint8List file = await pickImage(ImageSource.gallery);
    setState(() {
      _file = file;
    });
  }

  void _confirmForm() {
    if (_file == null ||
        _modelController.text.isEmpty ||
        _priceController.text.isEmpty) {
      setState(() {
        error = "Please enter all required fields.";
        isError = true;
      });
    } else if (!RegExp(r'^\d+$').hasMatch(_priceController.text)) {
      setState(() {
        error = "Please enter a valid number.";
        isError = true;
      });
    } else {
      Navigator.of(context).pop({
        'model': _modelController.text,
        'price': int.parse(_priceController.text),
        'file': _file,
      });
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
                              (MediaQuery.of(context).size.height -
                                  (((MediaQuery.of(context).size.width -
                                                  36 * 2) *
                                              0.5 -
                                          10) *
                                      1.125) -
                                  355) +
                              (3 / 14.5 * MediaQuery.of(context).size.height) +
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
                              Container(
                                  height: MediaQuery.of(context).size.height -
                                      (((MediaQuery.of(context).size.width -
                                                      36 * 2) *
                                                  0.5 -
                                              10) *
                                          1.125) -
                                      355,
                                  width: MediaQuery.of(context).size.width -
                                      36 * 2,
                                  decoration: BoxDecoration(
                                      color: const Color(0xFFF3F3F3),
                                      borderRadius: BorderRadius.circular(20)),
                                  child: _file != null
                                      ? ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(20),
                                          child: Image.memory(
                                            _file!,
                                            fit: BoxFit.contain,
                                          ),
                                        )
                                      : ElevatedButton(
                                          style: ElevatedButton.styleFrom(
                                            foregroundColor: Colors.transparent,
                                            backgroundColor: Colors.transparent,
                                            shadowColor: Colors.transparent,
                                            overlayColor: Colors.transparent,
                                          ),
                                          onPressed: () {
                                            _selectImage();
                                          },
                                          child: const Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.center,
                                            children: [
                                              Icon(
                                                Icons.add_circle_outline,
                                                size: 50,
                                                color: Colors.black,
                                              ),
                                              SizedBox(
                                                height: 8,
                                              ),
                                              Text(
                                                "Add A Photo",
                                                style: TextStyle(
                                                  color: Colors.black,
                                                  fontSize: 19,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              )
                                            ],
                                          ),
                                        )),
                              const SizedBox(height: 30),
                              SizedBox(
                                width:
                                    MediaQuery.of(context).size.width - 36 * 2,
                                child: Material(
                                  child: TextFeildInput(
                                    textEditingController: _modelController,
                                    hintText: "Model",
                                    textInputType: TextInputType.text,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 10),
                              SizedBox(
                                width:
                                    MediaQuery.of(context).size.width - 36 * 2,
                                child: Material(
                                  child: TextFeildInput(
                                    textEditingController: _priceController,
                                    hintText: "Price/day \$",
                                    textInputType: TextInputType.number,
                                  ),
                                ),
                              ),
                              SizedBox(
                                  height: 30,
                                  child: isError
                                      ? Material(
                                          color: Colors.transparent,
                                          child: Center(
                                            child: Text(
                                              error,
                                              style: const TextStyle(
                                                  fontSize: 15,
                                                  color: Colors.red),
                                            ),
                                          ),
                                        )
                                      : null),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Container(
                                      height:
                                          MediaQuery.of(context).size.height *
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
                                  Expanded(
                                    child: Container(
                                      height:
                                          MediaQuery.of(context).size.height *
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
                              const SizedBox(height: 0),
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
        ]));
  }
}
