import 'package:flutter/material.dart';

class CommonForm extends StatelessWidget {

  final GlobalKey<FormState> key;
  final Widget child;

  CommonForm({ required this.key, required this.child });

  @override
  Widget build(BuildContext context) {
    return Container(
      // key: key,
      padding: EdgeInsets.all(10),
      child: child,
    );
  }
}
