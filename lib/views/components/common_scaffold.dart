import 'package:flutter/material.dart';

class CommonScaffold extends StatelessWidget {

  final Widget body;
  final String appBarText;

  CommonScaffold({ required this.body, required this.appBarText });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(appBarText),
      ),
      body: body,
    );
  }
}
