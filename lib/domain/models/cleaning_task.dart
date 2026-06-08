import 'package:freezed_annotation/freezed_annotation.dart';
import 'json_converters.dart';

part 'cleaning_task.freezed.dart';
part 'cleaning_task.g.dart';

/// Modello di dominio per una faccenda/pulizia assegnata a un coinquilino.
@freezed
abstract class CleaningTask with _$CleaningTask {
  const factory CleaningTask({
    @Default('') String id,
    @Default('') String title,
    @Default('') String assigneeUid,
    @DateTimeConverter() required DateTime weekStart, // settimana di riferimento
    @Default(false) bool completed,
    @NullableDateTimeConverter() DateTime? completedAt,
  }) = _CleaningTask;

  factory CleaningTask.fromJson(Map<String, dynamic> json) =>
      _$CleaningTaskFromJson(json);
}
