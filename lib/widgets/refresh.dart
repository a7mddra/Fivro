import 'package:flutter/material.dart';

class Refresh extends StatefulWidget {
  final void Function()? logic;
  final bool isLoading;
  const Refresh({super.key, required this.logic, required this.isLoading});

  @override
  RefreshState createState() => RefreshState();
}

class RefreshState extends State<Refresh> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  double _lastStopPosition = 0.0;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant Refresh oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.isLoading && !_controller.isAnimating) {
      _controller.repeat();
    } else if (!widget.isLoading && _controller.isAnimating) {
      _lastStopPosition = _controller.value;
      _controller.stop();

      final remainingRotation = 1.0 - _lastStopPosition;
      final remainingDuration = Duration(
        milliseconds:
            (remainingRotation * _controller.duration!.inMilliseconds).toInt(),
      );

      _controller.animateTo(1.0, duration: remainingDuration).then((_) {
        _controller.value = 0.0;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: RotationTransition(
        turns: _controller,
        child: const Icon(Icons.refresh),
      ),
      onPressed: widget.isLoading ? null : widget.logic,
    );
  }
}
