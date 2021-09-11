import 'package:flutter/material.dart';
import 'package:flutter_sample/viewmodels/sign_up_view_model.dart';
import 'package:flutter_sample/views/components/common_button.dart';
import 'package:flutter_sample/views/components/common_input_text.dart';
import 'package:flutter_sample/views/components/common_scaffold.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';

import 'image_trim.dart';

class SignUp extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => SignUpViewModel(),
      child: CommonScaffold(
        appBarText: 'アカウント登録',
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
                child: Consumer<SignUpViewModel>(
                  builder: (context, viewModel, _) {
                    return Form(
                      key: viewModel.key,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CommonInputText(
                            controller: viewModel.nameController,
                            label: 'ニックネーム',
                          ),
                          SizedBox(
                            height: 30,
                          ),
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
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Stack(
                                children: [
                                  Container(
                                    decoration: BoxDecoration(
                                      color: Color(0xffF5F5F5),
                                      borderRadius: BorderRadius.circular(5),
                                    ),
                                    child: IconButton(
                                      icon: SvgPicture.asset('assets/icon/camera.svg'),
                                      color: Color(0xff9B9B9B),
                                      iconSize: 150,
                                      onPressed: () async => await _getImage(context),
                                    ),
                                  ),
                                  IgnorePointer(
                                    child: Container(
                                      width: 180,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(5),
                                      ),
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(5),
                                        child: viewModel.image != null
                                            ? Image.memory(
                                                viewModel.image!,
                                                fit: BoxFit.fitHeight,
                                                errorBuilder: (_, __, ___) => Container(),
                                              )
                                            : Container(),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              if (viewModel.image != null)
                                IconButton(
                                  icon: const Icon(
                                    Icons.close,
                                    color: Color(0xff9B9B9B),
                                  ),
                                  color: Color(0xff9B9B9B),
                                  iconSize: 30,
                                  onPressed: () => viewModel.removeImage(),
                                ),
                            ],
                          ),
                          SizedBox(
                            height: 30,
                          ),
                          CommonButton(
                            label: '登録',
                            onPressed: () => viewModel.submit()
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

  Future<void> _getImage(BuildContext context) async {
    final viewModel = context.read<SignUpViewModel>();
    await viewModel.getImage();
    if (viewModel.pickImage != null) {
      print('pickImage');
      final newImage = await Navigator.push(context, MaterialPageRoute(builder: (_) => ImageTrim(image: viewModel.pickImage!)));
      if (newImage != null) {
        viewModel.setTrimImage(newImage);
      } else {
        viewModel.onCancelTrim();
      }
    }
  }
}
