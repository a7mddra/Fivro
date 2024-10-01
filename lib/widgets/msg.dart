import 'package:flutter/material.dart';

class MsgWidget extends StatelessWidget {
  final String title;
  final String description;
  final String action1;
  final String action2;
  final VoidCallback onAction1;
  final VoidCallback onAction2;

  const MsgWidget({
    super.key,
    required this.title,
    required this.description,
    required this.action1,
    required this.action2,
    required this.onAction1,
    required this.onAction2,
  });

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
          padding: const EdgeInsets.only(bottom: 100),
          child: Stack(
            children: [
              Center(
                child: Container(
                  height: 138,
                  width: 270,
                  decoration: BoxDecoration(
                    color: const Color.fromARGB(255, 240, 240, 240),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(bottom: 13),
                        child: Material(
                          color: Colors.transparent,
                          child: Text(
                            title,
                            style: const TextStyle(
                              fontSize: 18.5,
                              fontWeight: FontWeight.w600,
                              color: Colors.black,
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: Material(
                          color: Colors.transparent,
                          child: Text(
                            description,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w400,
                              color: Colors.black,
                            ),
                            textAlign: TextAlign.center,
                          ),
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
                                onPressed: onAction1,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.transparent,
                                  shadowColor: Colors.black.withOpacity(0),
                                  elevation: 0,
                                  shape: const RoundedRectangleBorder(
                                    borderRadius: BorderRadius.only(
                                      bottomLeft: Radius.circular(20),
                                    ),
                                  ),
                                ),
                                child: Text(
                                  action1,
                                  style: const TextStyle(
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
                                onPressed: onAction2,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.transparent,
                                  shadowColor: Colors.black.withOpacity(0),
                                  elevation: 0,
                                  shape: const RoundedRectangleBorder(
                                    borderRadius: BorderRadius.only(
                                      bottomRight: Radius.circular(20),
                                    ),
                                  ),
                                ),
                                child: Text(
                                  action2,
                                  style: const TextStyle(
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
            ],
          ),
        ),
      ]),
    );
  }
}
