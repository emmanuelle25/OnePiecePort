import 'package:flutter/material.dart';
import '../services/onepiece_service.dart';
import '../services/translation_service.dart';
import '../theme/app_theme.dart';
import 'offline_art.dart';

class ResourceCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback? onTap;
  final Map<String, dynamic>? data;

  const ResourceCard({super.key, required this.title, required this.subtitle, required this.icon, this.onTap, this.data});

  String _secondary() {
    if (data == null) return subtitle;
    final preferred = ['role', 'type', 'bounty', 'year', 'number', 'effect', 'description'];
    for (final key in preferred) {
      final value = data![key];
      if (value != null && value.toString().trim().isNotEmpty) return value.toString();
    }
    return subtitle;
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final image = data == null ? null : OnePieceService.imageUrl(data!);
    final translatedTitle = TranslationService.instance.translate(title);
    final secondary = TranslationService.instance.translate(_secondary());
    return Card(
      clipBehavior: Clip.antiAlias,
      margin: EdgeInsets.zero,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(9, 9, 9, 9),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(18),
              child: SizedBox(
                height: 64,
                width: double.infinity,
                child: image == null
                    ? OfflineArt(icon: icon, height: 64)
                    : Image.network(image, fit: BoxFit.contain, webHtmlElementStrategy: WebHtmlElementStrategy.prefer, errorBuilder: (_, __, ___) => OfflineArt(icon: icon, height: 64)),
              ),
            ),
            const SizedBox(height: 7),
            FutureBuilder<String>(future: translatedTitle, builder: (context, snapshot) => Text(snapshot.data ?? title, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 12.5))),
            const SizedBox(height: 3),
            FutureBuilder<String>(future: secondary, builder: (context, snapshot) => Text(snapshot.data ?? _secondary(), maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(color: scheme.onSurfaceVariant, fontSize: 10.5))),
            const SizedBox(height: 6),
            Row(children: [Expanded(child: Container(height: 3, decoration: BoxDecoration(color: AppTheme.vermelho.withValues(alpha: .12), borderRadius: BorderRadius.circular(20)))), const SizedBox(width: 6), const Icon(Icons.chevron_right_rounded, size: 16, color: AppTheme.vermelho)]),
          ]),
        ),
      ),
    );
  }
}
