import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_sample/views/pages/sign_in.dart';

/// ViewModelからの画面遷移呼び出し用Streamクラス
/// indexページでListen
class RouterEventStream extends ChangeNotifier {

  // シングルトンなコンストラクタ
  factory RouterEventStream() => _instance;
  static final RouterEventStream _instance = RouterEventStream._internal();
  RouterEventStream._internal();

  final _routerAction = StreamController<Function(BuildContext)>();
  Stream get stream => _routerAction.stream;
  // Streamの監視が開始されているか
  bool isListened = false;

  /// 画面遷移
  void pushNamed(Widget widget, { Object? args }) =>
      _routerAction.sink.add((BuildContext context) =>
          Navigator.push(context, MaterialPageRoute(builder: (_) => widget)));

  /// 画面を一つ戻す
  void pop({ Object? args }) => _routerAction.sink.add((BuildContext context) {
    final navigator = Navigator.of(context);
    if (navigator.canPop()) {
      navigator.pop(args);
    }
  });

  void showCustomDialog(Function builder) {
    _routerAction.sink.add((BuildContext context) =>
      showDialog(
        context: context,
        barrierDismissible: false, // 周りを押下してもダイアログを閉じない
        builder: (_) => builder(_),
      )
    );
  }

  @override
  void dispose() {
    super.dispose();
    _routerAction.close();
  }

}
