import 'package:flutter/material.dart';

class ChangeNotifierBase with ChangeNotifier {
  bool isDisposed = false;

  void customNotifyListeners() {
    if (!isDisposed) {
      notifyListeners();
    }
  }

  @override
  void dispose() {
    isDisposed = true;
    super.dispose();
  }
}