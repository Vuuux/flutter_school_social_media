import 'package:eventual/eventual-builder.dart';
import 'package:eventual/eventual-notifier.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:luanvanflutter/controller/auth_controller.dart';
import 'package:luanvanflutter/controller/controller.dart';
import 'package:luanvanflutter/controller/task_controller.dart';
import 'package:luanvanflutter/models/task.dart';
import 'package:luanvanflutter/style/constants.dart';
import 'package:luanvanflutter/style/text_style.dart';
import 'package:luanvanflutter/utils/date_utils.dart';
import 'package:luanvanflutter/utils/dimen.dart';
import 'package:luanvanflutter/views/components/app_bar/standard_app_bar.dart';
import 'package:luanvanflutter/views/components/custom_input_field.dart';
import 'package:luanvanflutter/views/components/rounded_button.dart';
import 'package:uuid/uuid.dart';

class AddTaskScreen extends StatefulWidget {
  const AddTaskScreen({Key? key}) : super(key: key);

  @override
  State<AddTaskScreen> createState() => _AddTaskScreenState();
}

class _AddTaskScreenState extends State<AddTaskScreen> {
  final taskController = Get.put(TaskController());
  FirebaseAuth _auth = FirebaseAuth.instance;
  EventualNotifier<TaskSchedule> task = EventualNotifier<TaskSchedule>();
  EventualNotifier<bool> isLoading = EventualNotifier<bool>(false);
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _noteController = TextEditingController();
  final DateFormat _dateFormat = MyDateUtils.getFormatter;
  List<int> remindList = [0, 5, 10, 15, 20];
  List<ScheduleMode> repeatList = [
    ScheduleMode.NONE,
    ScheduleMode.DAILY,
    ScheduleMode.WEEKLY,
    ScheduleMode.MONTHLY
  ];
  @override
  void initState() {
    super.initState();
    String uid = _auth.currentUser!.uid;
    task.value = TaskSchedule(
        taskId: const Uuid().v4(),
        title: "",
        note: "",
        remindTime: remindList[0],
        date: DateFormat("EEEE dd/MM/yyyy", "vi_VN").format(DateTime.now()),
        startTime: DateFormat("hh:mm a").format(DateTime.now()).toString(),
        endTime: DateFormat("hh:mm a")
            .format(DateTime.now().add(const Duration(hours: 4)))
            .toString(),
        scheduleMode: ScheduleMode.NONE);
    print(DateTime.now().timeZoneName);
    task.notifyChange();
  }

  @override
  void dispose() {
    super.dispose();
    task.dispose();
    Get.delete<TaskController>();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: const StandardAppBar(
        enableBack: true,
        title: 'T H Ê M   N H Ắ C   N H Ở',
      ),
      body: EventualBuilder(
          notifiers: [task, isLoading],
          builder: (context, notifier, _) {
            DateTime _dateValue = _dateFormat.parse(notifier[0].value.date);
            return SingleChildScrollView(
              child: Container(
                margin: const EdgeInsets.only(top: 16),
                child: Column(
                  children: [
                    CustomInputField(
                      title: "Tựa đề",
                      content: "Nhập tên công việc",
                      controller: _titleController,
                    ),
                    CustomInputField(
                      title: "Nội dung",
                      content: "Nhập nội dung công việc",
                      controller: _noteController,
                    ),
                    CustomInputField(
                      title: "Ngày diễn ra",
                      content: _dateFormat.format(_dateValue),
                      widget: IconButton(
                        icon: const Icon(Icons.calendar_today_outlined),
                        onPressed: () => _getDateFromUser(_dateValue),
                      ),
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: CustomInputField(
                            title: "Bắt đầu",
                            content: notifier[0].value.startTime,
                            widget: IconButton(
                              onPressed: () {
                                _getStartTime(notifier[0].value.startTime,
                                    isStartTime: true);
                              },
                              icon: const Icon(Icons.access_time_rounded),
                              color: Colors.grey,
                            ),
                          ),
                        ),
                        Expanded(
                          child: CustomInputField(
                            title: "Kết thúc",
                            content: notifier[0].value.endTime,
                            widget: IconButton(
                              onPressed: () {
                                _getStartTime(notifier[0].value.endTime,
                                    isStartTime: false);
                              },
                              icon: const Icon(Icons.access_time_rounded),
                              color: Colors.grey,
                            ),
                          ),
                        )
                      ],
                    ),
                    CustomInputField(
                      title: "Nhắc nhở",
                      content: notifier[0].value.remindTime == 0
                          ? "Ngay lập tức"
                          : "Trước " +
                              notifier[0].value.remindTime.toString() +
                              " phút",
                      widget: DropdownButton(
                        icon: const Icon(Icons.keyboard_arrow_down,
                            color: Colors.grey),
                        onChanged: (value) {
                          task.value.remindTime = int.parse(value.toString());
                          task.notifyChange();
                        },
                        iconSize: 32,
                        elevation: 4,
                        style: subTitleStyle,
                        underline: Container(
                          height: 0,
                        ),
                        items: remindList
                            .map<DropdownMenuItem<String>>((int value) =>
                                DropdownMenuItem<String>(
                                    value: value.toString(),
                                    child: value == 0
                                        ? Text("Ngay lập tức")
                                        : Text(value.toString() + "phút")))
                            .toList(),
                      ),
                    ),
                    CustomInputField(
                      title: "Lặp lại",
                      content: ScheduleModeExtension.getScheduleString(
                          notifier[0].value.scheduleMode),
                      widget: DropdownButton(
                        icon: const Icon(Icons.keyboard_arrow_down,
                            color: Colors.grey),
                        onChanged: (ScheduleMode? value) {
                          task.value.scheduleMode = value!;
                          task.notifyChange();
                        },
                        iconSize: 32,
                        elevation: 4,
                        style: subTitleStyle,
                        underline: Container(
                          height: 0,
                        ),
                        items: repeatList
                            .map<DropdownMenuItem<ScheduleMode>>(
                                (ScheduleMode value) =>
                                    DropdownMenuItem<ScheduleMode>(
                                        value: value,
                                        child: Text(ScheduleModeExtension
                                            .getScheduleString(value))))
                            .toList(),
                      ),
                    ),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Color",
                              style: titleStyle,
                            ),
                            _colorPicker(notifier[0])
                          ],
                        ),
                        Expanded(
                          child: RoundedButton(
                            press: _validateInput,
                            text: 'Tạo nhắc nhở',
                            isBigButton: false,
                          ),
                        )
                      ],
                    ).paddingSymmetric(horizontal: Dimen.paddingCommon15),
                  ],
                ),
              ),
            );
          }),
    );
  }

  Future<void> _validateInput() async {
    if (_titleController.text.isNotEmpty && _noteController.text.isNotEmpty) {
      task.value.title = _titleController.text;
      task.value.note = _noteController.text;
      task.notifyChange();
      await _handleCreateTask();
      Get.back();
    } else if (_titleController.text.isEmpty || _noteController.text.isEmpty) {
      Get.snackbar("Bắt buộc", "Tất cả các ô cần được nhập",
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.white,
          icon: const Icon(Icons.warning_amber_rounded));
    }
  }

  Future<void> _handleCreateTask() async {
    var response = await taskController.addTask(task: task.value);
    response.fold((left) {
      if (left) {
        Fluttertoast.showToast(
            msg: "Tạo nhắc nhở thành công", toastLength: Toast.LENGTH_SHORT);
      }
    }, (right) {
      Fluttertoast.showToast(
          msg: "Có lỗi xảy ra: " + right.code, toastLength: Toast.LENGTH_SHORT);
    });
  }

  Widget _colorPicker(EventualNotifier notifier) => Wrap(
        children: List<Widget>.generate(3, (int index) {
          return GestureDetector(
            onTap: () {
              task.value.color = index;
              task.notifyChange();
            },
            child: CircleAvatar(
              radius: 14,
              backgroundColor: index == 0
                  ? kPrimaryColor
                  : index == 1
                      ? kPrimaryDarkColor
                      : kStudyColor,
              child: notifier.value.color == index
                  ? const Icon(Icons.done, color: Colors.white, size: 16)
                  : const SizedBox.shrink(),
            ).paddingOnly(right: 8.0),
          );
        }),
      )
          .paddingSymmetric(horizontal: Dimen.paddingCommon15)
          .marginOnly(top: Dimen.paddingCommon4);

  void _getDateFromUser(DateTime date) async {
    DateTime? _pickerDate = await showDatePicker(
        context: context,
        locale: const Locale("vi", "VN"),
        initialDate: date,
        firstDate: DateTime(2015),
        lastDate: DateTime(2121));

    if (_pickerDate != null) {
      task.value.date = _dateFormat.format(_pickerDate);
      task.notifyChange();
    } else {
      Fluttertoast.showToast(
          msg: "Có lỗi xảy ra, vui lòng thử lại!",
          toastLength: Toast.LENGTH_SHORT);
    }
  }

  Future<void> _getStartTime(String time, {bool isStartTime = false}) async {
    TimeOfDay? pickedTime = await _showTimePicker(time);
    DateTime now = DateTime.now();
    DateTime _toDateTime = DateTime(
        now.year, now.month, now.day, pickedTime!.hour, pickedTime.minute);
    String _formatedTime = DateFormat("hh:mm a").format(_toDateTime);
    if (pickedTime == null) {
      Fluttertoast.showToast(
          msg: "Có lỗi xảy ra, vui lòng thử lại!",
          toastLength: Toast.LENGTH_SHORT);
    } else if (isStartTime) {
      task.value.startTime = _formatedTime;
    } else if (!isStartTime) {
      task.value.endTime = _formatedTime;
    }
    task.notifyChange();
  }

  Future<TimeOfDay?> _showTimePicker(String initTimeString) {
    return showTimePicker(
        initialEntryMode: TimePickerEntryMode.input,
        initialTime: _getTimeOfDayFromString(initTimeString),
        context: context);
  }

  TimeOfDay _getTimeOfDayFromString(String initTimeString) {
    return TimeOfDay(
        hour: int.parse(initTimeString.split(":")[0]),
        minute: int.parse(initTimeString.split(":")[1].split(" ")[0]));
  }
}
