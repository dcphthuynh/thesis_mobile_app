import 'package:flutter/material.dart';

class CustomTextField extends StatefulWidget {
  final String textFieldLabel;
  final TextEditingController textEditingController;
  final bool isPassword;
  final bool isLong;
  final String? label;
  final bool onChanged;
  final bool? isTimer;
  final Function(String)? onChangedFunction;

  const CustomTextField(
      {super.key,
      required this.textFieldLabel,
      required this.textEditingController,
      this.isPassword = false,
      this.isLong = false,
      this.label,
      this.onChanged = false,
      this.onChangedFunction,
      this.isTimer});

  @override
  _CustomTextFieldState createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  bool _isPasswordVisible = false;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      cursorColor: Colors.black,
      keyboardType: (widget.isTimer != null)
          ? TextInputType.number
          : TextInputType.multiline,
      validator: (value) {
        if (value == null || value.isEmpty) {
          if (widget.label != null) {
            if (widget.isTimer != null && widget.isTimer!) {
              if (!RegExp(r'^[0-9]+$').hasMatch(value!)) {
                return 'Please enter a valid number';
              }
            }
            return '${widget.label} is required';
          }

          return '${widget.textFieldLabel} is required';
        }
        return null;
      },
      style: const TextStyle(
          color: Colors.black,
          fontSize: 16.0,
          fontWeight: FontWeight.w600,
          fontFamily: 'Urbanist'),
      controller: widget.textEditingController,
      obscureText: widget.isPassword && !_isPasswordVisible,
      maxLines: widget.isLong ? 3 : 1,
      minLines: 1,
      decoration: InputDecoration(
        enabledBorder: const OutlineInputBorder(
          borderSide: BorderSide(
            color: Colors.grey,
            width: 1.0,
          ),
        ),
        focusedBorder: const OutlineInputBorder(
          borderSide: BorderSide(
            color: Colors.black,
            width: 2.0,
          ),
        ),
        filled: true,
        fillColor: const Color.fromRGBO(247, 248, 249, 1.0),
        contentPadding: const EdgeInsets.all(19.5),
        border: const OutlineInputBorder(),
        labelText: widget.textFieldLabel,
        labelStyle: const TextStyle(
            color: Colors.black,
            fontSize: 18.0,
            fontWeight: FontWeight.w500,
            fontFamily: 'Urbanist'),
        suffixIcon: widget.isPassword
            ? TextButton(
                onPressed: () {
                  setState(() {
                    _isPasswordVisible = !_isPasswordVisible;
                  });
                },
                child: _isPasswordVisible
                    ? const Icon(
                        Icons.visibility_off,
                        color: Colors.black,
                      )
                    : const Icon(Icons.visibility, color: Colors.black),
                // 'Hide' : 'Show',
              )
            : null,
      ),
      onChanged: widget.onChanged ? widget.onChangedFunction : null,
    );
  }
}
