import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:luanvanflutter/style/loading.dart';
import 'package:luanvanflutter/views/admin/components/analytic_cards.dart';
import 'package:luanvanflutter/views/admin/components/custom_appbar.dart';
import 'package:luanvanflutter/views/admin/components/top_referals.dart';
import 'package:luanvanflutter/views/admin/components/users_data_session.dart';
import 'package:luanvanflutter/views/admin/components/users_by_device.dart';
import 'package:luanvanflutter/views/admin/components/viewers.dart';
import 'package:luanvanflutter/views/admin/controllers/dashboard_controller.dart';

import '../constants/constants.dart';
import '../constants/responsive.dart';
import '../components/discussions.dart';

class DashboardContent extends StatefulWidget {
  final DashboardController dashboardController;
  const DashboardContent({Key? key, required this.dashboardController})
      : super(key: key);

  @override
  State<DashboardContent> createState() => _DashboardContentState();
}

class _DashboardContentState extends State<DashboardContent> {
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Obx(() => widget.dashboardController.requestStatus.value ==
              RequestStatus.LOADING
          ? Loading()
          : SingleChildScrollView(
              padding: EdgeInsets.all(appPadding),
              child: Column(
                children: [
                  //CustomAppbar(),
                  SizedBox(
                    height: appPadding,
                  ),
                  Column(
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            flex: 5,
                            child: Column(
                              children: [
                                AnalyticCards(),
                                SizedBox(
                                  height: appPadding,
                                ),
                                Users(),
                                if (Responsive.isMobile(context))
                                  SizedBox(
                                    height: appPadding,
                                  ),
                                if (Responsive.isMobile(context))
                                  Discussions(
                                    dashboardController:
                                        widget.dashboardController,
                                  ),
                              ],
                            ),
                          ),
                          if (!Responsive.isMobile(context))
                            SizedBox(
                              width: appPadding,
                            ),
                          if (!Responsive.isMobile(context))
                            Expanded(
                              flex: 2,
                              child: Discussions(
                                dashboardController: widget.dashboardController,
                              ),
                            ),
                        ],
                      ),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            flex: 5,
                            child: Column(
                              children: [
                                SizedBox(
                                  height: appPadding,
                                ),
                                Row(
                                  children: [
                                    if (!Responsive.isMobile(context))
                                      Expanded(
                                        child: TopReferals(),
                                        flex: 2,
                                      ),
                                    if (!Responsive.isMobile(context))
                                      SizedBox(
                                        width: appPadding,
                                      ),
                                    Expanded(
                                      flex: 3,
                                      child: Viewers(),
                                    ),
                                  ],
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                ),
                                SizedBox(
                                  height: appPadding,
                                ),
                                if (Responsive.isMobile(context))
                                  SizedBox(
                                    height: appPadding,
                                  ),
                                if (Responsive.isMobile(context)) TopReferals(),
                                if (Responsive.isMobile(context))
                                  SizedBox(
                                    height: appPadding,
                                  ),
                                if (Responsive.isMobile(context))
                                  UsersByDevice(),
                              ],
                            ),
                          ),
                          if (!Responsive.isMobile(context))
                            SizedBox(
                              width: appPadding,
                            ),
                          if (!Responsive.isMobile(context))
                            Expanded(
                              flex: 2,
                              child: UsersByDevice(),
                            ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            )),
    );
  }
}
