import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'presentation/pages/start_menu_screen.dart';

void main() {
  // ProviderScope es todo lo que Riverpod necesita para vivir
  runApp(
    const ProviderScope(
      child: PolitecnicoOpenWorldApp(),
    ),
  );
}

class PolitecnicoOpenWorldApp extends StatelessWidget {
  const PolitecnicoOpenWorldApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Politécnico Open World',
      theme: ThemeData(
        primaryColor: const Color(0xFF0F2027),
        useMaterial3: true,
      ),
      home: const StartMenuScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}
