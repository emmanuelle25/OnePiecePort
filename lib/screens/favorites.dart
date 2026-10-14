import 'package:flutter/material.dart';

import '../services/favorites_service.dart';
import '../services/onepiece_service.dart';
import '../theme/app_theme.dart';
import '../widgets/app_header.dart';
import '../widgets/state_view.dart';
import '../widgets/bottom_nav.dart';
import 'resource_detail.dart';

class FavoritesScreen extends StatefulWidget {
  final VoidCallback? onHome;
  final VoidCallback? onProfile;

  const FavoritesScreen({
    super.key,
    this.onHome,
    this.onProfile,
  });

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  final FavoritesService _favorites = FavoritesService();
  late Future<List<Map<String, dynamic>>> _future;

  @override
  void initState() {
    super.initState();
    _loadFavorites();
  }

  void _loadFavorites() {
    _future = _favorites.getAll();
  }

  void _reload() {
    setState(_loadFavorites);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const AppHeader(title: 'Favoritos'),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const LoadingView();
          }

          if (snapshot.hasError) {
            return ErrorView(
              message: snapshot.error.toString(),
              onRetry: _reload,
            );
          }

          final items = snapshot.data ?? <Map<String, dynamic>>[];

          if (items.isEmpty) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(30),
                child: Text(
                  'Você ainda não salvou nenhum favorito.\n\n'
                  'Abra um personagem, episódio ou outro item '
                  'e toque no coração.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () async {
              _reload();
              await _future;
            },
            child: ListView.separated(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 28),
              itemCount: items.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                return _buildFavoriteItem(context, items[index]);
              },
            ),
          );
        },
      ),
      bottomNavigationBar: AppBottomNav(
        selectedIndex: 1,
        onSelected: (index) {
          if (index == 0) {
            widget.onHome?.call();
          } else if (index == 2) {
            widget.onProfile?.call();
          }
        },
      ),
    );
  }

  Widget _buildFavoriteItem(
    BuildContext context,
    Map<String, dynamic> item,
  ) {
    final rawData = item['data'];
    final Map<String, dynamic> data = rawData is Map
        ? Map<String, dynamic>.from(rawData)
        : <String, dynamic>{};

    final title = item['title']?.toString().trim().isNotEmpty == true
        ? item['title'].toString()
        : 'Favorito';

    final category = item['category']?.toString().trim().isNotEmpty == true
        ? item['category'].toString()
        : 'One Piece';

    final itemId = item['id'];
    final favoriteKey = item['key']?.toString() ?? '$category:$itemId';
    final image = OnePieceService.imageUrl(data);

    return Dismissible(
      key: ValueKey(favoriteKey),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 22),
        decoration: BoxDecoration(
          color: AppTheme.vermelho,
          borderRadius: BorderRadius.circular(18),
        ),
        child: const Icon(
          Icons.delete_outline_rounded,
          color: Colors.white,
        ),
      ),
      onDismissed: (_) async {
        await _favorites.remove(favoriteKey);
        if (mounted) {
          _reload();
        }
      },
      child: Card(
        child: InkWell(
          borderRadius: BorderRadius.circular(22),
          onTap: () async {
            await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => ResourceDetail(
                  title: title,
                  data: data,
                  category: category,
                  itemId: itemId,
                  icon: Icons.favorite_rounded,
                ),
              ),
            );

            if (mounted) {
              _reload();
            }
          },
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: Row(
              children: [
                const SizedBox(
                  width: 42,
                  height: 42,
                  child: Icon(Icons.favorite_rounded, color: AppTheme.vermelho, size: 28),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        category,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                const Icon(Icons.chevron_right_rounded),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildImage(String? image) {
    if (image == null || image.trim().isEmpty) {
      return _placeholder();
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(14),
      child: SizedBox(
        width: 70,
        height: 70,
        child: Image.network(
          image,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => _placeholder(),
          loadingBuilder: (context, child, progress) {
            if (progress == null) {
              return child;
            }

            return Container(
              color: AppTheme.azulClaro,
              alignment: Alignment.center,
              child: const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _placeholder() {
    return Container(
      width: 70,
      height: 70,
      decoration: BoxDecoration(
        color: AppTheme.azulClaro,
        borderRadius: BorderRadius.circular(14),
      ),
      child: const Icon(
        Icons.image_not_supported_outlined,
        color: AppTheme.vermelho,
      ),
    );
  }
}
