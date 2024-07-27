import 'package:flutter/material.dart';

class SquaredButton extends StatelessWidget {
  final void Function()? onPressed;
  final String buttonLabel;
  final Icon buttonIcon;
  final Color fillColor;
  final Color borderColor;
  final double elevation;

  SquaredButton(
      {required this.buttonLabel,
      required this.onPressed,
      required this.buttonIcon,
      required this.fillColor,
      required this.borderColor,
      required this.elevation});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          RawMaterialButton(
            enableFeedback: true,
            padding:
                const EdgeInsets.symmetric(horizontal: 15.0, vertical: 15.0),
            onPressed: onPressed,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30.0),
              side: BorderSide(color: borderColor, width: 2.0),
            ),
            elevation: elevation, // Customize the elevation
            fillColor: fillColor,
            child: Column(
              children: [
                buttonIcon,
              ],
            ),
          ),
          const SizedBox(
            height: 12.0,
          ),
          Text(
            buttonLabel,
            style: const TextStyle(
                color: Colors.black,
                fontSize: 21.0,
                fontWeight: FontWeight.w700,
                height: 1.2),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
