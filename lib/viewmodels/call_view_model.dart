import 'package:flutter_sample/commons/rtc.dart';
import 'package:flutter_sample/commons/web_socket.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';

import 'change_notifier_base.dart';

class CallViewModel extends ChangeNotifierBase {
  bool isReady = false;
  final renderer = RTCVideoRenderer();

  void init () async {
    await renderer.initialize();
  }

  Future<void> renderStart(MediaStream stream) async {
    try {
      await renderer.initialize();
      renderer.srcObject = stream;
      isReady = true;
      customNotifyListeners();
    } catch (e) {
      print(e.toString());
    }
  }

  @override
  dispose() {
    super.dispose();
    renderer.dispose();
  }
}
