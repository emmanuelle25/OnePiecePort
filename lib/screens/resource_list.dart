import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/app_header.dart';
import '../widgets/search_box.dart';
import '../widgets/state_view.dart';
import '../widgets/resource_card.dart';

class ResourceListScreen extends StatefulWidget {
  final String title;
  final IconData icon;
  final Future<List<dynamic>> Function() loadItems;
  final Future<List<dynamic>> Function(String value) searchItems;
  final void Function(dynamic item) openItem;
  final List<Widget> actions;

  const ResourceListScreen({
    super.key,
    required this.title,
    required this.icon,
    required this.loadItems,
    required this.searchItems,
    required this.openItem,
    this.actions = const [],
  });

  @override
  State<ResourceListScreen> createState() => _ResourceListScreenState();
}

class _ResourceListScreenState extends State<ResourceListScreen> {
  final _search = TextEditingController();
  late Future<List<dynamic>> _future;
  bool _showAll = true;

  @override
  void initState() {
    super.initState();
    _future = widget.loadItems();
    _search.addListener(() => setState(() {}));
  }

  void _reload() => setState(() => _future = widget.loadItems());

  void _searchData(String value) {
    final query = value.trim();
    setState(() {
      _showAll = query.isEmpty;
      _future = query.isEmpty ? widget.loadItems() : widget.searchItems(query);
    });
  }

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppHeader(title: widget.title, actions: widget.actions),
      body: Column(
        children: [
          SearchBox(controller: _search, onSubmitted: _searchData, onClear: () { _search.clear(); _reload(); }),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
            child: Row(
              children: [
                ChoiceChip(
                  label: const Text('Todos'),
                  selected: _showAll,
                  onSelected: (_) => _searchData(''),
                  avatar: const Icon(Icons.check_circle_outline_rounded, size: 15),
                ),
                const SizedBox(width: 7),
                Chip(
                  label: const Text('Offline'),
                  avatar: const Icon(Icons.cloud_off_rounded, size: 15),
                  backgroundColor: AppTheme.azulClaro,
                  side: BorderSide.none,
                ),
              ],
            ),
          ),
          Expanded(
            child: FutureBuilder<List<dynamic>>(
              future: _future,
              builder: (context, snapshot) {
                if (snapshot.connectionState != ConnectionState.done) return const LoadingView();
                if (snapshot.hasError) {
                  return ErrorView(
                    message: snapshot.error.toString().replaceFirst('Exception: ', ''),
                    onRetry: _reload,
                  );
                }
                final items = snapshot.data ?? [];
                if (items.isEmpty) return const EmptyView();

                return LayoutBuilder(
                  builder: (context, constraints) {
                    final columns = constraints.maxWidth >= 850 ? 3 : constraints.maxWidth >= 560 ? 2 : 1;
                    return GridView.builder(
                      padding: const EdgeInsets.fromLTRB(16, 4, 16, 28),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: columns,
                        crossAxisSpacing: 10,
                        mainAxisSpacing: 10,
                        childAspectRatio: columns == 1 ? 2.35 : 1.34,
                      ),
                      itemCount: items.length,
                      itemBuilder: (context, index) {
                        final item = items[index];
                        return ResourceCard(
                          title: item.displayName.toString(),
                          subtitle: item.id == null ? 'API One Piece' : 'ID ${item.id} • API One Piece',
                          icon: widget.icon,
                          data: Map<String, dynamic>.from(item.data as Map),
                          onTap: () => widget.openItem(item),
                        );
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
