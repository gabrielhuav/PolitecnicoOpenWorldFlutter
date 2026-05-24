import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../state/multiplayer_notifier.dart';

class MultiplayerLayer extends ConsumerWidget {
  const MultiplayerLayer({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final otherPlayers = ref.watch(multiplayerProvider);

    return MarkerLayer(
      markers: otherPlayers.entries.map((entry) {
        return Marker(
          point: entry.value,
          width: 30,
          height: 30,
          child: const Icon(Icons.person_pin, color: Colors.red, size: 30),
        );
      }).toList(),
    );
  }
}