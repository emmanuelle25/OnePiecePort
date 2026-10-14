import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class OfflineArt extends StatelessWidget {
  final IconData icon;
  final double height;
  final String? label;

  const OfflineArt({super.key, required this.icon, this.height = 118, this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFFF0F3EF),
        borderRadius: BorderRadius.circular(18),
      ),
      clipBehavior: Clip.antiAlias,
      child: CustomPaint(
        painter: _WavePainter(),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: AppTheme.vermelho, size: 20),
              ),
              if (label != null) ...[
                const SizedBox(height: 7),
                Text(
                  label!,
                  style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: Color(0xFF68706A)),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _WavePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2
      ..color = const Color(0xFFD9A928).withValues(alpha: .35);

    for (var i = 0; i < 4; i++) {
      final path = Path();
      final y = size.height * (.25 + i * .14);
      path.moveTo(-10, y);
      for (double x = 0; x <= size.width + 20; x += 20) {
        path.quadraticBezierTo(x + 10, y - 9, x + 20, y);
      }
      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
