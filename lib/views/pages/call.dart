import 'package:flutter/material.dart';
import 'package:flutter_sample/commons/web_socket.dart';
import 'package:flutter_sample/viewmodels/call_view_model.dart';
import 'package:flutter_sample/views/components/common_scaffold.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:provider/provider.dart';

class Call extends StatelessWidget {
  final String nickname;
  Call({ required this.nickname });

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => CallViewModel()..init(),
      child: CommonScaffold(
        appBarText: nickname,
        body: StreamBuilder<MessageInfo>(
          stream: WebSocket.mediaStream,
          builder: (context, AsyncSnapshot<MessageInfo> snapShot) {
            if (!snapShot.hasData) {
              print('StreamBuilder まだはやい');
              return Container();
            }
            print('StreamBuilder きてます');
            return Consumer<CallViewModel>(
              builder: (context, viewModel, _) {
                viewModel.renderer.srcObject = snapShot.data!.stream!;
                return Container(
                  width: double.infinity,
                  height: double.infinity,
                  child: Stack(
                    children: [
                      RTCVideoView(viewModel.renderer),
                      Align(
                          alignment: Alignment.bottomCenter,
                          child: IconButton(
                            onPressed: () => Navigator.pop(context),
                            icon: Icon(Icons.call_end),
                            color: Colors.red,
                          )
                      ),
                    ],
                  ),
                );
              }
            );
          },
        ),
      ),
    );
  }
}
