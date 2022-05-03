import 'package:flutter/material.dart';
import 'package:luanvanflutter/controller/auth_controller.dart';
import 'package:luanvanflutter/views/admin/components/drawer_list_tile.dart';
import 'package:luanvanflutter/views/admin/constants/constants.dart';
import 'package:provider/provider.dart';

class DrawerMenu extends StatelessWidget {
  const DrawerMenu({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        children: [
          Container(
            padding: EdgeInsets.all(appPadding),
            child: Image.asset(
              "assets/images/appicon.png",
              height: 64,
              width: 64,
            ),
          ),
          DrawerListTile(
              title: 'Dash Board',
              svgSrc: 'assets/icons/Dashboard.svg',
              tap: () {}),
          DrawerListTile(
              title: 'Quản lý người dùng',
              svgSrc: 'assets/icons/BlogPost.svg',
              tap: () {}),
          DrawerListTile(
              title: 'Quản lý báo cáo',
              svgSrc: 'assets/icons/Message.svg',
              tap: () {}),
          DrawerListTile(
              title: 'Thống kê',
              svgSrc: 'assets/icons/Statistics.svg',
              tap: () {}),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: appPadding * 2),
            child: Divider(
              color: grey,
              thickness: 0.2,
            ),
          ),
          DrawerListTile(
              title: 'Cài đặt', svgSrc: 'assets/icons/Setting.svg', tap: () {}),
          DrawerListTile(
              title: 'Đăng xuất',
              svgSrc: 'assets/icons/Logout.svg',
              tap: () async {
                await context.read<AuthService>().signOut();
              }),
        ],
      ),
    );
  }
}
