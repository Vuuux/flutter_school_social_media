import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:date_picker_timeline/date_picker_timeline.dart';
import 'package:either_dart/either.dart';
import 'package:eventual/eventual-notifier.dart';
import 'package:eventual/eventual-single-builder.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:luanvanflutter/controller/auth_controller.dart';
import 'package:luanvanflutter/controller/controller.dart';
import 'package:luanvanflutter/controller/task_controller.dart';
import 'package:luanvanflutter/models/task.dart';
import 'package:luanvanflutter/style/constants.dart';
import 'package:luanvanflutter/style/loading.dart';
import 'package:luanvanflutter/style/text_style.dart';
import 'package:luanvanflutter/utils/dimen.dart';
import 'package:luanvanflutter/utils/notify_service.dart';
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
  final _taskController = Get.put(TaskController());
  late NotifyHelper notifyHelper;
  // late Stream<Either<QuerySnapshot, FirebaseException>> taskStream;
  @override
  void initState() {
    super.initState();
    notifyHelper = NotifyHelper();
    _taskController.getTasks();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: StandardAppBar(
        title: 'C Ô N G   V I Ệ C',
        trailingIcon: Icons.post_add_outlined,
        onTrailingClick: () async {
          await Get.to(() => const AddTaskScreen());
          _taskController.getTasks();
        },
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildDateBar()
              .padding(EdgeInsets.symmetric(vertical: Dimen.paddingCommon15)),
          _buildDateSlider(),
          _buildTaskList(),
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

  Widget _buildTaskList() => Obx(() {
        return Expanded(
          child: ListView.separated(
              itemCount: _taskController.taskList.length,
              separatorBuilder: (BuildContext context, int index) {
                return const Divider(
                  height: 1,
                  thickness: 1,
                );
              },
              shrinkWrap: true,
              itemBuilder: (context, index) {
                return SizedBox(
                  height: 50,
                  child: Container(
                    color: Colors.red,
                  ),
                );
              }),
        );
      });
}
