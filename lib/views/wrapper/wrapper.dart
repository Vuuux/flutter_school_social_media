import 'package:flutter/material.dart';
import 'package:luanvanflutter/controller/controller.dart';
import 'package:luanvanflutter/style/loading.dart';
import 'package:luanvanflutter/utils/user_data_service.dart';
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
    //DatabaseServices services = context.watch<DatabaseServices>();
    if (user != null) {
      return StreamBuilder<UserData?>(
          stream: DatabaseServices(uid: user.uid).userData,
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              UserData? userData = snapshot.data;
              UserDataService().saveUserData(userData!);
              return userData.role == 'admin'
                  ? const DashBoardScreen()
                  : const Home();
            }
            return Loading();
          });
    }
    return WelcomeScreen();
  }
}
