import 'package:flutter/material.dart';

import 'components/dashboard_content.dart';
import 'components/drawer_menu.dart';
import 'package:provider/provider.dart';

import 'constants/constants.dart';
import 'constants/responsive.dart';
import 'controllers/controller.dart';

class DashBoardScreen extends StatelessWidget {
  const DashBoardScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      drawer: DrawerMenu(),
      key: context.read<Controller>().scaffoldKey,
      body: SafeArea(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (Responsive.isDesktop(context))
              Expanded(
                child: DrawerMenu(),
              ),
            Expanded(
              flex: 5,
              child: DashboardContent(),
            )
          ],
        ),
      ),
    );
  }
}
