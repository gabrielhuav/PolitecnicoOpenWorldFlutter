import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

// Cambiamos el estado a un Mapa donde la llave es el ID del jugador
final multiplayerProvider = StateNotifierProvider<MultiplayerNotifier, Map<String, LatLng>>((ref) {
  return MultiplayerNotifier();
});

class MultiplayerNotifier extends StateNotifier<Map<String, LatLng>> {
  late WebSocketChannel _channel;

  MultiplayerNotifier() : super({}) {
    _connect();
  }

  void _connect() {
    // IMPORTANTE: Cambia la URL por la IP de tu servidor local o remoto
    _channel = WebSocketChannel.connect(Uri.parse('ws://192.168.1.XX:8080/multiplayer'));

    _channel.stream.listen((message) {
      final data = jsonDecode(message);
      final playerId = data['playerId'].toString();
      final position = LatLng(data['lat'], data['lon']);

      state = {
        ...state,
        playerId: position,
      };
    });
  }

  void broadcastMovement(LatLng position) {
    // Enviamos nuestra posición al servidor
    _channel.sink.add(jsonEncode({
      'lat': position.latitude,
      'lon': position.longitude,
    }));
  }

  @override
  void dispose() {
    _channel.sink.close();
    super.dispose();
  }
}