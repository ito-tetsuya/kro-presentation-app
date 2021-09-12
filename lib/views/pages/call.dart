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
        body: Consumer<CallViewModel>(
          builder: (context, viewModel, _) {
            return WillPopScope(
              onWillPop: () async {
                viewModel.stopCall();
                return false;
              },
              child: Container(
                width: double.infinity,
                height: double.infinity,
                child: Stack(
                  children: [
                    if (viewModel.isReady)
                      RTCVideoView(viewModel.renderer),
                    if (!viewModel.isReady)
                      Align(
                        alignment: Alignment.center,
                        child: SizedBox(
                          width: 50,
                          height: 50,
                          child: CircularProgressIndicator(),
                        ),
                      ),
                    Align(
                        alignment: Alignment.bottomCenter,
                        child: IconButton(
                          onPressed: () => viewModel.stopCall(),
                          icon: Icon(Icons.call_end),
                          color: Colors.red,
                        )
                    ),
                  ],
                ),
              ),
            );
          }
        ),
      ),
    );
  }
}
