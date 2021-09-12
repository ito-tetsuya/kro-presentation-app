import 'package:flutter/material.dart';
import 'package:flutter_sample/commons/router_event_stream.dart';
import 'package:flutter_sample/commons/web_socket.dart';
import 'package:flutter_sample/models/user.dart';
import 'package:flutter_sample/views/components/receive_dialog.dart';

import 'change_notifier_base.dart';

class ListViewModel extends ChangeNotifierBase {
  bool isReady = false;
  List<User> users = [];
  User? receiveUser;

  Future<void> init() async {
    if (!WebSocket.isListListen) {
      WebSocket.isListListen = !WebSocket.isListListen;
      WebSocket.callStream.listen((MessageInfo info) {
        receiveCall(info.userId!);
      });
    }
    users = await User.getList();
    isReady = true;
    customNotifyListeners();
  }

  void receiveCall(int id) {
    final user = users.firstWhere((user) => user.id == id);
    // customNotifyListeners();
    RouterEventStream().showCustomDialog((_) => ReceiveDialog(user: user));

  }
}
