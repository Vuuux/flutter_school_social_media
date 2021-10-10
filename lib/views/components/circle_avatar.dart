import 'package:flutter/material.dart';
import 'package:luanvanflutter/style/constants.dart';

class CustomCircleAvatar extends StatelessWidget {
  final Widget image;

  const CustomCircleAvatar({Key? key, required this.image}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      backgroundColor: kPrimaryColor,
      radius: 80.0,
      child: CircleAvatar(
        backgroundColor: kPrimaryLightColor,
        radius: 70.0,
        child: ClipOval(
          child: SizedBox(
              width: 180,
              height: 180,
              child: image
          ),
        ),
      ),
    );
  }
}
