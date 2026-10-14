import 'package:flutter/material.dart';
import 'screens/home.dart';
import 'services/onepiece_service.dart';
import 'theme/app_theme.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const OnePieceApp());
}

class OnePieceApp extends StatefulWidget {
  const OnePieceApp({super.key});

  @override
  State<OnePieceApp> createState() => _OnePieceAppState();
}

class _OnePieceAppState extends State<OnePieceApp> {
  ThemeMode _themeMode = ThemeMode.system;
  final service = OnePieceService();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'One Piece Wiki',
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: _themeMode,
      home: HomeScreen(service: service),
    );
  }
}
