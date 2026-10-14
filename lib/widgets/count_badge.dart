import 'package:flutter/material.dart';

class CountBadge extends StatelessWidget {
  final Future<int> future;
  const CountBadge({super.key, required this.future});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<int>(
      future: future,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return Chip(
            avatar: const Icon(Icons.numbers, size: 18),
            label: Text('${snapshot.data}'),
          );
        }
        if (snapshot.hasError) return const SizedBox.shrink();
        return const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2));
      },
    );
  }
}
