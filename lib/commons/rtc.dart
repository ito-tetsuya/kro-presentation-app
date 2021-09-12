import 'dart:async';

import 'package:flutter_sample/models/user.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:flutter_sample/commons/web_socket.dart';

class Rtc {
  static RTCPeerConnection? connection;
  static int? toId;
  static MediaStream? localStream;

  static Future<void> makeOffer(int targetId) async {
    print('sendOffer start');
    connection = await _createPeerConnection(targetId);
    final sdp = await connection!.createOffer();
    await connection!.setLocalDescription(sdp);
    await _sendSessionDescription((info) => WebSocket.sendOffer(info));
    print('sendOffer end');
  }

  static Future<void> setOffer(Map<String, dynamic> info) async {
    print('setOffer start');
    connection = await _createPeerConnection(info['fromId']);
    await connection!.setRemoteDescription(RTCSessionDescription(info['sdp'], info['type']));
    await _makeAnswer();
    print('setOffer end');
  }

  static Future<void> _makeAnswer() async {
    print('_makeAnswer start');
    final sdp = await connection!.createAnswer();
    await connection!.setLocalDescription(sdp);
    await _sendSessionDescription((info) => WebSocket.sendAnswer(info));
    print('_makeAnswer end');
  }

  static Future<void> setAnswer(Map<String, dynamic> info) async {
    print('setAnswer start');
    await connection!.setRemoteDescription(RTCSessionDescription(info['sdp'], info['type']));
    print('setAnswer end');
  }

  static Future<RTCPeerConnection> _createPeerConnection(int targetId) async {
    if (_isConnect(targetId)) {
      return connection!;
    }
    toId = targetId;
    localStream = await _getLocalUserMedia();
    const config = {
      'sdpSemantics': 'unified-plan',
      'iceServers': [
        {
          'urls': ['stun:stun1.l.google.com:19302']
        }
      ],
      'bundlePolicy': 'max-compat',
    };
    final peer = await createPeerConnection(config);
    // localストリームを設定
    localStream!.getTracks().forEach((track) {
      peer.addTrack(track, localStream!);
    });
    peer.onRemoveStream = (event) {
      print('--------------onRemoveStream--------------');
      if (toId != null) {
        hangup();
      }
    };
    // 相手のストリーム受信時
    peer.onTrack = (event) {
      print('--------------onTrack--------------');
      if (event.track.kind == 'video') {
        WebSocket.onAddTrack(event.streams[0]);
      }
    };
    // candidate
    peer.onIceCandidate = (candidate) {
      print('----------onIceCandidate-------------');
      final info = {
        'targetId': targetId,
        'candidate': candidate.candidate,
        'sdpMid': candidate.sdpMid,
        'sdpMLineIndex': candidate.sdpMlineIndex,
      };
      WebSocket.sendCandidate(info);
    };
    return peer;
  }

  static void addCandidate(Map<String, dynamic> info) {
    if (connection != null) {
      print('------addCandidate------');
      connection!.addCandidate(
          RTCIceCandidate(
              info['candidate'],
              info['sdpMid'],
              info['sdpMLineIndex']
          )
      );
    }
  }

  static bool _isConnect(int targetId) {
    return toId != targetId && connection != null;
  }

  static Future<void> _sendSessionDescription(Function sendFunc) async {
    final description = await connection!.getLocalDescription();
    final info = {
      'targetId': toId,
      'fromId': User.signInUser!.id,
      'type': description!.type,
      'sdp': description.sdp,
    };
    sendFunc(info);
  }

  static Future<MediaStream> _getLocalUserMedia() async {
    final Map<String, dynamic> mediaConstraints = {
      'audio': true,
      'video': {
        'mandatory': {
          'minWidth': '640',
          'minHeight': '480',
          'minFrameRate': '30',
        },
        ...WebRTC.platformIsDesktop ? {} : {'facingMode': 'user'},
        'optional': [],
      }
    };
    return await navigator.mediaDevices.getUserMedia(mediaConstraints);
  }

  static void hangup() {
    if (toId != null) {
      WebSocket.hangup(toId!, User.signInUser!.id);
    }
    if (connection != null) {
      connection!.close();
      connection = null;
    }
    if (localStream != null) {
      localStream!.getTracks().forEach((track) => track.stop());
      localStream = null;
    }
    toId = null;
  }
}