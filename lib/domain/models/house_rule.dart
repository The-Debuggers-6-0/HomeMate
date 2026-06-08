import 'package:freezed_annotation/freezed_annotation.dart';

part 'house_rule.freezed.dart';
part 'house_rule.g.dart';

/// Modello di dominio per una regola della casa.
@freezed
abstract class HouseRule with _$HouseRule {
  const factory HouseRule({
    @Default('') String id,
    @Default('') String title,
    @Default('') String description,
  }) = _HouseRule;

  factory HouseRule.fromJson(Map<String, dynamic> json) =>
      _$HouseRuleFromJson(json);
}
