import 'package:flutter/material.dart';
import '../../domain/entities/character.dart';

/// Card del personaje. Muestra un cuadro vacío como placeholder de imagen.
/// Cuando tengas la imagen real, sólo agrega `imagePath` al `Character` y
/// el widget la dibujará automáticamente.
class CharacterCard extends StatelessWidget {
  final Character character;
  final bool isSelected;

  const CharacterCard({
    Key? key,
    required this.character,
    this.isSelected = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOut,
      margin: EdgeInsets.symmetric(
        horizontal: 12,
        vertical: isSelected ? 0 : 24,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFF1F2A3A),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isSelected ? Colors.tealAccent.shade400 : Colors.white24,
          width: isSelected ? 3 : 1.5,
        ),
        boxShadow: isSelected
            ? [
                BoxShadow(
                  color: Colors.tealAccent.withValues(alpha: 0.35),
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
            // ---------- ZONA DE IMAGEN (PLACEHOLDER) ----------
            Expanded(
              child: Container(
                width: double.infinity,
                color: const Color(0xFF0F1722),
                child: _buildImagePlaceholder(),
              ),
            ),

            // ---------- INFO ----------
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              color: const Color(0xFF263243),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    character.name,
                    style: const TextStyle(
                      color: Colors.white,
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
                      color: Colors.white.withValues(alpha: 0.65),
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

  Widget _buildImagePlaceholder() {
    // Si en el futuro le pasas imagePath, lo pinta directo:
    if (character.imagePath != null && character.imagePath!.isNotEmpty) {
      return Image.asset(
        character.imagePath!,
        fit: BoxFit.cover,
      );
    }

    // Cuadro vacío estilizado mientras no haya imagen.
    return Center(
      child: DottedBorderBox(
        isCustomSlot: character.isCustomSlot,
      ),
    );
  }
}

/// Cuadro vacío con bordes punteados para indicar "espacio para imagen".
class DottedBorderBox extends StatelessWidget {
  final bool isCustomSlot;
  const DottedBorderBox({Key? key, this.isCustomSlot = false})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _DashedRectPainter(
        color: isCustomSlot ? Colors.tealAccent.shade100 : Colors.white38,
      ),
      child: Container(
        margin: const EdgeInsets.all(20),
        alignment: Alignment.center,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isCustomSlot ? Icons.add_circle_outline : Icons.image_outlined,
              size: 64,
              color: isCustomSlot ? Colors.tealAccent.shade100 : Colors.white54,
            ),
            const SizedBox(height: 8),
            Text(
              isCustomSlot ? 'Crear nuevo' : 'Imagen pendiente',
              style: TextStyle(
                color:
                    isCustomSlot ? Colors.tealAccent.shade100 : Colors.white54,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
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

    // Top
    double startX = rect.left;
    while (startX < rect.right) {
      canvas.drawLine(
        Offset(startX, rect.top),
        Offset(startX + dashWidth, rect.top),
        paint,
      );
      startX += dashWidth + dashSpace;
    }
    // Bottom
    startX = rect.left;
    while (startX < rect.right) {
      canvas.drawLine(
        Offset(startX, rect.bottom),
        Offset(startX + dashWidth, rect.bottom),
        paint,
      );
      startX += dashWidth + dashSpace;
    }
    // Left
    double startY = rect.top;
    while (startY < rect.bottom) {
      canvas.drawLine(
        Offset(rect.left, startY),
        Offset(rect.left, startY + dashWidth),
        paint,
      );
      startY += dashWidth + dashSpace;
    }
    // Right
    startY = rect.top;
    while (startY < rect.bottom) {
      canvas.drawLine(
        Offset(rect.right, startY),
        Offset(rect.right, startY + dashWidth),
        paint,
      );
      startY += dashWidth + dashSpace;
    }
  }

  @override
  bool shouldRepaint(covariant _DashedRectPainter oldDelegate) =>
      oldDelegate.color != color;
}
