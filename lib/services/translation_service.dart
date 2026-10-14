import 'dart:convert';
import 'package:http/http.dart' as http;

/// Tradução automática EN -> PT-BR para textos recebidos da API.
/// Os dados originais da API não são alterados; apenas a apresentação é traduzida.
class TranslationService {
  TranslationService._();
  static final TranslationService instance = TranslationService._();

  final Map<String, String> _cache = {};
  final Map<String, String> _labels = {
    'name': 'Nome', 'title': 'Título', 'description': 'Descrição',
    'roman_name': 'Nome romanizado', 'roman name': 'Nome romanizado',
    'type': 'Tipo', 'filename': 'Imagem', 'image': 'Imagem',
    'id': 'ID', 'age': 'Idade', 'height': 'Altura', 'weight': 'Peso',
    'bounty': 'Recompensa', 'role': 'Função', 'status': 'Estado',
    'effect': 'Efeito', 'power': 'Poder', 'origin': 'Origem',
    'meaning': 'Significado', 'debut': 'Estreia', 'affiliation': 'Afiliação',
    'crew': 'Tripulação', 'crew_id': 'ID da tripulação', 'captain': 'Capitão',
    'fruit': 'Fruta', 'fruit_id': 'ID da fruta', 'boat': 'Barco',
    'boat_id': 'ID do barco', 'location': 'Local', 'locate': 'Local',
    'is yonko': 'É um Yonkou', 'yonko': 'Yonkou', 'number': 'Número',
    'year': 'Ano', 'episode': 'Episódio', 'chapter': 'Capítulo',
    'saga': 'Saga', 'arc': 'Arco', 'tome': 'Volume', 'gender': 'Gênero',
    'family': 'Família', 'occupation': 'Ocupação', 'first appearance': 'Primeira aparição',
    'size': 'Tamanho', 'english name': 'Nome em inglês', 'japanese name': 'Nome japonês',
    'roman name': 'Nome romanizado', 'created at': 'Criado em', 'updated at': 'Atualizado em',
  };

  String label(String key) {
    final normalized = key.replaceAllMapped(RegExp(r'([a-z])([A-Z])'), (m) => '${m[1]} ${m[2]}')
        .replaceAll('_', ' ').replaceAll('-', ' ').trim().toLowerCase();
    return _labels[normalized] ?? normalized.split(' ').where((s) => s.isNotEmpty)
        .map((s) => s[0].toUpperCase() + s.substring(1)).join(' ');
  }

  bool isUrl(String value) => Uri.tryParse(value)?.hasAbsolutePath == true &&
      (value.startsWith('http://') || value.startsWith('https://'));

  Future<String> translate(String input) async {
    final text = input.trim();
    if (text.isEmpty || isUrl(text) || _looksLikeIdentifier(text)) return input;
    if (_cache.containsKey(text)) return _cache[text]!;
    // Evita enviar números e códigos para o tradutor.
    final key = text.toLowerCase();
    if (_labels.containsKey(key)) return _labels[key]!;
    try {
      final uri = Uri.https('translate.googleapis.com', '/translate_a/single', {
        'client': 'gtx', 'sl': 'en', 'tl': 'pt', 'dt': 't', 'q': text,
      });
      final response = await http.get(uri, headers: {'Accept': 'application/json'}).timeout(const Duration(seconds: 12));
      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        if (decoded is List && decoded.isNotEmpty && decoded[0] is List) {
          final result = (decoded[0] as List).whereType<List>()
              .map((part) => part.isNotEmpty ? part[0]?.toString() ?? '' : '')
              .join().trim();
          if (result.isNotEmpty) {
            _cache[text] = result;
            return result;
          }
        }
      }
    } catch (_) {
      // Se estiver sem internet ou o serviço falhar, exibe o texto original.
    }
    _cache[text] = text;
    return text;
  }

  bool _looksLikeIdentifier(String value) {
    if (RegExp(r'^\d+(\.\d+)?$').hasMatch(value)) return true;
    if (value.length < 3 && !value.contains(' ')) return true;
    return false;
  }

  Future<dynamic> translateValue(dynamic value) async {
    if (value == null) return null;
    if (value is String) return translate(value);
    if (value is num || value is bool) return value;
    if (value is List) {
      final translated = await Future.wait(value.map(translateValue));
      return translated;
    }
    if (value is Map) {
      final result = <String, dynamic>{};
      for (final entry in value.entries) {
        result[entry.key.toString()] = await translateValue(entry.value);
      }
      return result;
    }
    return value.toString();
  }
}
