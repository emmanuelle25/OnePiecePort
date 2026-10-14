import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class FavoritesService {
  static const _key = 'one_piece_favorites_v2';

  Future<List<Map<String, dynamic>>> getAll() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);
    if (raw == null || raw.isEmpty) return [];
    try {
      final decoded = jsonDecode(raw);
      if (decoded is! List) return [];
      return decoded.whereType<Map>().map((e) => Map<String, dynamic>.from(e)).toList();
    } catch (_) {
      return [];
    }
  }

  String key(String category, dynamic id) => '$category:${id ?? ''}';

  Future<bool> contains(String category, dynamic id) async {
    final target = key(category, id);
    final all = await getAll();
    return all.any((e) => e['key'] == target);
  }

  Future<bool> toggle({required String category, required dynamic id, required String title, required Map<String, dynamic> data}) async {
    final prefs = await SharedPreferences.getInstance();
    final all = await getAll();
    final target = key(category, id);
    final index = all.indexWhere((e) => e['key'] == target);
    if (index >= 0) {
      all.removeAt(index);
      await prefs.setString(_key, jsonEncode(all));
      return false;
    }
    all.add({'key': target, 'category': category, 'id': id, 'title': title, 'data': data});
    await prefs.setString(_key, jsonEncode(all));
    return true;
  }

  Future<void> remove(String key) async {
    final prefs = await SharedPreferences.getInstance();
    final all = await getAll();
    all.removeWhere((e) => e['key'] == key);
    await prefs.setString(_key, jsonEncode(all));
  }
}
