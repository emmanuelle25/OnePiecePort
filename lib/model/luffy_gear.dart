import 'package:flutter/foundation.dart';

/// Modelo genérico do recurso LuffyGear.
///
/// A API possui estruturas que podem variar entre registros. Em vez de inventar
/// campos que não estejam presentes no JSON recebido, o modelo preserva o mapa
/// original e oferece acesso seguro aos valores.
class LuffyGear {
  final Map<String, dynamic> data;

  const LuffyGear(this.data);

  factory LuffyGear.fromJson(Map<String, dynamic> json) {
    return LuffyGear(Map<String, dynamic>.from(json));
  }

  dynamic operator [](String key) => data[key];

  int? get id => data['id'] is num ? (data['id'] as num).toInt() : int.tryParse('${data['id'] ?? ''}');

  String get displayName {
    final candidates = ['name', 'title', 'nom', 'label'];
    for (final key in candidates) {
      final value = data[key];
      if (value != null && value.toString().trim().isNotEmpty) {
        return value.toString();
      }
    }
    return id == null ? 'Registro' : 'Registro #$id';
  }

  @override
  String toString() => data.toString();
}

List<LuffyGear> parseLuffyGearList(dynamic decoded) {
  if (decoded is List) {
    return List<LuffyGear>.from(
      decoded.map((x) => LuffyGear.fromJson(Map<String, dynamic>.from(x as Map))),
    );
  }
  if (decoded is Map<String, dynamic>) {
    final list = decoded['results'] ?? decoded['data'] ?? decoded['items'];
    if (list is List) {
      return List<LuffyGear>.from(
        list.map((x) => LuffyGear.fromJson(Map<String, dynamic>.from(x as Map))),
      );
    }
    return [LuffyGear.fromJson(decoded)];
  }
  return <LuffyGear>[];
}
