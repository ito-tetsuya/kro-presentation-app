import 'package:flutter/material.dart';
import 'package:flutter_sample/components/common_button.dart';
import 'package:flutter_sample/components/common_form.dart';
import 'package:flutter_sample/components/common_input_text.dart';
import 'package:flutter_sample/components/common_scaffold.dart';

class Login extends StatelessWidget {

  final mailController = TextEditingController();
  final passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return CommonScaffold(
      appBarText: 'ログイン',
      body: Container(
        width: double.infinity,
        height: double.infinity,
        // color: Colors.grey,
        child: Container(
          margin: EdgeInsets.all(10),
          child: Card(
            elevation: 8.0,
            
            child: CommonForm(
              key: GlobalKey<FormState>(),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CommonInputText(
                    controller: mailController,
                    label: 'メールアドレス',
                  ),
                  SizedBox(
                    height: 30,
                  ),
                  CommonInputText(
                    controller: passwordController,
                    label: 'パスワード',
                    obscure: true,
                  ),
                  SizedBox(
                    height: 30,
                  ),
                  CommonButton(label: 'ログイン'),
                  SizedBox(
                    height: 30,
                  ),
                  CommonButton(label: 'アカウント登録'),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
