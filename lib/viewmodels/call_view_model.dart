import 'package:flutter_sample/commons/router_event_stream.dart';
import 'package:flutter_sample/commons/rtc.dart';
import 'package:flutter_sample/commons/web_socket.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';

import 'change_notifier_base.dart';

class CallViewModel extends ChangeNotifierBase {
  bool isReady = false;
  final renderer = RTCVideoRenderer();

  void init () async {
    await renderer.initialize();
    WebSocket.mediaStream.listen((event) {
      if (event.stream != null) {
        renderStart(event.stream!);
      } else {
        print('切断通知--------');
        // 切断通知
        if (!isDisposed) {
          RouterEventStream().pop();
        }
      }
    });
  }

  Future<void> renderStart(MediaStream stream) async {
    try {
      renderer.srcObject = stream;
      isReady = true;
      customNotifyListeners();
    } catch (e) {
      print(e.toString());
    }
  }

  void stopCall() {
    Rtc.hangup();
    print('stopCall--------');
    if (!isReady) {
      RouterEventStream().pop();
    }
  }

  @override
  dispose() {
    super.dispose();
    renderer.dispose();
  }
}
