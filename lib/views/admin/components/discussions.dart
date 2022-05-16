import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:luanvanflutter/models/user.dart';
import 'package:luanvanflutter/style/constants.dart';
import 'package:luanvanflutter/utils/dimen.dart';
import 'package:luanvanflutter/views/admin/constants/constants.dart';
import 'package:luanvanflutter/views/admin/controllers/dashboard_controller.dart';
import 'package:luanvanflutter/views/components/buttons/bottom_sheet_button.dart';

import 'discussion_info_detail.dart';

class Discussions extends StatefulWidget {
  final DashboardController dashboardController;
  const Discussions({Key? key, required this.dashboardController})
      : super(key: key);

  @override
  State<Discussions> createState() => _DiscussionsState();
}

class _DiscussionsState extends State<Discussions> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 540,
      padding: EdgeInsets.all(appPadding),
      decoration: BoxDecoration(
        color: secondaryColor,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
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
              Text(
                'Xem tất cả',
                style: TextStyle(
                  color: textColor.withOpacity(0.5),
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
            ],
          ),
          const SizedBox(
            height: appPadding,
          ),
          Obx(() => Expanded(
                child: ListView.builder(
                  physics: const NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  itemCount: widget.dashboardController.userList.length,
                  itemBuilder: (context, index) => DiscussionInfoDetail(
                    info: widget.dashboardController.userList[index],
                    onTapMore: () => _showBottomSheet(
                        context, widget.dashboardController.userList[index]),
                  ),
                ),
              ))
        ],
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
              label: "Khóa tài khoản",
              color: kWarninngColor,
              textColor: Colors.black,
              onTap: () async {
                widget.dashboardController
                    .deleteUser(context: context, userId: user.id);
              }).marginOnly(bottom: Dimen.paddingCommon20),
          BottomSheetButton(
              label: "Xóa",
              color: kErrorColor,
              textColor: Colors.black,
              onTap: () async {
                widget.dashboardController
                    .deleteUser(context: context, userId: user.id);
              }).marginOnly(bottom: Dimen.paddingCommon20),
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
