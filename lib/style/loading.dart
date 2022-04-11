import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:luanvanflutter/style/constants.dart';
import 'package:luanvanflutter/utils/theme_service.dart';

class Loading extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(color: Colors.black54),
      child: Center(
        child: SpinKitFoldingCube(
          color: ThemeService().isDarkTheme ? kPrimaryDarkColor : kPrimaryColor,
          size: 50,
        ),
      ),
    );
  }
}
