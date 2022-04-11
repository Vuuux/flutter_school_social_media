// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'task.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TaskSchedule _$TaskScheduleFromJson(Map<String, dynamic> json) => TaskSchedule(
      taskId: json['taskId'] as String,
      title: json['title'] as String,
      note: json['note'] as String,
      date: json['date'] as String,
      startTime: json['startTime'] as String,
      endTime: json['endTime'] as String,
      remindTime: json['remindTime'] as int,
      scheduleMode: $enumDecode(_$ScheduleModeEnumMap, json['scheduleMode']),
      color: json['color'] as int? ?? 0,
      isCompleted: json['isCompleted'] as bool? ?? false,
    );

Map<String, dynamic> _$TaskScheduleToJson(TaskSchedule instance) =>
    <String, dynamic>{
      'taskId': instance.taskId,
      'title': instance.title,
      'note': instance.note,
      'date': instance.date,
      'startTime': instance.startTime,
      'endTime': instance.endTime,
      'remindTime': instance.remindTime,
      'scheduleMode': _$ScheduleModeEnumMap[instance.scheduleMode],
      'color': instance.color,
      'isCompleted': instance.isCompleted,
    };

const _$ScheduleModeEnumMap = {
  ScheduleMode.NONE: 'NONE',
  ScheduleMode.DAILY: 'DAILY',
  ScheduleMode.WEEKLY: 'WEEKLY',
  ScheduleMode.MONTHLY: 'MONTHLY',
};
