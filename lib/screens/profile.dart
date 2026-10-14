import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../theme/app_theme.dart';
import '../widgets/app_header.dart';
import '../widgets/bottom_nav.dart';

class ProfileScreen extends StatefulWidget {
  final VoidCallback? onHome;
  final VoidCallback? onFavorites;
  const ProfileScreen({super.key, this.onHome, this.onFavorites});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _name = TextEditingController();
  final _age = TextEditingController();
  final _anime = TextEditingController();
  final _character = TextEditingController();
  Uint8List? _photo;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final prefs = await SharedPreferences.getInstance();
    final encoded = prefs.getString('profile_photo');
    if (!mounted) return;
    setState(() {
      _name.text = prefs.getString('profile_name') ?? '';
      _age.text = prefs.getString('profile_age') ?? '';
      _anime.text = prefs.getString('profile_anime') ?? '';
      _character.text = prefs.getString('profile_character') ?? '';
      if (encoded != null && encoded.isNotEmpty) _photo = base64Decode(encoded);
      _loading = false;
    });
  }

  Future<void> _pickPhoto() async {
    try {
      final file = await ImagePicker().pickImage(source: ImageSource.gallery, imageQuality: 60);
      if (file == null) return;
      final bytes = await file.readAsBytes();
      setState(() => _photo = bytes);
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Não foi possível selecionar a foto.')));
    }
  }

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('profile_name', _name.text.trim());
    await prefs.setString('profile_age', _age.text.trim());
    await prefs.setString('profile_anime', _anime.text.trim());
    await prefs.setString('profile_character', _character.text.trim());
    if (_photo != null) await prefs.setString('profile_photo', base64Encode(_photo!));
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Perfil salvo neste dispositivo.')));
  }

  @override
  void dispose() {
    _name.dispose();
    _age.dispose();
    _anime.dispose();
    _character.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const Scaffold(body: Center(child: CircularProgressIndicator()));

    return Scaffold(
      appBar: const AppHeader(title: 'Meu perfil'),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 10, 16, 30),
        children: [
          Container(
            padding: const EdgeInsets.fromLTRB(16, 18, 16, 16),
            decoration: BoxDecoration(color: Colors.white, border: Border.all(color: AppTheme.dourado.withValues(alpha: .65)), borderRadius: BorderRadius.circular(15)),
            child: Column(
              children: [
                GestureDetector(
                  onTap: _pickPhoto,
                  child: Stack(
                    alignment: Alignment.bottomRight,
                    children: [
                      CircleAvatar(
                        radius: 42,
                        backgroundColor: AppTheme.azulClaro,
                        backgroundImage: _photo == null ? null : MemoryImage(_photo!),
                        child: _photo == null ? const Icon(Icons.person_rounded, size: 42, color: AppTheme.vermelho) : null,
                      ),
                      Container(width: 26, height: 26, decoration: const BoxDecoration(color: AppTheme.dourado, shape: BoxShape.circle), child: const Icon(Icons.camera_alt_rounded, size: 14, color: AppTheme.marinho)),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                const Text('Perfil do Pirata', style: TextStyle(fontSize: 19, fontWeight: FontWeight.w900)),
                const SizedBox(height: 4),
                Text('Personalize seus dados e mantenha tudo salvo localmente.', textAlign: TextAlign.center, style: TextStyle(fontSize: 11, color: Theme.of(context).colorScheme.onSurfaceVariant)),
                const SizedBox(height: 17),
                _field(_name, 'Nome', Icons.person_outline_rounded),
                const SizedBox(height: 9),
                _field(_age, 'Idade', Icons.cake_outlined, keyboard: TextInputType.number),
                const SizedBox(height: 9),
                _field(_anime, 'Anime favorito', Icons.tv_outlined),
                const SizedBox(height: 9),
                _field(_character, 'Personagem favorito', Icons.star_outline_rounded),
                const SizedBox(height: 14),
                SizedBox(width: double.infinity, child: FilledButton(onPressed: _save, style: FilledButton.styleFrom(backgroundColor: AppTheme.vermelho, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))), child: const Text('Salvar perfil'))),
              ],
            ),
          ),
          const SizedBox(height: 13),
          Card(color: const Color(0xFFFFF3C9), child: const Padding(padding: EdgeInsets.all(13), child: Row(children: [Icon(Icons.cloud_off_rounded, color: AppTheme.vermelho, size: 19), SizedBox(width: 9), Expanded(child: Text('Seu perfil funciona sem internet e fica salvo neste aparelho.', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700)))]))),
        ],
      ),
      bottomNavigationBar: AppBottomNav(selectedIndex: 2, onSelected: (index) { if (index == 0) widget.onHome?.call(); if (index == 1) widget.onFavorites?.call(); }),
    );
  }

  Widget _field(TextEditingController controller, String label, IconData icon, {TextInputType? keyboard}) {
    return TextField(
      controller: controller,
      keyboardType: keyboard,
      decoration: InputDecoration(
        hintText: label,
        prefixIcon: Icon(icon, size: 18),
        fillColor: const Color(0xFFFFF3C9),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: AppTheme.dourado)),
      ),
    );
  }
}
