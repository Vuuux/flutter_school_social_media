import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_state_manager/src/rx_flutter/rx_obx_widget.dart';
import 'package:luanvanflutter/models/user.dart';
import 'package:luanvanflutter/style/constants.dart';
import 'package:luanvanflutter/utils/dimen.dart';
import 'package:luanvanflutter/views/admin/components/custom_appbar.dart';
import 'package:luanvanflutter/views/admin/components/discussion_info_detail.dart';
import 'package:luanvanflutter/views/admin/components/drawer_menu.dart';
import 'package:luanvanflutter/views/admin/constants/constants.dart';
import 'package:luanvanflutter/views/admin/controllers/dashboard_controller.dart';
import 'package:luanvanflutter/views/admin/controllers/menu_controller.dart';
import 'package:luanvanflutter/views/components/buttons/bottom_sheet_button.dart';
import 'package:provider/provider.dart';

class UserManagementScreen extends StatefulWidget {
  final DashboardController dashboardController;
  const UserManagementScreen({Key? key, required this.dashboardController})
      : super(key: key);

  @override
  State<UserManagementScreen> createState() => _UserManagementScreenState();
}

class _UserManagementScreenState extends State<UserManagementScreen> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: RefreshIndicator(
        onRefresh: () async {
          widget.dashboardController.getAllUsers();
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
                  Text(
                    'Danh sách người dùng',
                    style: TextStyle(
                      color: textColor,
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                    ),
                  ),
                ],
              ),
              Obx(() => ListView.builder(
                  physics: const NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  itemCount: widget.dashboardController.userList.length,
                  itemBuilder: (context, index) {
                    if (widget.dashboardController.userList[index].role !=
                        'admin') {
                      return DiscussionInfoDetail(
                        info: widget.dashboardController.userList[index],
                        onTapMore: () => _showBottomSheet(context,
                            widget.dashboardController.userList[index]),
                      );
                    }
                    return SizedBox.shrink();
                  }))
            ],
          ),
        ),
      ),
    );
  }

  _showBottomSheet(BuildContext context, UserData user) {
    Get.bottomSheet(Container(
      color: Colors.white,
      padding: const EdgeInsets.only(top: 4),
      height: MediaQuery.of(context).size.height * 0.32,
      child: Column(
        children: [
          Container(
            height: 6,
            width: 120,
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: Get.isDarkMode ? Colors.grey[600] : Colors.grey[300]),
          ),
          BottomSheetButton(
                  label: user.enabled == "disabled"
                      ? "Mở khóa tài khoản"
                      : "Khóa tài khoản",
                  color: kWarninngColor,
                  textColor: Colors.black,
                  onTap: () async {
                    user.enabled == "disabled"
                        ? widget.dashboardController
                            .enableUser(context: context, userId: user.id)
                        : widget.dashboardController
                            .disableUser(context: context, userId: user.id);
                  })
              .marginOnly(
                  bottom: Dimen.paddingCommon10, top: Dimen.paddingCommon10),
          BottomSheetButton(
              label: "Xóa",
              color: kErrorColor,
              textColor: Colors.white,
              onTap: () async {
                widget.dashboardController
                    .deleteUser(context: context, userId: user.id);
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
