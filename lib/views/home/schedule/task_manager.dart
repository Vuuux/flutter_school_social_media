import 'package:date_picker_timeline/date_picker_timeline.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:luanvanflutter/style/constants.dart';
import 'package:luanvanflutter/style/text_style.dart';
import 'package:luanvanflutter/utils/dimen.dart';
import 'package:luanvanflutter/utils/theme_service.dart';
import 'package:luanvanflutter/utils/widget_extensions.dart';
import 'package:luanvanflutter/views/components/app_bar/standard_app_bar.dart';
import 'package:luanvanflutter/views/home/schedule/add_task_screen.dart';

class TaskManagerPage extends StatefulWidget {
  const TaskManagerPage({Key? key}) : super(key: key);

  @override
  State<TaskManagerPage> createState() => _TaskManagerPageState();
}

class _TaskManagerPageState extends State<TaskManagerPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: StandardAppBar(
        title: 'C Ô N G   V I Ệ C',
        trailingIcon: Icons.post_add_outlined,
        onTrailingClick: () {
          Get.to(AddTaskScreen());
        },
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildDateBar()
              .padding(EdgeInsets.symmetric(vertical: Dimen.paddingCommon15)),
          _buildDateSlider(),
        ],
      ),
    );
  }

  Widget _buildDateBar() => Container(
        margin: EdgeInsets.symmetric(horizontal: Dimen.paddingCommon20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              DateFormat.yMMMd().format(DateTime.now()),
              style: subHeadingStyle,
            ),
            Text("Today")
          ],
        ),
      );

  Widget _buildDateSlider() => Container(
        child: DatePicker(
          DateTime.now(),
          height: 100,
          width: 80,
          initialSelectedDate: DateTime.now(),
          selectionColor: ThemeService().isDarkTheme
              ? kSecondaryDarkColor
              : kSecondaryColor,
          deactivatedColor: kSelectedBackgroudColor,
          selectedTextColor: Colors.white,
          dateTextStyle: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: ThemeService().isDarkTheme
                  ? kPrimaryDarkColor
                  : kPrimaryColor),
        ),
      );
}
