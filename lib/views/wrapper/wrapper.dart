import 'package:flutter/material.dart';
import 'package:luanvanflutter/views/admin/dash_board_screen.dart';
import 'package:luanvanflutter/views/authenticate/login_screen.dart';
import 'package:luanvanflutter/views/authenticate/welcome_screen.dart';
import 'package:provider/provider.dart';
import 'package:luanvanflutter/models/user.dart';
import 'package:luanvanflutter/home.dart';

class Wrapper extends StatelessWidget {
  bool firstlog = true;
  @override
  Widget build(BuildContext context) {
    final user = context.watch<CurrentUserId?>();
    UserData userData = context.watch<UserData>();
    if (user == null) {
      return const WelcomeScreen();
    } else if (user != null && userData != null && userData.role != 'admin') {
      return const Home();
    } else
      return DashBoardScreen();
  }
}
