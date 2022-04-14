import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class Constants {
  static String myName = "";
  static String myEmail = "";
  static String nickname = "";
  static RegExp EMAIL_REGEX = RegExp(
      "(\w{1,}[b]\d{1,7})@(\w+\.||)+(ctu.edu.vn)",
      caseSensitive: false,
      multiLine: false);
}

class Photo {
  final String photo;

  Photo(this.photo);
}

const textInputDecoration = InputDecoration(
  fillColor: Colors.blueGrey,
  filled: true,
  enabledBorder: OutlineInputBorder(
      borderSide: BorderSide(color: Colors.blueGrey, width: 2.0)),
  focusedBorder: OutlineInputBorder(
      borderSide: BorderSide(color: Colors.blueGrey, width: 2.0)),
);

const kSpacingUnit = 10;
const kSelectedBackgroudColor = Color(0xFFD9D9D9);
const kPrimaryDarkBackgroundColor = Color(0xFF3D3D3D);
const kPrimaryDarkColor = Color(0xFFFFD154);
const kSecondaryDarkColor = Color(0xFFFFCC36);
const kPrimaryColor = Color(0xFFC20000);
const kPrimaryBackgroundColor = Color(0xFFD9D9D9);
const kSecondaryColor = Color(0xFF717171);
//const kPrimaryColor = Color(0xFF6F35A5);
const kPrimaryLightColor = Color(0xFFFFD154);
const kContentColorLightTheme = Color(0xFF1D1D35);
const kContentColorDarkTheme = Color(0xFFF5FCF9);
const kGreenColor = Color(0xFF02EC88);
const kWarninngColor = Color(0xFFF3BB1C);
const kErrorColor = Color(0xFFF03738);

//Text color
const kTextBodyDarkTheme = Color(0xFFF5FCF9);
const kTextDisplayDarkTheme = Color(0xFFBABABA);

const kDefaultPadding = 20.0;
//Forum color
const kStudyColor = Colors.lightBlueAccent;
const kQuestionColor = Colors.amber;
const kAdviseColor = Colors.pinkAccent;
const kSecretColor = Colors.deepPurpleAccent;
const kSupportColor = Colors.red;

const Color bluishColor = Color(0xFF4e5ae8);
const Color yellowColor = Color(0xFFFB746);
const Color white = Colors.white;
const Color black = Colors.black;
const primaryColor = kPrimaryColor;
const Color darkGreyColor = Color(0xFF121212);

class FadeRoute extends PageRouteBuilder {
  final Widget page;
  FadeRoute({required this.page})
      : super(
          pageBuilder: (
            BuildContext context,
            Animation<double> animation,
            Animation<double> secondaryAnimation,
          ) =>
              page,
          transitionsBuilder: (
            BuildContext context,
            Animation<double> animation,
            Animation<double> secondaryAnimation,
            Widget child,
          ) =>
              FadeTransition(
            opacity: animation,
            child: child,
          ),
        );
}
