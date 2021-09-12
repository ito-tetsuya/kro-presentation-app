import 'dart:async';
import 'package:flutter_sample/commons/rtc.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_sample/viewmodels/list_view_model.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

import 'common.dart';
import 'env.dart';

class WebSocket extends ChangeNotifier {
  static IO.Socket? socket;
  static final _callAction = StreamController<MessageInfo>();
  static Stream<MessageInfo> get callStream => _callAction.stream;
  static final _mediaAction = StreamController<MessageInfo>.broadcast();
  static Stream<MessageInfo> get mediaStream => _mediaAction.stream;
  static bool isListListen = false;
  static bool isCallListen = false;

  static void init() {
    socket = IO.io(
      '${Env.getSchema()}://${Env.getDomain()}',
      <String, dynamic>{ 'transports': ['websocket'], 'autoConnect': false, },
    );
    print(socket);
    socket!.onConnect((_) {
      print('WebSocket Connect');
    });
    socket!.on('entered', (data) {
      print('entered $data');
    });
    socket!.on('call', (data) {
      _callAction.sink.add(MessageInfo(userId: data['fromId']));
    });
    socket!.on('sendOffer', (data) {
      Rtc.setOffer(data);
    });
    socket!.on('sendAnswer', (data) {
      Rtc.setAnswer(data);
    });
    socket!.on('candidate', (data) {
      Rtc.addCandidate(data);
    });
    socket!.on('hangup', (data) {
      Rtc.hangup();
      _mediaAction.sink.add(MessageInfo());
    });
    socket!.connect();
  }

  static void enter(int userId) {
    socket!.emit('enter', {'id': userId});
  }

  static void call(int targetId, int fromId) {
    socket!.emit('call', {'targetId': targetId, 'fromId': fromId});
  }

  static void sendOffer(Map<String, dynamic> info) {
    socket!.emit('sendOffer', info);
  }

  static void sendAnswer(Map<String, dynamic> info) {
    socket!.emit('sendAnswer', info);
  }

  static void sendCandidate(Map<String, dynamic> info) {
    socket!.emit('candidate', info);
  }

  static void hangup(int targetId, int fromId) {
    socket!.emit('hangup', {'targetId': targetId, 'fromId': fromId});
  }

  static void onAddTrack(MediaStream stream) {
    _mediaAction.sink.add(MessageInfo(stream: stream));
  }

  @override
  void dispose() {
    super.dispose();
    _callAction.close();
    _mediaAction.close();
  }
}

class MessageInfo {
  final int? userId;
  final MediaStream? stream;

  MessageInfo({
    this.userId,
    this.stream
  });
}
