import 'package:flutter/material.dart';
import 'package:flutter_sample/commons/common.dart';
import 'package:flutter_svg/flutter_svg.dart';

class UserImage extends StatelessWidget {

  final String? path;
  final double radius;

  UserImage({ required this.path, required this.radius });

  @override
  Widget build(BuildContext context) {
    if (path == null || path!.isEmpty) {
      return CircleAvatar(
        radius: radius,
        backgroundColor: Colors.white,
        child: Icon(
          Icons.account_circle,
          size: radius * 2,
        ),
      );
    }
    return CircleAvatar(
      radius: radius,
      backgroundImage: NetworkImage(Common.getImageUrl(path!)),
    );
  }
}
