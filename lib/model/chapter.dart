import 'package:flutter/foundation.dart';

/// Modelo genérico do recurso Chapter.
///
/// A API possui estruturas que podem variar entre registros. Em vez de inventar
/// campos que não estejam presentes no JSON recebido, o modelo preserva o mapa
/// original e oferece acesso seguro aos valores.
class Chapter {
  final Map<String, dynamic> data;

  const Chapter(this.data);

  factory Chapter.fromJson(Map<String, dynamic> json) {
    return Chapter(Map<String, dynamic>.from(json));
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

List<Chapter> parseChapterList(dynamic decoded) {
  if (decoded is List) {
    return List<Chapter>.from(
      decoded.map((x) => Chapter.fromJson(Map<String, dynamic>.from(x as Map))),
    );
  }
  if (decoded is Map<String, dynamic>) {
    final list = decoded['results'] ?? decoded['data'] ?? decoded['items'];
    if (list is List) {
      return List<Chapter>.from(
        list.map((x) => Chapter.fromJson(Map<String, dynamic>.from(x as Map))),
      );
    }
    return [Chapter.fromJson(decoded)];
  }
  return <Chapter>[];
}
