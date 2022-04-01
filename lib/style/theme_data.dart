import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'constants.dart';

// This is our  main focus
// Let's apply light and dark theme on our app
// Now let's add dark theme on our app

class Themes {
  static final light = ThemeData(
    backgroundColor: kPrimaryBackgroundColor,
    primaryColor: kPrimaryColor,
    //appBarTheme: appBarTheme,
    brightness: Brightness.light,
    iconTheme: const IconThemeData(color: kContentColorLightTheme),
    colorScheme: const ColorScheme.light(
      primary: kPrimaryColor,
      secondary: kSecondaryColor,
      error: kErrorColor,
    ),
    textTheme: GoogleFonts.latoTextTheme().apply(
        bodyColor: kContentColorLightTheme,
        displayColor: kContentColorLightTheme),
  );

  static final dark = ThemeData(
    backgroundColor: kSelectedBackgroudColor,
    primaryColor: kPrimaryDarkColor,
    appBarTheme: darkAppBarTheme,
    iconTheme: const IconThemeData(color: kContentColorDarkTheme),
    brightness: Brightness.dark,
    colorScheme: const ColorScheme.dark(
      primary: kPrimaryDarkColor,
      secondary: kPrimaryDarkColor,
      error: kErrorColor,
    ),
    textTheme: GoogleFonts.latoTextTheme().apply(
        bodyColor: kTextBodyDarkTheme, displayColor: kTextDisplayDarkTheme),
  );
}

final darkAppBarTheme = AppBarTheme(
    color: kPrimaryDarkColor,
    centerTitle: true,
    titleTextStyle:
        GoogleFonts.lato().copyWith(fontSize: 20, fontWeight: FontWeight.bold),
    elevation: 0);

final lightAppBarTheme = AppBarTheme(
    color: kPrimaryColor,
    centerTitle: true,
    titleTextStyle:
        GoogleFonts.lato().copyWith(fontSize: 20, fontWeight: FontWeight.bold),
    elevation: 0);
