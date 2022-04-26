import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:luanvanflutter/views/authenticate/login_screen.dart';
import 'package:luanvanflutter/views/authenticate/welcome_screen.dart';
import 'package:provider/provider.dart';
import 'package:luanvanflutter/models/user.dart';
import 'package:luanvanflutter/controller/controller.dart';
import 'package:luanvanflutter/home.dart';

class Wrapper extends StatelessWidget {
  bool firstlog = true;
  @override
  Widget build(BuildContext context) {
    final user = context.watch<CurrentUserId?>();
    print('Current user:' + user.toString());
    if (user == null) {
      return const WelcomeScreen();
    } else {
      return const Home();
    }
  }
}
