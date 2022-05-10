import 'package:date_picker_timeline/date_picker_timeline.dart';
import 'package:eventual/eventual-notifier.dart';
import 'package:eventual/eventual-single-builder.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:luanvanflutter/controller/task_controller.dart';
import 'package:luanvanflutter/models/task.dart';
import 'package:luanvanflutter/style/constants.dart';
import 'package:luanvanflutter/style/text_style.dart';
import 'package:luanvanflutter/utils/date_utils.dart';
import 'package:luanvanflutter/utils/dimen.dart';
import 'package:luanvanflutter/utils/notify_service.dart';
import 'package:luanvanflutter/utils/theme_service.dart';
import 'package:luanvanflutter/utils/widget_extensions.dart';
import 'package:luanvanflutter/views/components/app_bar/standard_app_bar.dart';
import 'package:luanvanflutter/views/components/buttons/bottom_sheet_button.dart';
import 'package:luanvanflutter/views/home/feed/components/custom_snackbar.dart';
import 'package:luanvanflutter/views/home/task/task_tile.dart';

import 'add_task_screen.dart';

class TaskManagerPage extends StatefulWidget {
  const TaskManagerPage({Key? key}) : super(key: key);

  @override
  State<TaskManagerPage> createState() => _TaskManagerPageState();
}

class _TaskManagerPageState extends State<TaskManagerPage> {
  final _taskController = Get.put(TaskController());
  late NotifyHelper notifyHelper;
  final DateFormat _dateFormat = MyDateUtils.getFormatter;
  final EventualNotifier<DateTime> _selectedDate =
      EventualNotifier<DateTime>(DateTime.now());
  // late Stream<Either<QuerySnapshot, FirebaseException>> taskStream;
  @override
  void initState() {
    super.initState();
    notifyHelper = NotifyHelper();
    notifyHelper.initializeNotification();
    Future.delayed(Duration.zero, () {
      _taskController.getTasks();
    });
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
      body: EventualSingleBuilder(
          notifier: _selectedDate,
          builder: (context, notifier, child) {
            DateTime selectedDate = notifier.value;
            return Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildDateBar().padding(
                    EdgeInsets.symmetric(vertical: Dimen.paddingCommon15)),
                _buildDateSlider(selectedDate)
                    .paddingOnly(bottom: Dimen.paddingCommon15),
                _buildTaskList(selectedDate),
              ],
            );
          }),
    );
  }

  Widget _buildDateBar() => Container(
        margin: EdgeInsets.symmetric(horizontal: Dimen.paddingCommon20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _dateFormat.format(DateTime.now()),
              style: subHeadingStyle,
            ),
            const Text("Hôm nay")
          ],
        ),
      );

  Widget _buildDateSlider(DateTime selectedDate) => Container(
        margin: EdgeInsets.symmetric(horizontal: Dimen.paddingCommon15),
        child: DatePicker(
          DateTime.now(),
          height: 100,
          width: 80,
          initialSelectedDate: selectedDate,
          selectionColor:
              ThemeService().isDarkTheme ? kPrimaryDarkColor : kPrimaryColor,
          deactivatedColor: kSelectedBackgroudColor,
          selectedTextColor: Colors.white,
          dateTextStyle: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: ThemeService().isDarkTheme
                  ? kPrimaryDarkColor
                  : kPrimaryColor),
          onDateChange: (date) {
            _selectedDate.value = date;
          },
        ),
      );

  Widget _buildTaskList(DateTime selectedDate) => Obx(() {
        return Expanded(
          child: ListView.builder(
              itemCount: _taskController.taskList.length,
              shrinkWrap: true,
              itemBuilder: (context, index) {
                TaskSchedule task = _taskController.taskList[index];
                DateTime dateOfTask = _dateFormat.parse(task.date);
                if (task.scheduleMode == ScheduleMode.DAILY ||
                    (task.scheduleMode == ScheduleMode.MONTHLY &&
                        dateOfTask.month == DateTime.now().month &&
                        dateOfTask.day == _selectedDate.value.day) ||
                    (task.scheduleMode == ScheduleMode.WEEKLY &&
                        dateOfTask.weekday == _selectedDate.value.weekday)) {
                  return AnimationConfiguration.staggeredList(
                    position: index,
                    child: SlideAnimation(
                      child: FadeInAnimation(
                        child: Row(
                          children: [
                            GestureDetector(
                              onTap: () {
                                _showBottomSheet(context, task);
                              },
                              child: TaskTile(
                                task: task,
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                  );
                }

                if (task.date == _dateFormat.format(selectedDate)) {
                  DateTime date =
                      DateFormat.jm().parse(task.startTime.toString());
                  String myTime = DateFormat("HH:mm").format(date);
                  notifyHelper.scheduledNotification(
                      index,
                      int.parse(myTime.split(":")[0]),
                      int.parse(myTime.split(":")[1]),
                      task);
                  return AnimationConfiguration.staggeredList(
                    position: index,
                    child: SlideAnimation(
                      child: FadeInAnimation(
                        child: Row(
                          children: [
                            GestureDetector(
                              onTap: () {
                                _showBottomSheet(context, task);
                              },
                              child: TaskTile(
                                task: task,
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                  );
                } else {
                  return const SizedBox.shrink();
                }
              }),
        );
      });

  _showBottomSheet(BuildContext context, TaskSchedule task) {
    Get.bottomSheet(Container(
      padding: const EdgeInsets.only(top: 4),
      height: task.isCompleted
          ? MediaQuery.of(context).size.height * 0.24
          : MediaQuery.of(context).size.height * 0.32,
      color: Get.isDarkMode ? darkGreyColor : Colors.white,
      child: Column(
        children: [
          Container(
            height: 6,
            width: 120,
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: Get.isDarkMode ? Colors.grey[600] : Colors.grey[300]),
          ),
          task.isCompleted
              ? Container()
              : BottomSheetButton(
                      label: "Đánh dấu đã hoàn thành",
                      color: kGreenColor,
                      onTap: () async {
                        var response = await _taskController.updateTask(
                            taskId: task.taskId);
                        response.fold((left) async {
                          if (left) {
                            _taskController.getTasks();
                            Get.back();
                            CustomBottomSnackBar(
                                    title: "Cập nhật thành công",
                                    text:
                                        "Chúc mừng bạn đã hoàn thành công việc")
                                .createSnackBar();
                          }
                        }, (right) {
                          Get.back();
                          CustomBottomSnackBar(
                                  title: "Lỗi",
                                  text: "Có lỗi xảy ra: " + right.code)
                              .createSnackBar();
                        });
                      })
                  .marginOnly(
                      top: Dimen.paddingCommon10, bottom: Dimen.paddingCommon4),
          BottomSheetButton(
              label: "Xóa",
              color: kWarninngColor,
              textColor: Colors.black,
              onTap: () async {
                var response =
                    await _taskController.deleteTask(taskId: task.taskId);
                response.fold((left) async {
                  Get.back();
                  await _taskController.getTasks();
                  Get.back();
                  CustomBottomSnackBar(
                          title: "Xóa thành công",
                          text: "Xóa công việc thành công")
                      .createSnackBar();
                }, (right) {
                  Get.back();
                  CustomBottomSnackBar(
                          title: "Lỗi", text: "Có lỗi xảy ra: " + right.code)
                      .createSnackBar();
                });
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
