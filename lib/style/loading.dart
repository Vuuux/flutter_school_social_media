import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:luanvanflutter/style/constants.dart';

class Loading extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(color: Colors.black54),
      child: Center(
        child: SpinKitFoldingCube(
          color: kPrimaryLightColor,
          size: 50,
        ),
      ),
    );
  }
}
