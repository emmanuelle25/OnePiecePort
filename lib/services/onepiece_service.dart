import 'dart:convert';
import 'package:http/http.dart' as http;

import '../model/saga.dart';
import '../model/fruit.dart';
import '../model/chapter.dart';
import '../model/tome.dart';
import '../model/episode.dart';
import '../model/dial.dart';
import '../model/movie.dart';
import '../model/haki.dart';
import '../model/luffy_gear.dart';
import '../model/luffy_technique.dart';
import '../model/crew.dart';
import '../model/character.dart';
import '../model/boat.dart';
import '../model/arc.dart';
import '../model/location.dart';
import '../model/sword.dart';

/// Cliente da One Piece API.
///
/// Todos os registros são carregados diretamente da API e ficam em memória
/// durante a sessão. Assim, as telas usam os dados completos e os filtros e
/// relacionamentos não dependem de um JSON de exemplo local.
class OnePieceService {
  static const String baseUrl = 'https://api.api-onepiece.com/v2';
  static const String language = 'en';
  static const Duration timeout = Duration(seconds: 30);

  final Map<String, List<Map<String, dynamic>>> _cache = {};

  // A versão atual da API usa recursos no plural e exige o idioma:
  // /v2/characters/en, /v2/fruits/en, /v2/locates/en, etc.
  // Mantemos o mapeamento centralizado para evitar erros de rota.
  String _route(String resource) {
    final apiResource = resource == 'locations' ? 'locates' : resource;
    return '$apiResource/$language';
  }

  Future<List<Map<String, dynamic>>> _fetchAll(String endpoint) async {
    if (_cache.containsKey(endpoint)) return _cache[endpoint]!;
    final uri = Uri.parse('$baseUrl/$endpoint');
    final response = await http.get(uri, headers: {'Accept': 'application/json'}).timeout(timeout);
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception('API retornou HTTP ${response.statusCode} em /$endpoint');
    }
    final decoded = jsonDecode(response.body);
    final rows = _extractRows(decoded);
    _cache[endpoint] = rows;
    return rows;
  }

  List<Map<String, dynamic>> _extractRows(dynamic decoded) {
    if (decoded is List) {
      return decoded.whereType<Map>().map((e) => Map<String, dynamic>.from(e)).toList();
    }
    if (decoded is Map) {
      // A API pode devolver diretamente um objeto ou uma lista dentro de data/results/items.
      for (final key in ['data', 'results', 'items', 'content']) {
        final value = decoded[key];
        if (value is List) {
          return value.whereType<Map>().map((e) => Map<String, dynamic>.from(e)).toList();
        }
      }
      return [Map<String, dynamic>.from(decoded)];
    }
    return [];
  }

  Future<Map<String, dynamic>> _oneRaw(String endpoint, dynamic id) async {
    final uri = Uri.parse('$baseUrl/$endpoint/$id');
    final response = await http.get(uri, headers: {'Accept': 'application/json'}).timeout(timeout);
    if (response.statusCode < 200 || response.statusCode >= 300) {
      // Se o endpoint individual falhar, usa o catálogo completo como fallback.
      final rows = await _fetchAll(endpoint);
      final found = rows.where((r) => _sameId(r['id'], id)).toList();
      if (found.isNotEmpty) return found.first;
      throw Exception('Registro #$id não encontrado em /$endpoint.');
    }
    final rows = _extractRows(jsonDecode(response.body));
    if (rows.isEmpty) throw Exception('Registro #$id não encontrado em /$endpoint.');
    return rows.first;
  }

  bool _sameId(dynamic a, dynamic b) => a?.toString() == b?.toString();

  Future<List<T>> _typed<T>(String endpoint, T Function(Map<String, dynamic>) parser) async {
    final rows = await _fetchAll(endpoint);
    return rows.map(parser).toList();
  }

  Future<T> _one<T>(String endpoint, dynamic id, T Function(Map<String, dynamic>) parser) async {
    return parser(await _oneRaw(endpoint, id));
  }

  Future<List<T>> _search<T>(Future<List<T>> Function() loader, String query) async {
    final q = _normalize(query);
    if (q.isEmpty) return loader();
    final items = await loader();
    return items.where((item) => _containsQuery((item as dynamic).data, q)).toList();
  }

  String _normalize(String value) => value.trim().toLowerCase().replaceAll(RegExp(r'\s+'), ' ');

  bool _containsQuery(dynamic value, String query) {
    if (value == null) return false;
    if (value is Map) return value.entries.any((e) => _containsQuery(e.key, query) || _containsQuery(e.value, query));
    if (value is Iterable) return value.any((v) => _containsQuery(v, query));
    return _normalize(value.toString()).contains(query);
  }

  /// Procura relações aceitando camelCase, snake_case e objetos aninhados.
  /// Isso evita que a tela fique vazia quando a API altera o formato de um campo.
  Future<List<T>> _related<T>(String endpoint, String relationField, dynamic id, T Function(Map<String, dynamic>) parser) async {
    final rows = await _fetchAll(endpoint);
    return rows.where((row) => _hasRelation(row, relationField, id)).map(parser).toList();
  }

  bool _hasRelation(dynamic value, String field, dynamic id) {
    if (value is Map) {
      for (final entry in value.entries) {
        final key = entry.key.toString();
        final normalizedKey = key.toLowerCase().replaceAll('_', '').replaceAll('-', '');
        final normalizedField = field.toLowerCase().replaceAll('_', '').replaceAll('-', '');
        final matchesField = normalizedKey == normalizedField ||
            normalizedKey == '${normalizedField}id' ||
            normalizedKey == normalizedField.replaceAll('id', '') + 'id';
        if (matchesField && _valueContainsId(entry.value, id)) return true;
        if (entry.value is Map && _valueContainsId(entry.value, id) && _looksLikeRelationKey(key, normalizedField)) return true;
        if (_hasRelation(entry.value, field, id)) return true;
      }
    } else if (value is Iterable) {
      return value.any((v) => _hasRelation(v, field, id));
    }
    return false;
  }

  bool _looksLikeRelationKey(String key, String field) {
    final k = key.toLowerCase().replaceAll('_', '').replaceAll('-', '');
    return k.contains(field.replaceAll('id', '')) || k.contains('relation') || k.contains('character') || k.contains('crew') || k.contains('saga') || k.contains('arc') || k.contains('tome') || k.contains('gear') || k.contains('captain');
  }

  bool _valueContainsId(dynamic value, dynamic id) {
    if (value is num || value is String) return _sameId(value, id);
    if (value is Map) {
      for (final key in ['id', 'ID', 'value']) {
        if (value.containsKey(key) && _sameId(value[key], id)) return true;
      }
      return value.values.any((v) => _valueContainsId(v, id));
    }
    if (value is Iterable) return value.any((v) => _valueContainsId(v, id));
    return false;
  }

  Future<int> _count<T>(Future<List<T>> Function() loader) async => (await loader()).length;

  Future<List<Saga>> getSagas() => _typed(_route('sagas'), Saga.fromJson);
  Future<Saga> getSaga(dynamic id) => _one(_route('sagas'), id, Saga.fromJson);
  Future<List<Saga>> searchSagas(String q) => _search(getSagas, q);
  Future<int> countSagas() => _count(getSagas);

  Future<List<Fruit>> getFruits() => _typed(_route('fruits'), Fruit.fromJson);
  Future<Fruit> getFruit(dynamic id) => _one(_route('fruits'), id, Fruit.fromJson);
  Future<List<Fruit>> searchFruits(String q) => _search(getFruits, q);
  Future<int> countFruits() => _count(getFruits);

  Future<List<Chapter>> getChapters() => _typed(_route('chapters'), Chapter.fromJson);
  Future<Chapter> getChapter(dynamic id) => _one(_route('chapters'), id, Chapter.fromJson);
  Future<List<Chapter>> searchChapters(String q) => _search(getChapters, q);
  Future<int> countChapters() => _count(getChapters);
  Future<List<Chapter>> getChaptersByTome(dynamic id) => _related(_route('chapters'), 'tomeId', id, Chapter.fromJson);
  Future<int> countChaptersByTome(dynamic id) => _count(() => getChaptersByTome(id));

  Future<List<Tome>> getTomes() => _typed(_route('tomes'), Tome.fromJson);
  Future<Tome> getTome(dynamic id) => _one(_route('tomes'), id, Tome.fromJson);
  Future<List<Tome>> searchTomes(String q) => _search(getTomes, q);
  Future<int> countTomes() => _count(getTomes);

  Future<List<Episode>> getEpisodes() => _typed(_route('episodes'), Episode.fromJson);
  Future<Episode> getEpisode(dynamic id) => _one(_route('episodes'), id, Episode.fromJson);
  Future<List<Episode>> searchEpisodes(String q) => _search(getEpisodes, q);
  Future<int> countEpisodes() => _count(getEpisodes);
  Future<List<Episode>> getEpisodesBySaga(dynamic id) => _related(_route('episodes'), 'sagaId', id, Episode.fromJson);
  Future<int> countEpisodesBySaga(dynamic id) => _count(() => getEpisodesBySaga(id));
  Future<List<Episode>> getEpisodesByArc(dynamic id) => _related(_route('episodes'), 'arcId', id, Episode.fromJson);
  Future<int> countEpisodesByArc(dynamic id) => _count(() => getEpisodesByArc(id));

  Future<List<Dial>> getDials() => _typed(_route('dials'), Dial.fromJson);
  Future<Dial> getDial(dynamic id) => _one(_route('dials'), id, Dial.fromJson);
  Future<List<Dial>> searchDials(String q) => _search(getDials, q);
  Future<int> countDials() => _count(getDials);

  Future<List<Movie>> getMovies() => _typed(_route('films'), Movie.fromJson);
  Future<Movie> getMovie(dynamic id) => _one(_route('films'), id, Movie.fromJson);
  Future<List<Movie>> searchMovies(String q) => _search(getMovies, q);
  Future<int> countMovies() => _count(getMovies);

  Future<List<Sword>> getSwords() => _typed(_route('swords'), Sword.fromJson);
  Future<Sword> getSword(dynamic id) => _one(_route('swords'), id, Sword.fromJson);
  Future<List<Sword>> searchSwords(String q) => _search(getSwords, q);
  Future<int> countSwords() => _count(getSwords);

  Future<List<Haki>> getHakis() => _typed(_route('hakis'), Haki.fromJson);
  Future<Haki> getHaki(dynamic id) => _one(_route('hakis'), id, Haki.fromJson);
  Future<List<Haki>> searchHakis(String q) => _search(getHakis, q);
  Future<int> countHakis() => _count(getHakis);
  Future<List<Haki>> getHakisByCharacter(dynamic id) => _related(_route('hakis'), 'characterId', id, Haki.fromJson);
  Future<int> countHakisByCharacter(dynamic id) => _count(() => getHakisByCharacter(id));

  Future<List<LuffyGear>> getLuffyGears() => _typed(_route('luffy-gears'), LuffyGear.fromJson);
  Future<LuffyGear> getLuffyGear(dynamic id) => _one(_route('luffy-gears'), id, LuffyGear.fromJson);
  Future<List<LuffyGear>> searchLuffyGears(String q) => _search(getLuffyGears, q);
  Future<int> countLuffyGears() => _count(getLuffyGears);

  Future<List<LuffyTechnique>> getLuffyTechniques() => _typed(_route('luffy-techniques'), LuffyTechnique.fromJson);
  Future<LuffyTechnique> getLuffyTechnique(dynamic id) => _one(_route('luffy-techniques'), id, LuffyTechnique.fromJson);
  Future<List<LuffyTechnique>> searchLuffyTechniques(String q) => _search(getLuffyTechniques, q);
  Future<int> countLuffyTechniques() => _count(getLuffyTechniques);
  Future<List<LuffyTechnique>> getLuffyTechniquesByGear(dynamic id) => _related(_route('luffy-techniques'), 'gearId', id, LuffyTechnique.fromJson);
  Future<int> countLuffyTechniquesByGear(dynamic id) => _count(() => getLuffyTechniquesByGear(id));

  Future<List<Crew>> getCrews() => _typed(_route('crews'), Crew.fromJson);
  Future<Crew> getCrew(dynamic id) => _one(_route('crews'), id, Crew.fromJson);
  Future<List<Crew>> searchCrews(String q) => _search(getCrews, q);
  Future<int> countCrews() => _count(getCrews);
  Future<List<Crew>> getYonkoCrews() async {
    final crews = await getCrews();
    return crews.where((crew) => crew.data['yonko'] == true || crew.data['type']?.toString().toLowerCase().contains('yonko') == true).toList();
  }
  Future<int> countYonkoCrews() => _count(getYonkoCrews);
  Future<List<Character>> getCharactersByCrew(dynamic id) => _related(_route('characters'), 'crewId', id, Character.fromJson);
  Future<int> countCharactersByCrew(dynamic id) => _count(() => getCharactersByCrew(id));
  Future<List<Boat>> getBoatsByCrew(dynamic id) => _related(_route('boats'), 'crewId', id, Boat.fromJson);
  Future<int> countBoatsByCrew(dynamic id) => _count(() => getBoatsByCrew(id));

  Future<List<Character>> getCharacters() => _typed(_route('characters'), Character.fromJson);
  Future<Character> getCharacter(dynamic id) => _one(_route('characters'), id, Character.fromJson);
  Future<List<Character>> searchCharacters(String q) => _search(getCharacters, q);
  Future<int> countCharacters() => _count(getCharacters);

  Future<List<Boat>> getBoats() => _typed(_route('boats'), Boat.fromJson);
  Future<Boat> getBoat(dynamic id) => _one(_route('boats'), id, Boat.fromJson);
  Future<List<Boat>> searchBoats(String q) => _search(getBoats, q);
  Future<int> countBoats() => _count(getBoats);
  Future<List<Boat>> getBoatsByCaptain(dynamic id) => _related(_route('boats'), 'captainId', id, Boat.fromJson);
  Future<int> countBoatsByCaptain(dynamic id) => _count(() => getBoatsByCaptain(id));

  Future<List<Arc>> getArcs() => _typed(_route('arcs'), Arc.fromJson);
  Future<Arc> getArc(dynamic id) => _one(_route('arcs'), id, Arc.fromJson);
  Future<List<Arc>> searchArcs(String q) => _search(getArcs, q);
  Future<int> countArcs() => _count(getArcs);
  Future<List<Arc>> getArcsBySaga(dynamic id) => _related(_route('arcs'), 'sagaId', id, Arc.fromJson);
  Future<int> countArcsBySaga(dynamic id) => _count(() => getArcsBySaga(id));

  Future<List<Location>> getLocations() => _typed(_route('locations'), Location.fromJson);
  Future<Location> getLocation(dynamic id) => _one(_route('locations'), id, Location.fromJson);
  Future<List<Location>> searchLocations(String q) => _search(getLocations, q);
  Future<int> countLocations() => _count(getLocations);

  /// Localiza uma imagem nos campos enviados pela API.
  ///
  /// A API usa principalmente `filename` nas frutas. A busca começa no
  /// próprio registro para não exibir a imagem da fruta relacionada como se
  /// fosse a imagem do personagem.
  static String? imageUrl(Map<String, dynamic> data) {
    const imageKeys = {
      'image', 'imageurl', 'img', 'picture', 'poster', 'thumbnail', 'cover',
      'filename', 'technicalfile', 'src', 'url', 'uri', 'path',
    };

    String? findUrl(dynamic value, {int depth = 0}) {
      if (depth > 4 || value == null) return null;
      if (value is String) {
        final text = value.trim();
        if (text.startsWith('https://') || text.startsWith('http://')) return text;
        return null;
      }
      if (value is Map) {
        for (final entry in value.entries) {
          final key = entry.key.toString().toLowerCase().replaceAll('_', '').replaceAll('-', '').replaceAll(' ', '');
          if (imageKeys.contains(key)) {
            final found = findUrl(entry.value, depth: depth + 1);
            if (found != null) return found;
          }
        }
        // Algumas respostas agrupam metadados dentro de image/media/asset.
        for (final entry in value.entries) {
          final key = entry.key.toString().toLowerCase();
          if (key.contains('image') || key.contains('media') || key.contains('asset') || key.contains('technical')) {
            final found = findUrl(entry.value, depth: depth + 1);
            if (found != null) return found;
          }
        }
      } else if (value is Iterable) {
        for (final item in value) {
          final found = findUrl(item, depth: depth + 1);
          if (found != null) return found;
        }
      }
      return null;
    }

    // A API de frutas fornece as imagens diretamente em `filename` e,
    // em alguns registros, em `technicalFile`. Prioriza esses campos.
    for (final entry in data.entries) {
      final normalized = entry.key.toString().toLowerCase().replaceAll('_', '').replaceAll('-', '').replaceAll(' ', '');
      if (['filename', 'technicalfile', 'image', 'imageurl', 'img', 'picture', 'poster', 'thumbnail', 'cover', 'src', 'url', 'uri', 'path'].contains(normalized)) {
        final found = findUrl(entry.value);
        if (found != null) return found;
      }
    }

    // Usa somente URLs fornecidas pela própria API; não cria imagens fictícias.
    for (final entry in data.entries) {
      final key = entry.key.toString().toLowerCase().replaceAll('_', '').replaceAll('-', '').replaceAll(' ', '');
      if (imageKeys.contains(key) || key.contains('image') || key.contains('media') || key.contains('asset') || key.contains('technical')) {
        final found = findUrl(entry.value);
        if (found != null) return found;
      }
    }
    return null;
  }
}
