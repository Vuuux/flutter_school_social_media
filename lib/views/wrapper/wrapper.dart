import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:luanvanflutter/controller/auth_controller.dart';
import 'package:luanvanflutter/controller/controller.dart';
import 'package:luanvanflutter/style/loading.dart';
import 'package:luanvanflutter/utils/user_data_service.dart';
import 'package:luanvanflutter/views/admin/views/dash_board_screen.dart';
import 'package:luanvanflutter/views/authenticate/login_screen.dart';
import 'package:luanvanflutter/views/authenticate/welcome_screen.dart';
import 'package:provider/provider.dart';
import 'package:luanvanflutter/models/user.dart';
import 'package:luanvanflutter/home.dart';

class Wrapper extends StatelessWidget {
  bool firstlog = true;

  Wrapper({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    final user = context.watch<CurrentUserId?>();
    if (user != null) {
      return StreamBuilder<UserData?>(
          stream: DatabaseServices(uid: user.uid).userData,
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              UserData? userData = snapshot.data;
              if (userData != null) {
                if (!userData.enabled) {
                  context.read<AuthService>().signOut().then((value) =>
                      Get.snackbar("Đăng nhập thất bại",
                          "Tài khoản của bạn đã bị khóa! Vui lòng liên hệ người quản trị để mở lại!"));
                } else {
                  UserDataService().saveUserData(userData);
                  return userData.role == 'admin'
                      ? DashBoardScreen()
                      : const Home();
                }
              } else {
                context.read<AuthService>().deleteUser().then((value) =>
                    Get.snackbar(
                        "Đăng nhập thất bại", "Tài khoản của bạn đã bị xóa!"));
              }
            }
            return Loading();
          });
    }
    return WelcomeScreen();
  }
}
