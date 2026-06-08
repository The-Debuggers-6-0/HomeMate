// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'cleaning_task.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_CleaningTask _$CleaningTaskFromJson(Map<String, dynamic> json) =>
    _CleaningTask(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      assigneeUid: json['assigneeUid'] as String? ?? '',
      weekStart: const DateTimeConverter().fromJson(json['weekStart']),
      completed: json['completed'] as bool? ?? false,
      completedAt: const NullableDateTimeConverter().fromJson(
        json['completedAt'],
      ),
    );

Map<String, dynamic> _$CleaningTaskToJson(
  _CleaningTask instance,
) => <String, dynamic>{
  'id': instance.id,
  'title': instance.title,
  'assigneeUid': instance.assigneeUid,
  'weekStart': const DateTimeConverter().toJson(instance.weekStart),
  'completed': instance.completed,
  'completedAt': const NullableDateTimeConverter().toJson(instance.completedAt),
};
