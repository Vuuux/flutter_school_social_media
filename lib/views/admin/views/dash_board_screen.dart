import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:luanvanflutter/style/loading.dart';
import 'package:luanvanflutter/views/admin/components/custom_appbar.dart';
import 'package:luanvanflutter/views/admin/controllers/dashboard_controller.dart';
import 'package:luanvanflutter/views/admin/views/users/users_screen.dart';

import 'dashboard_content.dart';
import '../components/drawer_menu.dart';
import 'package:provider/provider.dart';

import '../constants/constants.dart';
import '../constants/responsive.dart';
import '../controllers/menu_controller.dart';

enum Section { DASHBOARD, USERS, REPORTS, POSTS }

class DashBoardScreen extends StatefulWidget {
  const DashBoardScreen({Key? key}) : super(key: key);

  @override
  State<DashBoardScreen> createState() => _DashBoardScreenState();
}

class _DashBoardScreenState extends State<DashBoardScreen> {
  late PageController _pageController;
  final _dashboardController = Get.put(DashboardController());
  double currentPageValue = 0.0;

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () async {
      await _dashboardController.getAlLData();
    });
    _pageController = PageController();
    _pageController.addListener(() {
      setState(() {
        currentPageValue = _pageController.page!;
        _dashboardController.getAlLData();
      });
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    Get.delete<DashboardController>();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      drawer: DrawerMenu(pageController: _pageController),
      key: context.read<MenuController>().scaffoldKey,
      appBar: CustomAppbar(),
      body: Obx(() =>
          _dashboardController.requestStatus.value == RequestStatus.LOADING
              ? Loading()
              : SafeArea(
                  top: false,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (Responsive.isDesktop(context))
                        Expanded(
                          child: DrawerMenu(pageController: _pageController),
                        ),
                      Expanded(
                          flex: 5,
                          child: PageView(
                            controller: _pageController,
                            children: <Widget>[
                              DashboardContent(
                                dashboardController: _dashboardController,
                              ),
                              UserManagementScreen(
                                dashboardController: _dashboardController,
                              )
                            ],
                          )
                          //DashboardContent(),
                          )
                    ],
                  ),
                )),
    );
  }
}
