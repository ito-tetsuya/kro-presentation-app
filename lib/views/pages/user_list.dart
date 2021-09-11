import 'package:flutter/material.dart';
import 'package:flutter_sample/commons/common.dart';
import 'package:flutter_sample/models/user.dart';
import 'package:flutter_sample/viewmodels/list_view_model.dart';
import 'package:flutter_sample/views/components/call_dialog.dart';
import 'package:flutter_sample/views/components/common_scaffold.dart';
import 'package:flutter_sample/views/components/receive_dialog.dart';
import 'package:flutter_sample/views/components/user_image.dart';
import 'package:provider/provider.dart';

class UserList extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ListViewModel()..init(),
      child: CommonScaffold(
        appBarText: '一覧',
        body: Consumer<ListViewModel>(
          builder: (context, viewModel, _) {
            if (!viewModel.isReady) {
              return Container();
            }
            if (viewModel.receiveUser != null) {
              WidgetsBinding
                  .instance!
                  .addPostFrameCallback(
                      (_) => _showReceiveDialog(context, viewModel.receiveUser!)
              );
            }
            return ListView.builder(
              itemCount: viewModel.users.length,
              itemBuilder: (BuildContext context, int index) {
                final user = viewModel.users[index];
                return Card(
                  elevation: 8,
                  child: ListTile(
                    leading: UserImage(
                      radius: 20,
                      path: user.imagePath,
                    ),
                    title: Text(user.nickName),
                    onTap: () => _showDetailDialog(context, user),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }

  void _showDetailDialog(BuildContext context, User user) {
    showDialog(
      context: context,
      builder: (_) => CallDialog(user: user),
    );
  }

  void _showReceiveDialog(BuildContext context, User user) {
    showDialog(
      context: context,
      builder: (_) => ReceiveDialog(user: user),
    );
  }
}
