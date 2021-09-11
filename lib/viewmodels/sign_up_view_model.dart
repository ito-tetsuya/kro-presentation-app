import 'dart:convert';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_sample/commons/router_event_stream.dart';
import 'package:flutter_sample/models/user.dart';
import 'package:flutter_sample/views/pages/user_list.dart';

import 'change_notifier_base.dart';

class SignUpViewModel extends ChangeNotifierBase {
  final key = GlobalKey<FormState>();
  final nameController = TextEditingController();
  final mailController = TextEditingController();
  final passwordController = TextEditingController();
  Uint8List? pickImage;
  String? pickImageExt;
  Uint8List? image;
  String? imageExt;

  Future<void> getImage() async {
    FilePickerResult? pickFile = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['jpeg', 'jpg', 'png']
    );
    if (pickFile != null) {
      PlatformFile file = pickFile.files.first;
      pickImage = file.bytes;
      pickImageExt = file.extension;
      customNotifyListeners();
    }
  }

  void setTrimImage(Uint8List newImage) {
    image = newImage;
    imageExt = pickImageExt;
    _onEndPick();
    customNotifyListeners();
  }

  void onCancelTrim() {
    _onEndPick();
  }

  void removeImage() {
    image = null;
    imageExt = null;
    customNotifyListeners();
  }

  void _onEndPick() {
    pickImage = null;
    pickImageExt = null;
  }

  Future<void> submit() async {
    if (!key.currentState!.validate()) {
      return;
    }
    final body = {
      'email': mailController.text,
      'password': passwordController.text,
      'nickname': nameController.text,
      'image': image != null ? base64.encode(image!) : '',
      'ext': imageExt != null ? imageExt : '',
    };
    await User.signUp(body);
    RouterEventStream().pop();
  }

}