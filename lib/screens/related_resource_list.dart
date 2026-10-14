import 'package:flutter/material.dart';
import '../widgets/app_header.dart';
import '../widgets/state_view.dart';
import '../widgets/resource_card.dart';
import 'resource_detail.dart';

class RelatedResourceList extends StatefulWidget {
  final String title;
  final IconData icon;
  final String category;
  final Future<List<dynamic>> Function() loadItems;
  final Future<int> Function()? loadCount;

  const RelatedResourceList({super.key, required this.title, required this.icon, required this.category, required this.loadItems, this.loadCount});

  @override
  State<RelatedResourceList> createState() => _RelatedResourceListState();
}

class _RelatedResourceListState extends State<RelatedResourceList> {
  late Future<List<dynamic>> _future;
  @override
  void initState() { super.initState(); _future = widget.loadItems(); }
  void _retry() => setState(() => _future = widget.loadItems());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppHeader(title: widget.title),
      body: FutureBuilder<List<dynamic>>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) return const LoadingView();
          if (snapshot.hasError) return ErrorView(message: snapshot.error.toString().replaceFirst('Exception: ', ''), onRetry: _retry);
          final items = snapshot.data ?? [];
          if (items.isEmpty) {
            return Center(child: Padding(padding: const EdgeInsets.all(30), child: Text('Nenhum registro relacionado encontrado na API.\n\nSe a relação existir com outro formato de campo, ela também é procurada automaticamente.', textAlign: TextAlign.center, style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant))));
          }
          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 28),
            children: [
              if (widget.loadCount != null) FutureBuilder<int>(future: widget.loadCount!(), builder: (context, s) => Padding(padding: const EdgeInsets.only(bottom: 10), child: Text(s.hasData ? '${s.data} resultados encontrados' : 'Resultados', style: const TextStyle(fontWeight: FontWeight.w700, color: Color(0xFF68706A))))),
              ...items.map((item) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: ResourceCard(
                  title: item.displayName.toString(),
                  subtitle: item.id == null ? 'API One Piece' : 'ID ${item.id}',
                  icon: widget.icon,
                  data: Map<String, dynamic>.from(item.data as Map),
                  onTap: item.id == null ? null : () => Navigator.push(context, MaterialPageRoute(builder: (_) => ResourceDetail(title: item.displayName.toString(), data: Map<String, dynamic>.from(item.data as Map), category: widget.category, itemId: item.id, icon: widget.icon))),
                ),
              )),
            ],
          );
        },
      ),
    );
  }
}
