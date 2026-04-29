import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'core/utils/providers.dart';
import 'presentation/pages/world_map_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Inicializamos SharedPreferences antes de arrancar la App
  final prefs = await SharedPreferences.getInstance();

  runApp(
    ProviderScope(
      overrides: [
        // Inyectamos la instancia real de SharedPreferences
        sharedPreferencesProvider.overrideWithValue(prefs),
      ],
      child: const PolitecnicoOpenWorldApp(),
    ),
  );
}

class PolitecnicoOpenWorldApp extends StatelessWidget {
  const PolitecnicoOpenWorldApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Politecnico Open World',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(useMaterial3: true),
      home: const WorldMapScreen(),
    );
  }
}