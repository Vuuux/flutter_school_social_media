import 'package:flutter/material.dart';
import 'package:luanvanflutter/style/constants.dart';
import 'package:luanvanflutter/utils/dimen.dart';

class TextFieldContainer extends StatelessWidget {
  final Widget child;

  const TextFieldContainer({
    Key? key,
    required this.child,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Container(
      margin: EdgeInsets.symmetric(vertical: Dimen.paddingCommon10),
      padding:
          EdgeInsets.symmetric(horizontal: Dimen.paddingCommon20, vertical: 5),
      decoration: BoxDecoration(
        border: Border.all(width: 1.0),
        color: kPrimaryLightColor,
        borderRadius: BorderRadius.circular(60),
      ),
      child: child,
    );
  }
}
