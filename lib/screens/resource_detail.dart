import 'package:flutter/material.dart';
import '../services/favorites_service.dart';
import '../services/onepiece_service.dart';
import '../services/translation_service.dart';
import '../theme/app_theme.dart';
import '../widgets/app_header.dart';

class ResourceDetail extends StatefulWidget {
  final String title;
  final Map<String, dynamic> data;
  final List<Widget> related;
  final IconData icon;
  final String category;
  final dynamic itemId;

  const ResourceDetail({
    super.key,
    required this.title,
    required this.data,
    this.related = const [],
    this.icon = Icons.menu_book_rounded,
    this.category = 'One Piece',
    this.itemId,
  });

  @override
  State<ResourceDetail> createState() => _ResourceDetailState();
}

class _ResourceDetailState extends State<ResourceDetail> {
  final _favorites = FavoritesService();
  bool favorite = false;
  bool loadingFavorite = true;

  @override
  void initState() {
    super.initState();
    _loadFavorite();
  }

  Future<void> _loadFavorite() async {
    final value = await _favorites.contains(widget.category, widget.itemId ?? widget.data['id']);
    if (!mounted) return;
    setState(() {
      favorite = value;
      loadingFavorite = false;
    });
  }

  Future<void> _toggleFavorite() async {
    final saved = await _favorites.toggle(
      category: widget.category,
      id: widget.itemId ?? widget.data['id'],
      title: widget.title,
      data: widget.data,
    );
    if (!mounted) return;
    setState(() => favorite = saved);
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(saved ? 'Salvo em Favoritos.' : 'Removido dos Favoritos.')));
  }

  String _formatKey(String key) => TranslationService.instance.label(key);

  String _formatValue(dynamic value) {
    if (value is Map) return value.entries.map((e) => '${_formatKey(e.key.toString())}: ${_formatValue(e.value)}').join(' • ');
    if (value is List) return value.map(_formatValue).join(', ');
    return value.toString();
  }

  @override
  Widget build(BuildContext context) {
    final visible = widget.data.entries.where((e) {
      return e.value != null && e.value.toString().trim().isNotEmpty;
    }).toList();
    final image = OnePieceService.imageUrl(widget.data);
    final translator = TranslationService.instance;
    final titleFuture = translator.translate(widget.title);
    final translatedEntriesFuture = Future.wait(visible.map((entry) async => MapEntry<String, dynamic>(entry.key, await translator.translateValue(entry.value))));

    return Scaffold(
      appBar: AppHeader(title: 'Detalhes', actions: [
        if (!loadingFavorite)
          IconButton(onPressed: _toggleFavorite, tooltip: favorite ? 'Remover dos favoritos' : 'Salvar nos favoritos', icon: Icon(favorite ? Icons.favorite_rounded : Icons.favorite_border_rounded, color: favorite ? AppTheme.dourado : null)),
      ]),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 30),
        children: [
          if (image != null && image.trim().isNotEmpty) ...[
            ClipRRect(
              borderRadius: BorderRadius.circular(18),
              child: SizedBox(
                height: 210,
                width: double.infinity,
                child: Image.network(
                  image,
                  fit: BoxFit.contain,
                  webHtmlElementStrategy: WebHtmlElementStrategy.prefer,
                  errorBuilder: (_, __, ___) => const SizedBox.shrink(),
                ),
              ),
            ),
            const SizedBox(height: 12),
          ],
          FutureBuilder<String>(future: titleFuture, builder: (context, snapshot) => Text(snapshot.data ?? widget.title, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900))),
          const SizedBox(height: 10),
          OutlinedButton.icon(
            onPressed: loadingFavorite ? null : _toggleFavorite,
            icon: Icon(favorite ? Icons.favorite_rounded : Icons.favorite_border_rounded),
            label: Text(favorite ? 'Salvo nos favoritos' : 'Salvar favorito'),
            style: OutlinedButton.styleFrom(foregroundColor: AppTheme.vermelho, side: const BorderSide(color: AppTheme.vermelho), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(11))),
          ),
          const SizedBox(height: 14),
          Card(
            color: const Color(0xFFFFF3C9),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 13, 16, 16),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const Text('TODOS OS DADOS DA API', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w900, letterSpacing: .8, color: AppTheme.vermelho)),
                const SizedBox(height: 8),
                FutureBuilder<List<MapEntry<String, dynamic>>>(
                  future: translatedEntriesFuture,
                  builder: (context, snapshot) {
                    final entries = snapshot.data ?? visible.map((e) => MapEntry<String, dynamic>(e.key, e.value)).toList();
                    return Column(children: entries.map((entry) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 7),
                      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        SizedBox(width: 105, child: Text(_formatKey(entry.key), style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: Color(0xFF68706A)))),
                        Expanded(child: Text(_formatValue(entry.value), style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w600))),
                      ]),
                    )).toList());
                  },
                ),
              ]),
            ),
          ),
          if (widget.related.isNotEmpty) ...[
            const SizedBox(height: 22),
            const Text('Relacionados', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900)),
            const SizedBox(height: 2),
            ...widget.related,
          ],
        ],
      ),
    );
  }
}
