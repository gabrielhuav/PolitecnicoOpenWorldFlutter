import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/theme_extensions.dart';
import '../../domain/entities/character.dart';

class CharacterCard extends ConsumerWidget {
  final Character character;
  final bool isSelected;

  const CharacterCard({
    Key? key,
    required this.character,
    this.isSelected = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ref.appTheme;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOut,
      margin: EdgeInsets.symmetric(
        horizontal: 12,
        vertical: isSelected ? 0 : 24,
      ),
      decoration: BoxDecoration(
        color: theme.surfacePrimary,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isSelected ? theme.accentSecondary : theme.borderSubtle,
          width: isSelected ? 3 : 1.5,
        ),
        boxShadow: isSelected
            ? [
                BoxShadow(
                  color: theme.accentSecondary.withValues(alpha: 0.35),
                  blurRadius: 18,
                  spreadRadius: 1,
                ),
              ]
            : null,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(13),
        child: Column(
          children: [
            Expanded(
              child: Container(
                width: double.infinity,
                color: theme.surfacePrimary,
                child: _buildImagePlaceholder(theme),
              ),
            ),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              color: theme.surfaceSecondary,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    character.name,
                    style: TextStyle(
                      color: theme.textPrimary,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    character.description,
                    style: TextStyle(
                      color: theme.textSecondary,
                      fontSize: 12,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImagePlaceholder(theme) {
    if (character.imagePath != null && character.imagePath!.isNotEmpty) {
      return Image.asset(character.imagePath!, fit: BoxFit.cover);
    }
    return Center(
      child: DottedBorderBox(
        isCustomSlot: character.isCustomSlot,
        accent: theme.accentSecondary,
        muted: theme.textTertiary,
      ),
    );
  }
}

class DottedBorderBox extends StatelessWidget {
  final bool isCustomSlot;
  final Color accent;
  final Color muted;
  const DottedBorderBox({
    Key? key,
    required this.accent,
    required this.muted,
    this.isCustomSlot = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final color = isCustomSlot ? accent : muted;
    return CustomPaint(
      painter: _DashedRectPainter(color: color),
      child: Container(
        margin: const EdgeInsets.all(20),
        alignment: Alignment.center,
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                isCustomSlot ? Icons.add_circle_outline : Icons.image_outlined,
                size: 64,
                color: color,
              ),
              const SizedBox(height: 8),
              Text(
                isCustomSlot ? 'Crear nuevo' : 'Imagen pendiente',
                style: TextStyle(
                  color: color,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DashedRectPainter extends CustomPainter {
  final Color color;
  _DashedRectPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;
    const dashWidth = 8.0;
    const dashSpace = 6.0;
    final rect = Rect.fromLTWH(8, 8, size.width - 16, size.height - 16);
    double x = rect.left;
    while (x < rect.right) {
      canvas.drawLine(
          Offset(x, rect.top), Offset(x + dashWidth, rect.top), paint);
      canvas.drawLine(
          Offset(x, rect.bottom), Offset(x + dashWidth, rect.bottom), paint);
      x += dashWidth + dashSpace;
    }
    double y = rect.top;
    while (y < rect.bottom) {
      canvas.drawLine(
          Offset(rect.left, y), Offset(rect.left, y + dashWidth), paint);
      canvas.drawLine(
          Offset(rect.right, y), Offset(rect.right, y + dashWidth), paint);
      y += dashWidth + dashSpace;
    }
  }

  @override
  bool shouldRepaint(covariant _DashedRectPainter oldDelegate) =>
      oldDelegate.color != color;
}
