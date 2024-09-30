import 'package:flutter/material.dart';

class ZoomOut extends PageRouteBuilder {
  final Widget page;
  final Duration duration;

  ZoomOut(
      {required this.page, this.duration = const Duration(milliseconds: 150)})
      : super(
          pageBuilder: (context, animation, secondaryAnimation) => page,
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            const begin = 0.0;
            const end = 1.0;
            const curve = Curves.easeIn;

            var fadeAnimation =
                Tween<double>(begin: begin, end: end).animate(CurvedAnimation(
              parent: animation,
              curve: curve,
            ));

            var scaleAnimation =
                Tween<double>(begin: 1.5, end: 1.0).animate(CurvedAnimation(
              parent: animation,
              curve: curve,
            ));

            return FadeTransition(
              opacity: fadeAnimation,
              child: ScaleTransition(
                scale: scaleAnimation,
                child: child,
              ),
            );
          },
          transitionDuration: duration,
        );
}
