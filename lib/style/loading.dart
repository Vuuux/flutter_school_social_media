import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:luanvanflutter/style/constants.dart';
import 'package:luanvanflutter/utils/theme_service.dart';

class Loading extends StatelessWidget {
  const Loading({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(color: Colors.white.withOpacity(0.2)),
      child: Center(
        child: SpinKitFoldingCube(
          color: ThemeService().isDarkTheme ? kPrimaryDarkColor : kPrimaryColor,
          size: 50,
        ),
      ),
    );
  }
}
