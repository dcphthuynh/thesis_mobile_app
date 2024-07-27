import 'package:flutter/material.dart';

class SliderValueTextField extends StatefulWidget {
  final String textFieldLabel;
  final TextEditingController textEditingController;
  final bool isValue;
  final bool onChanged;
  final Function(String)? onChangedFunction;

  const SliderValueTextField(
      {super.key,
      required this.textFieldLabel,
      required this.textEditingController,
      this.onChanged = false,
      this.onChangedFunction,
      required this.isValue});

  @override
  _SliderValueTextFieldState createState() => _SliderValueTextFieldState();
}

class _SliderValueTextFieldState extends State<SliderValueTextField> {
  @override
  Widget build(BuildContext context) {
    return TextFormField(
      validator: (value) {
        if (value == null || value.isEmpty) {
          return '${widget.textFieldLabel} is required';
        }
        if (widget.isValue) {
          if (!RegExp(r'^-?[0-9]+(\.[0-9]*)?$').hasMatch(value)) {
            return 'Please enter a valid number';
          }
        }

        return null;
      },
      style: const TextStyle(
          color: Colors.black,
          fontSize: 16.0,
          fontWeight: FontWeight.w600,
          fontFamily: 'Urbanist'),
      controller: widget.textEditingController,
      decoration: InputDecoration(
        filled: true,
        fillColor: const Color.fromRGBO(247, 248, 249, 1.0),
        border: const OutlineInputBorder(),
        labelText: widget.textFieldLabel,
        labelStyle: const TextStyle(
            fontFamily: 'Urbanist',
            fontWeight: FontWeight.w500,
            fontSize: 16.0),
      ),
      keyboardType: widget.isValue ? TextInputType.datetime : null,
      onChanged: widget.onChanged ? widget.onChangedFunction : null,
    );
  }
}
