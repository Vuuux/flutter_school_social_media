import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_state_manager/src/rx_flutter/rx_obx_widget.dart';
import 'package:luanvanflutter/models/post.dart';
import 'package:luanvanflutter/models/report.dart';
import 'package:luanvanflutter/models/user.dart';
import 'package:luanvanflutter/style/constants.dart';
import 'package:luanvanflutter/utils/dimen.dart';
import 'package:luanvanflutter/views/admin/components/custom_appbar.dart';
import 'package:luanvanflutter/views/admin/components/discussion_info_detail.dart';
import 'package:luanvanflutter/views/admin/components/drawer_menu.dart';
import 'package:luanvanflutter/views/admin/constants/constants.dart';
import 'package:luanvanflutter/views/admin/controllers/dashboard_controller.dart';
import 'package:luanvanflutter/views/admin/controllers/menu_controller.dart';
import 'package:luanvanflutter/views/admin/views/posts/widgets/post_tile_items.dart';
import 'package:luanvanflutter/views/admin/views/reports/widgets/report_tile_items.dart';
import 'package:luanvanflutter/views/authenticate/register_screen.dart';
import 'package:luanvanflutter/views/components/buttons/bottom_sheet_button.dart';
import 'package:luanvanflutter/views/home/feed/post_detail.dart';
import 'package:provider/provider.dart';

class ReportManagementScreen extends StatefulWidget {
  final DashboardController dashboardController;
  const ReportManagementScreen({Key? key, required this.dashboardController})
      : super(key: key);

  @override
  State<ReportManagementScreen> createState() => _ReportManagementScreenState();
}

class _ReportManagementScreenState extends State<ReportManagementScreen> {
  @override
  void initState() {
    super.initState();
    widget.dashboardController.getAllReports();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: RefreshIndicator(
        onRefresh: () async {
          widget.dashboardController.getAllReports();
          return;
        },
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(appPadding),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Danh sách bài viết',
                    style: TextStyle(
                      color: textColor,
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () async {
                      // await Get.to(() => Register(
                      //   isFromAdmin: true,
                      // ));
                      // widget.dashboardController.getAllReports();
                    },
                    child: const Text("Thêm"),
                    style: ElevatedButton.styleFrom(
                        primary: Colors.blue,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 15, vertical: 10),
                        textStyle: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold)),
                  )
                ],
              ),
              Obx(() => ListView.builder(
                  physics: const NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  itemCount: widget.dashboardController.reportList.length,
                  itemBuilder: (context, index) {
                    return ReportInfoDetail(
                      reportInfo: widget.dashboardController.reportList[index],
                      onTapMore: () => _showBottomSheet(context,
                          widget.dashboardController.reportList[index]),
                    );
                  }))
            ],
          ),
        ),
      ),
    );
  }

  _showBottomSheet(BuildContext context, ReportModel report) {
    Get.bottomSheet(Container(
      color: Colors.white,
      padding: const EdgeInsets.only(top: 4),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            height: 6,
            width: 120,
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: Get.isDarkMode ? Colors.grey[600] : Colors.grey[300]),
          ),
          BottomSheetButton(
                  label: "Xem bài viết",
                  color: kWarninngColor,
                  textColor: Colors.black,
                  onTap: () async {
                    Get.to(() => PostDetail(
                        postId: report.postId, ownerId: report.ownerId));
                  })
              .marginOnly(
                  bottom: Dimen.paddingCommon10, top: Dimen.paddingCommon10),
          BottomSheetButton(
              label: "Phê duyệt bài viết",
              color: Colors.greenAccent,
              textColor: Colors.black,
              onTap: () async {
                await widget.dashboardController
                    .validateReport(report: report, status: "approved");
                widget.dashboardController.getAllReports();
                Get.back();
              }).marginOnly(bottom: Dimen.paddingCommon10),
          BottomSheetButton(
              label: "Xóa bài viết",
              color: kErrorColor,
              textColor: Colors.white,
              onTap: () async {
                widget.dashboardController
                    .deletePost(postId: report.postId, userId: report.ownerId);
                widget.dashboardController.getAllReports();
                Get.back();
              }).marginOnly(bottom: Dimen.paddingCommon10),
          BottomSheetButton(
              label: "Đóng",
              color: Colors.white,
              isClose: true,
              onTap: () {
                Get.back();
              }),
        ],
      ),
    ));
  }
}
