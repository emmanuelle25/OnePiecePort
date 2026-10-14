import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class SearchBox extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String> onSubmitted;
  final VoidCallback onClear;

  const SearchBox({super.key, required this.controller, required this.onSubmitted, required this.onClear});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
      child: TextField(
        controller: controller,
        textInputAction: TextInputAction.search,
        onChanged: onSubmitted,
        decoration: InputDecoration(
          hintText: 'Buscar por nome',
          prefixIcon: const Icon(Icons.search_rounded, size: 20),
          suffixIcon: controller.text.isEmpty
              ? null
              : IconButton(tooltip: 'Limpar pesquisa', onPressed: onClear, icon: const Icon(Icons.close_rounded)),
          prefixIconColor: AppTheme.vermelho,
          fillColor: const Color(0xFFFFF3C9),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(13),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(13),
            borderSide: const BorderSide(color: AppTheme.dourado, width: 1.2),
          ),
        ),
      ),
    );
  }
}
