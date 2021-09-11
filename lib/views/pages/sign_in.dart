import 'package:flutter/material.dart';
import 'package:flutter_sample/commons/router_event_stream.dart';
import 'package:flutter_sample/viewmodels/sign_in_view_model.dart';
import 'package:flutter_sample/views/components/common_button.dart';
import 'package:flutter_sample/views/components/common_form.dart';
import 'package:flutter_sample/views/components/common_input_text.dart';
import 'package:flutter_sample/views/components/common_scaffold.dart';
import 'package:flutter_sample/views/pages/sign_up.dart';
import 'package:provider/provider.dart';

class SignIn extends StatelessWidget {

  @override
  Widget build(BuildContext context) {

    final router = RouterEventStream();
    if (!router.isListened) {
      // viewModel層からのページ遷移イベントを受信
      router.stream.listen((event) => event(context));
      router.isListened = true;
    }

    return ChangeNotifierProvider(
      create: (_) => SignInViewModel(),
      child: CommonScaffold(
        appBarText: 'ログイン',
        body: Container(
          width: double.infinity,
          height: double.infinity,
          // color: Colors.grey,
          child: Container(
            margin: EdgeInsets.all(10),
            child: Card(
              elevation: 8.0,
              child: Padding(
                padding: EdgeInsets.all(10),
                child: Consumer<SignInViewModel>(
                  builder: (context, viewModel, _) {
                    return Form(
                      key: viewModel.key,
                      child: ListView(
                        // mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CommonInputText(
                            controller: viewModel.mailController,
                            label: 'メールアドレス',
                          ),
                          SizedBox(
                            height: 30,
                          ),
                          CommonInputText(
                            controller: viewModel.passwordController,
                            label: 'パスワード',
                            obscure: true,
                          ),
                          SizedBox(
                            height: 30,
                          ),
                          CommonButton(
                            label: 'ログイン',
                            onPressed: () => viewModel.submit(),
                          ),
                          SizedBox(
                            height: 30,
                          ),
                          CommonButton(
                            label: 'アカウント登録',
                            onPressed: () => Navigator.push(
                                context,
                                MaterialPageRoute(builder: (_) => SignUp())
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
