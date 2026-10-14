class Sword {
  final Map<String, dynamic> data;
  const Sword(this.data);
  factory Sword.fromJson(Map<String, dynamic> json) => Sword(Map<String, dynamic>.from(json));
  dynamic operator [](String key) => data[key];
  int? get id => data['id'] is num ? (data['id'] as num).toInt() : int.tryParse('${data['id'] ?? ''}');
  String get displayName {
    for (final key in ['name', 'title', 'nom', 'label']) {
      final value = data[key];
      if (value != null && value.toString().trim().isNotEmpty) return value.toString();
    }
    return id == null ? 'Registro' : 'Registro #$id';
  }
}
