import 'package:flutter/material.dart';

class ProgressCircle extends StatefulWidget {
  final Color color; // Couleur passée au widget

  const ProgressCircle({super.key, this.color = Colors.white});

  @override
  _ProgressCircleState createState() => _ProgressCircleState();
}

class _ProgressCircleState extends State<ProgressCircle> {
  bool _isVisible = false;

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) {
        setState(() {
          _isVisible = true;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return _isVisible
        ? CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation(
                widget.color), // Utilisez la couleur passée
          )
        : const SizedBox.shrink();
  }
}
