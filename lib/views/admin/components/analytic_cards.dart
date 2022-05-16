import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:luanvanflutter/views/admin/controllers/dashboard_controller.dart';
import 'package:luanvanflutter/views/admin/data/data.dart';

import '../constants/constants.dart';
import '../constants/responsive.dart';
import 'analytic_info_card.dart';

class AnalyticCards extends StatelessWidget {
  AnalyticCards({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    return Container(
      child: Responsive(
        mobile: AnalyticInfoCardGridView(
          crossAxisCount: size.width < 650 ? 2 : 4,
          childAspectRatio: size.width < 650 ? 2 : 1.5,
        ),
        tablet: AnalyticInfoCardGridView(),
        desktop: AnalyticInfoCardGridView(
          childAspectRatio: size.width < 1400 ? 1.5 : 2.1,
        ),
      ),
    );
  }
}

class AnalyticInfoCardGridView extends StatelessWidget {
  final _dashboardController = Get.put(DashboardController());

  AnalyticInfoCardGridView({
    Key? key,
    this.crossAxisCount = 4,
    this.childAspectRatio = 1.4,
  }) : super(key: key);

  final int crossAxisCount;
  final double childAspectRatio;

  @override
  Widget build(BuildContext context) {
    List<int> dataCount = [
      _dashboardController.userList.length,
      _dashboardController.postList.length,
      _dashboardController.reportList.length,
      _dashboardController.forumList.length
    ];
    return GridView.builder(
      physics: NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemCount: analyticData.length,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        crossAxisSpacing: appPadding,
        mainAxisSpacing: appPadding,
        childAspectRatio: childAspectRatio,
      ),
      itemBuilder: (context, index) {
        analyticData[index].count = dataCount[index];
        return AnalyticInfoCard(
          info: analyticData[index],
        );
      },
    );
  }
}
