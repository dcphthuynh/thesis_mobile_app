import 'package:flutter/material.dart';

class RoundedButton extends StatelessWidget {
  final VoidCallback onPressed;
  final String buttonLabel;
  final bool isBlack;

  RoundedButton(
      {required this.buttonLabel,
      required this.onPressed,
      required this.isBlack});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        elevation: 6.0,
        backgroundColor: isBlack ? Colors.black : Colors.white,
        minimumSize: const Size(160, 60),
      ),
      onPressed: onPressed,
      child: Text(
        buttonLabel,
        style: TextStyle(
            color: isBlack ? Colors.white : Colors.black,
            fontSize: 22.0,
            fontWeight: FontWeight.w800,
            fontFamily: 'Urbanist'),
      ),
    );
  }
}
