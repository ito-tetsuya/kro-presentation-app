import 'package:flutter_sample/commons/router_event_stream.dart';
import 'package:flutter_sample/commons/rtc.dart';
import 'package:flutter_sample/models/user.dart';
import 'package:flutter_sample/views/pages/call.dart';

import 'change_notifier_base.dart';
import 'package:flutter_sample/commons/web_socket.dart';

class DialogViewModel extends ChangeNotifierBase {

  void call(int userId, String nickname) {
    print('call');
    WebSocket.call(userId, User.signInUser!.id);
    RouterEventStream().pushNamed(Call(nickname: nickname,));
  }

  Future<void> accept(int userId, String nickname) async {
    await Rtc.makeOffer(userId);
    RouterEventStream().pushNamed(Call(nickname: nickname,));
  }

  Future<void> decline(int userId) async {
    WebSocket.hangup(userId, User.signInUser!.id);
  }
}
