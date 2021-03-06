import 'package:flutter/material.dart';

class CommonScaffold extends StatelessWidget {

  final Widget body;
  final String appBarText;
  final bool showBack;

  CommonScaffold({ required this.body, required this.appBarText, this.showBack = true });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: showBack,
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(appBarText),
      ),
      body: body,
    );
  }
}
