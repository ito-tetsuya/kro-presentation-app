import 'package:flutter/material.dart';
import 'package:flutter_sample/models/user.dart';
import 'package:flutter_sample/viewmodels/dialog_view_model.dart';
import 'package:flutter_sample/views/components/user_image.dart';
import 'package:provider/provider.dart';

class ReceiveDialog extends StatelessWidget {

  final User user;

  ReceiveDialog({required this.user});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Dialog(
      child: ChangeNotifierProvider(
        create: (_) => DialogViewModel(),
        child: Consumer<DialogViewModel>(
          builder: (context, viewModel, _) {
            return Container(
              width: size.width * 0.7,
              height: size.height * 0.5,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  UserImage(
                    radius: 60,
                    path: user.imagePath,
                  ),
                  SizedBox(height: 10,),
                  Text(user.nickName),
                  SizedBox(height: 10,),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        onPressed: () => viewModel.accept(user.id, user.nickName),
                        icon: Icon(
                          Icons.phone_callback,
                          color: Theme.of(context).primaryColor,
                        ),
                      ),
                      IconButton(
                        onPressed: () => print('callend'),
                        icon: Icon(
                          Icons.call_end,
                          color: Colors.red,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
