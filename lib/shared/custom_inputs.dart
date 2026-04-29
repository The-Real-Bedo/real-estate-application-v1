import 'package:flutter/material.dart';

class CustomTextInput extends StatelessWidget {
  final String hintText;
  final IconData? icon;
  final bool isPassword;
  final TextInputType keyboardType;

  const CustomTextInput({
    Key? key,
    required this.hintText,
    this.icon,
    this.isPassword = false,
    this.keyboardType = TextInputType.text,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      obscureText: isPassword,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        hintText: hintText,
        prefixIcon: icon != null ? Icon(icon) : null,
      ),
    );
  }
}
