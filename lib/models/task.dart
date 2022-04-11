import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:json_annotation/json_annotation.dart';
part 'task.g.dart';

enum ScheduleMode { NONE, DAILY, WEEKLY, MONTHLY }

extension ScheduleModeExtension on ScheduleMode {
  static ScheduleMode getScheduleMode(String mode) {
    switch (mode) {
      case "DAILY":
        return ScheduleMode.DAILY;
      case "WEEKLY":
        return ScheduleMode.WEEKLY;
      case "MONTHLY":
        return ScheduleMode.MONTHLY;
      default:
        return ScheduleMode.NONE;
    }
  }

  static String getScheduleString(ScheduleMode mode) {
    switch (mode) {
      case ScheduleMode.DAILY:
        return "Hằng ngày";
      case ScheduleMode.WEEKLY:
        return "Hằng tuần";
      case ScheduleMode.MONTHLY:
        return "Hằng tháng";
      default:
        return "Không";
    }
  }
}

@JsonSerializable()
class TaskSchedule {
  String taskId;
  String title;
  String note;
  String date;
  String startTime;
  String endTime;
  int remindTime;
  ScheduleMode scheduleMode;
  int color;
  bool isCompleted;

  TaskSchedule(
      {required this.taskId,
      required this.title,
      required this.note,
      required this.date,
      required this.startTime,
      required this.endTime,
      required this.remindTime,
      required this.scheduleMode,
      this.color = 0,
      this.isCompleted = false});

  factory TaskSchedule.fromJson(Map<String, dynamic> json) =>
      _$TaskScheduleFromJson(json);

  /// `toJson` is the convention for a class to declare support for serialization
  /// to JSON. The implementation simply calls the private, generated
  /// helper method `_$UserToJson`.
  Map<String, dynamic> toJson() => _$TaskScheduleToJson(this);

  factory TaskSchedule.fromDocumentSnapshot(DocumentSnapshot snapshot) {
    return TaskSchedule(
        taskId: snapshot["taskId"],
        color: snapshot["color"],
        isCompleted: snapshot["isCompleted"],
        title: snapshot["title"],
        note: snapshot["note"],
        date: snapshot["date"],
        startTime: snapshot["startTime"],
        endTime: snapshot["endTime"],
        remindTime: snapshot["remindTime"],
        scheduleMode: ScheduleModeExtension.getScheduleMode(
            (snapshot["scheduleMode"] as String)));
  }
}
