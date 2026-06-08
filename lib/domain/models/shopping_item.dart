import 'package:freezed_annotation/freezed_annotation.dart';
import 'json_converters.dart';

part 'shopping_item.freezed.dart';
part 'shopping_item.g.dart';

/// Modello di dominio per un articolo della lista della spesa.
@freezed
abstract class ShoppingItem with _$ShoppingItem {
  const factory ShoppingItem({
    @Default('') String id,
    @Default('') String name,
    @Default('') String quantity,
    @Default('') String addedByUid,
    String? boughtByUid,
    @Default(false) bool bought,
    @DateTimeConverter() required DateTime addedAt,
    @NullableDateTimeConverter() DateTime? boughtAt,
  }) = _ShoppingItem;

  factory ShoppingItem.fromJson(Map<String, dynamic> json) =>
      _$ShoppingItemFromJson(json);
}
