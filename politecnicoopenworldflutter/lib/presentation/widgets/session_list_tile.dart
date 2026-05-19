import 'package:flutter/material.dart';

import '../../domain/entities/game_session.dart';

/// Tarjeta visual de una partida guardada. Independiente de Riverpod para
/// que se pueda reutilizar y testear de forma aislada.
class SessionListTile extends StatelessWidget {
  final GameSession session;
  final VoidCallback onResume;
  final VoidCallback onDelete;

  const SessionListTile({
    super.key,
    required this.session,
    required this.onResume,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.tealAccent.withValues(alpha: 0.25),
          width: 1,
        ),
      ),
      child: ListTile(
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: CircleAvatar(
          backgroundColor: Colors.tealAccent.shade700,
          child: const Icon(Icons.person, color: Colors.white),
        ),
        title: Text(
          session.characterName,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              '${session.lastLat.toStringAsFixed(5)}, '
              '${session.lastLon.toStringAsFixed(5)}',
              style: const TextStyle(
                color: Colors.white60,
                fontSize: 12,
                fontFeatures: [FontFeature.tabularFigures()],
              ),
            ),
            Text(
              'Actualizada: ${_formatDate(session.updatedAt)}',
              style: const TextStyle(color: Colors.white38, fontSize: 11),
            ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.delete_outline,
                  color: Colors.redAccent, size: 22),
              tooltip: 'Eliminar partida',
              onPressed: onDelete,
            ),
            IconButton(
              icon: const Icon(Icons.play_arrow,
                  color: Colors.tealAccent, size: 26),
              tooltip: 'Reanudar partida',
              onPressed: onResume,
            ),
          ],
        ),
        onTap: onResume,
      ),
    );
  }

  String _formatDate(DateTime d) {
    String two(int n) => n.toString().padLeft(2, '0');
    return '${d.year}-${two(d.month)}-${two(d.day)} '
        '${two(d.hour)}:${two(d.minute)}';
  }
}
