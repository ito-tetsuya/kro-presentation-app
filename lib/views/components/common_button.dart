import 'package:flutter/material.dart';

class CommonButton extends StatelessWidget {

  final String label;
  final Function onPressed;

  CommonButton({ required this.label, required this.onPressed });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed: () => onPressed(),
        child: Text(label),
      ),
    );
  }
}
