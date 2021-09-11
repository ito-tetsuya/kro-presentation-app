import 'package:flutter/material.dart';

class CommonInputText extends StatelessWidget {

  final TextEditingController controller;
  final String label;
  final bool obscure;

  CommonInputText({
    required this.controller,
    required this.label,
    this.obscure = false,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      obscureText: obscure,
      decoration: InputDecoration(
        labelText: label,
      ),
    );
  }
}
