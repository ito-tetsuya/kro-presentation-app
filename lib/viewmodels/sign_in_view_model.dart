import 'package:flutter/material.dart';
import 'package:flutter_sample/commons/router_event_stream.dart';
import 'package:flutter_sample/commons/web_socket.dart';
import 'package:flutter_sample/models/user.dart';
import 'package:flutter_sample/viewmodels/change_notifier_base.dart';
import 'package:flutter_sample/views/pages/user_list.dart';

class SignInViewModel extends ChangeNotifierBase {

  final key = GlobalKey<FormState>();
  final mailController = TextEditingController();
  final passwordController = TextEditingController();

  Future<void> submit() async {
    if (!key.currentState!.validate()) {
      return;
    }
    try {
      print('aaaa');
      await User.signIn(mailController.text, passwordController.text);
      WebSocket.enter(User.signInUser!.id);
      RouterEventStream().pushNamed(UserList());
    } catch (e) {
      print(e);
    }
  }

}