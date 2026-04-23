import 'package:freezed_annotation/freezed_annotation.dart';

part 'house.freezed.dart';
part 'house.g.dart';

/// Modello di dominio per una casa condivisa.
@freezed
abstract class House with _$House {
  const factory House({
    required String id,
    required String admin,
    required String nome,
    @Default(<String>[]) List<String> membri,
  }) = _House;

  factory House.fromJson(Map<String, dynamic> json) => _$HouseFromJson(json);

  /// Factory per creare una House da un documento Firestore.
  factory House.fromFirestore(String id, Map<String, dynamic> data) {
    return House(
      id: id,
      admin: data['admin'] as String? ?? '',
      nome: data['nome'] as String? ?? '',
      membri: List<String>.from(data['membri'] as List? ?? []),
    );
  }
}
