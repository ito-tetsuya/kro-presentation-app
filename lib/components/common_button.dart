import 'package:flutter/material.dart';

class CommonButton extends StatelessWidget {

  final String label;

  CommonButton({ required this.label });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed: () => print('おうか'),
        child: Text(label),
      ),
    );
  }
}
