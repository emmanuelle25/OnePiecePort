import 'package:flutter/material.dart';
import '../services/onepiece_service.dart';
import '../theme/app_theme.dart';
import '../widgets/app_header.dart';
import '../widgets/count_badge.dart';
import '../widgets/bottom_nav.dart';
import 'profile.dart';
import 'favorites.dart';
import 'resource_list.dart';
import 'resource_detail.dart';
import 'related_resource_list.dart';

class HomeScreen extends StatefulWidget {
  final OnePieceService service;
  const HomeScreen({super.key, required this.service});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _index = 0;

  List<Map<String, dynamic>> _categories() => [
    {'name': 'Personagens', 'icon': Icons.person_rounded, 'color': AppTheme.vermelho, 'count': widget.service.countCharacters()},
    {'name': 'Frutas do Demônio', 'icon': Icons.local_fire_department_rounded, 'color': AppTheme.vermelhoEscuro, 'count': widget.service.countFruits()},
    {'name': 'Tripulações', 'icon': Icons.groups_rounded, 'color': AppTheme.azul, 'count': widget.service.countCrews()},
    {'name': 'Sagas', 'icon': Icons.auto_stories_rounded, 'color': AppTheme.dourado, 'count': widget.service.countSagas()},
    {'name': 'Episódios', 'icon': Icons.live_tv_rounded, 'color': AppTheme.azul, 'count': widget.service.countEpisodes()},
    {'name': 'Arcos', 'icon': Icons.map_rounded, 'color': AppTheme.vermelho, 'count': widget.service.countArcs()},
    {'name': 'Capítulos', 'icon': Icons.menu_book_rounded, 'color': AppTheme.marinho, 'count': widget.service.countChapters()},
    {'name': 'Tomos', 'icon': Icons.library_books_rounded, 'color': AppTheme.dourado, 'count': widget.service.countTomes()},
    {'name': 'Dials', 'icon': Icons.graphic_eq_rounded, 'color': AppTheme.azul, 'count': widget.service.countDials()},
    {'name': 'Filmes', 'icon': Icons.movie_creation_rounded, 'color': AppTheme.vermelho, 'count': widget.service.countMovies()},
    {'name': 'Hakis', 'icon': Icons.shield_rounded, 'color': AppTheme.marinho, 'count': widget.service.countHakis()},
    {'name': 'Gears de Luffy', 'icon': Icons.bolt_rounded, 'color': AppTheme.vermelhoEscuro, 'count': widget.service.countLuffyGears()},
    {'name': 'Técnicas de Luffy', 'icon': Icons.flash_on_rounded, 'color': AppTheme.dourado, 'count': widget.service.countLuffyTechniques()},
    {'name': 'Barcos', 'icon': Icons.sailing_rounded, 'color': AppTheme.azul, 'count': widget.service.countBoats()},
    {'name': 'Locais', 'icon': Icons.location_on_rounded, 'color': AppTheme.vermelho, 'count': widget.service.countLocations()},
  ];

  void _openCategory(Map<String, dynamic> category) {
    final name = category['name'] as String;
    final config = _configFor(name);
    if (config == null) return;
    Navigator.push(context, MaterialPageRoute(builder: (_) => ResourceListScreen(
      title: name,
      icon: category['icon'] as IconData,
      loadItems: config['load'] as Future<List<dynamic>> Function(),
      searchItems: config['search'] as Future<List<dynamic>> Function(String),
      openItem: (item) => _openDetail(name, item, category['icon'] as IconData),
      actions: name == 'Tripulações' ? [
        IconButton(
          tooltip: 'Somente Yonko',
          icon: const Icon(Icons.filter_alt_outlined),
          onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => ResourceListScreen(
            title: 'Tripulações Yonko', icon: Icons.groups_rounded,
            loadItems: widget.service.getYonkoCrews,
            searchItems: widget.service.searchCrews,
            openItem: (item) => _openDetail('Tripulações', item, Icons.groups_rounded),
          ))),
        ),
      ] : [],
    )));
  }

  Map<String, dynamic>? _configFor(String name) {
    switch (name) {
      case 'Personagens': return {'load': widget.service.getCharacters, 'search': widget.service.searchCharacters};
      case 'Tripulações': return {'load': widget.service.getCrews, 'search': widget.service.searchCrews};
      case 'Frutas do Demônio': return {'load': widget.service.getFruits, 'search': widget.service.searchFruits};
      case 'Sagas': return {'load': widget.service.getSagas, 'search': widget.service.searchSagas};
      case 'Episódios': return {'load': widget.service.getEpisodes, 'search': widget.service.searchEpisodes};
      case 'Arcos': return {'load': widget.service.getArcs, 'search': widget.service.searchArcs};
      case 'Capítulos': return {'load': widget.service.getChapters, 'search': widget.service.searchChapters};
      case 'Tomos': return {'load': widget.service.getTomes, 'search': widget.service.searchTomes};
      case 'Dials': return {'load': widget.service.getDials, 'search': widget.service.searchDials};
      case 'Filmes': return {'load': widget.service.getMovies, 'search': widget.service.searchMovies};
      case 'Hakis': return {'load': widget.service.getHakis, 'search': widget.service.searchHakis};
      case 'Gears de Luffy': return {'load': widget.service.getLuffyGears, 'search': widget.service.searchLuffyGears};
      case 'Técnicas de Luffy': return {'load': widget.service.getLuffyTechniques, 'search': widget.service.searchLuffyTechniques};
      case 'Barcos': return {'load': widget.service.getBoats, 'search': widget.service.searchBoats};
      case 'Locais': return {'load': widget.service.getLocations, 'search': widget.service.searchLocations};
    }
    return null;
  }

  void _openDetail(String category, dynamic item, IconData icon) {
    final id = item.id;
    if (id == null) return;

    late Future<dynamic> detail;
    switch (category) {
      case 'Personagens': detail = widget.service.getCharacter(id); break;
      case 'Tripulações': detail = widget.service.getCrew(id); break;
      case 'Frutas do Demônio': detail = widget.service.getFruit(id); break;
      case 'Sagas': detail = widget.service.getSaga(id); break;
      case 'Episódios': detail = widget.service.getEpisode(id); break;
      case 'Arcos': detail = widget.service.getArc(id); break;
      case 'Capítulos': detail = widget.service.getChapter(id); break;
      case 'Tomos': detail = widget.service.getTome(id); break;
      case 'Dials': detail = widget.service.getDial(id); break;
      case 'Filmes': detail = widget.service.getMovie(id); break;
      case 'Hakis': detail = widget.service.getHaki(id); break;
      case 'Gears de Luffy': detail = widget.service.getLuffyGear(id); break;
      case 'Técnicas de Luffy': detail = widget.service.getLuffyTechnique(id); break;
      case 'Barcos': detail = widget.service.getBoat(id); break;
      case 'Locais': detail = widget.service.getLocation(id); break;
      default: return;
    }

    Navigator.push(context, MaterialPageRoute(builder: (_) => FutureBuilder<dynamic>(
      future: detail,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) return const Scaffold(body: Center(child: CircularProgressIndicator()));
        if (snapshot.hasError) return Scaffold(body: Center(child: Text(snapshot.error.toString())));
        final data = Map<String, dynamic>.from(snapshot.data.data as Map);
        final relations = <Widget>[];
        if (category == 'Personagens') {
          relations.add(_relationButton(context, 'Hakis relacionados', 'Hakis', Icons.shield, () => widget.service.getHakisByCharacter(id), () => widget.service.countHakisByCharacter(id)));
          relations.add(_relationButton(context, 'Barcos relacionados', 'Barcos', Icons.sailing, () => widget.service.getBoatsByCaptain(id), () => widget.service.countBoatsByCaptain(id)));
        } else if (category == 'Sagas') {
          relations.add(_relationButton(context, 'Episódios da saga', 'Episódios', Icons.live_tv, () => widget.service.getEpisodesBySaga(id), () => widget.service.countEpisodesBySaga(id)));
          relations.add(_relationButton(context, 'Arcos da saga', 'Arcos', Icons.map, () => widget.service.getArcsBySaga(id), () => widget.service.countArcsBySaga(id)));
        } else if (category == 'Tomos') {
          relations.add(_relationButton(context, 'Capítulos do tomo', 'Capítulos', Icons.menu_book, () => widget.service.getChaptersByTome(id), () => widget.service.countChaptersByTome(id)));
        } else if (category == 'Tripulações') {
          relations.add(_relationButton(context, 'Personagens da tripulação', 'Personagens', Icons.groups, () => widget.service.getCharactersByCrew(id), () => widget.service.countCharactersByCrew(id)));
          relations.add(_relationButton(context, 'Barcos da tripulação', 'Barcos', Icons.sailing, () => widget.service.getBoatsByCrew(id), () => widget.service.countBoatsByCrew(id)));
        } else if (category == 'Gears de Luffy') {
          relations.add(_relationButton(context, 'Técnicas do Gear', 'Técnicas de Luffy', Icons.bolt, () => widget.service.getLuffyTechniquesByGear(id), () => widget.service.countLuffyTechniquesByGear(id)));
        } else if (category == 'Arcos') {
          relations.add(_relationButton(context, 'Episódios do arco', 'Episódios', Icons.live_tv, () => widget.service.getEpisodesByArc(id), () => widget.service.countEpisodesByArc(id)));
        }
        return ResourceDetail(title: item.displayName.toString(), data: data, related: relations, category: category, itemId: id, icon: icon);
      },
    )));
  }

  Widget _relationButton(BuildContext context, String title, String category, IconData icon, Future<List<dynamic>> Function() load, Future<int> Function() count) {
    return Padding(
      padding: const EdgeInsets.only(top: 9),
      child: InkWell(
        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => RelatedResourceList(title: title, category: category, icon: icon, loadItems: load, loadCount: count))),
        borderRadius: BorderRadius.circular(11),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 12),
          decoration: BoxDecoration(border: Border.all(color: const Color(0xFFE6E7E3)), borderRadius: BorderRadius.circular(11), color: Colors.white),
          child: Row(children: [Icon(icon, size: 17, color: AppTheme.vermelho), const SizedBox(width: 9), Expanded(child: Text(title, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13))), const Icon(Icons.chevron_right_rounded, size: 19)]),
        ),
      ),
    );
  }

  void _showAbout() {
    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      builder: (_) => const Padding(
        padding: EdgeInsets.fromLTRB(22, 4, 22, 30),
        child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Sobre o One Piece Wiki', style: TextStyle(fontSize: 21, fontWeight: FontWeight.w900)),
          SizedBox(height: 8),
          Text('Um catálogo inspirado na estrutura da One Piece API, com listas, pesquisa, detalhes e relacionamentos.'),
          SizedBox(height: 10),
          Text('Os dados são carregados diretamente da One Piece API. Favoritos e perfil ficam salvos neste aparelho.', style: TextStyle(fontWeight: FontWeight.w700)),
        ]),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_index == 1) return FavoritesScreen(onHome: () => setState(() => _index = 0), onProfile: () => setState(() => _index = 2));
    if (_index == 2) return ProfileScreen(onHome: () => setState(() => _index = 0), onFavorites: () => setState(() => _index = 1));
    final categories = _categories();

    return Scaffold(
      appBar: AppHeader(title: 'One Piece Wiki', actions: [IconButton(onPressed: _showAbout, icon: const Icon(Icons.info_outline_rounded))]),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 10, 16, 24),
        children: [
          Row(children: [
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: const [
              Text('Um universo.', style: TextStyle(fontSize: 27, fontWeight: FontWeight.w900, height: 1)),
              Text('Novas rotas.', style: TextStyle(fontSize: 27, fontWeight: FontWeight.w900, color: AppTheme.vermelho, height: 1.05)),
            ])),
            Container(width: 58, height: 58, decoration: BoxDecoration(color: AppTheme.dourado.withValues(alpha: .2), shape: BoxShape.circle), child: const Icon(Icons.explore_rounded, color: AppTheme.vermelho, size: 30)),
          ]),
          const SizedBox(height: 14),
          InkWell(
            onTap: () => _openCategory(categories.first),
            borderRadius: BorderRadius.circular(16),
            child: Container(
              padding: const EdgeInsets.all(20),
              constraints: const BoxConstraints(minHeight: 150),
              decoration: BoxDecoration(color: AppTheme.vermelho, borderRadius: BorderRadius.circular(16), boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 12, offset: Offset(0, 6))]),
              child: Row(children: [
                Container(width: 54, height: 54, decoration: BoxDecoration(color: Colors.white.withValues(alpha: .18), borderRadius: BorderRadius.circular(15)), child: const Icon(Icons.person_rounded, color: Colors.white)),
                const SizedBox(width: 12),
                const Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('Personagens', style: TextStyle(color: Colors.white, fontSize: 21, fontWeight: FontWeight.w900)), SizedBox(height: 3), Text('Explore a tripulação e seus aliados', style: TextStyle(color: Colors.white70, fontSize: 12))])),
                const Icon(Icons.arrow_forward_ios_rounded, color: Colors.white, size: 16),
              ]),
            ),
          ),
          const SizedBox(height: 19),
          Row(children: [const Expanded(child: Text('Categorias', style: TextStyle(fontSize: 19, fontWeight: FontWeight.w900))), Chip(label: const Text('API ONLINE'), avatar: const Icon(Icons.cloud_done_rounded, size: 14), backgroundColor: AppTheme.azulClaro, side: BorderSide.none)]),
          const SizedBox(height: 9),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: categories.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3, crossAxisSpacing: 7, mainAxisSpacing: 7, childAspectRatio: 0.92),
            itemBuilder: (_, index) => _CategoryCard(category: categories[index], onTap: () => _openCategory(categories[index])),
          ),
        ],
      ),
      bottomNavigationBar: AppBottomNav(selectedIndex: _index, onSelected: (value) => setState(() => _index = value)),
    );
  }
}

class _CategoryCard extends StatelessWidget {
  final Map<String, dynamic> category;
  final VoidCallback onTap;
  const _CategoryCard({required this.category, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final color = category['color'] as Color;
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(6),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              Container(width: 23, height: 23, decoration: BoxDecoration(color: color.withValues(alpha: .11), borderRadius: BorderRadius.circular(9)), child: Icon(category['icon'] as IconData, color: color, size: 14)),
              const Spacer(),
              Icon(Icons.arrow_forward_ios_rounded, size: 12, color: color),
            ]),
            const Spacer(),
            Text(category['name'] as String, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 11.5)),
            const SizedBox(height: 2),
            CountBadge(future: category['count'] as Future<int>),
          ]),
        ),
      ),
    );
  }
}
