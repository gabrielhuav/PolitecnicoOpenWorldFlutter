import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../state/character_provider.dart';
import '../widgets/character_card.dart';
import 'world_map_screen.dart';

class CharacterSelectionScreen extends ConsumerStatefulWidget {
  const CharacterSelectionScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<CharacterSelectionScreen> createState() =>
      _CharacterSelectionScreenState();
}

class _CharacterSelectionScreenState
    extends ConsumerState<CharacterSelectionScreen> {
  late final PageController _pageController;

  @override
  void initState() {
    super.initState();
    final initialIndex = ref.read(selectedCharacterIndexProvider);
    _pageController = PageController(
      initialPage: initialIndex,
      viewportFraction: 0.62, // muestra parcialmente las cards vecinas
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _goTo(int index, int total) {
    if (index < 0 || index >= total) return;
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 320),
      curve: Curves.easeOut,
    );
  }

  void _startGame(BuildContext context) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const WorldMapScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final characters = ref.watch(availableCharactersProvider);
    final selectedIndex = ref.watch(selectedCharacterIndexProvider);

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF0B1220),
              Color(0xFF152234),
              Color(0xFF1F3A5F),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildTopBar(context),
              const SizedBox(height: 8),
              Expanded(
                child: _buildCarousel(characters, selectedIndex),
              ),
              const SizedBox(height: 16),
              _buildPageIndicator(characters.length, selectedIndex),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  // ============================================
  // TOP BAR (back + título + Iniciar Partida)
  // ============================================
  Widget _buildTopBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 8, 16, 8),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white, size: 28),
            onPressed: () => Navigator.pop(context),
          ),
          const SizedBox(width: 4),
          const Text(
            'Elegir Personaje',
            style: TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.0,
            ),
          ),
          const Spacer(),
          // ---------- BOTÓN INICIAR PARTIDA (esquina superior derecha) ----------
          ElevatedButton.icon(
            onPressed: () => _startGame(context),
            icon: const Icon(Icons.play_arrow_rounded, size: 22),
            label: const Text(
              'Iniciar Partida',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.tealAccent.shade700,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              elevation: 6,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================
  // CARRUSEL PRINCIPAL
  // ============================================
  Widget _buildCarousel(List characters, int selectedIndex) {
    return Stack(
      alignment: Alignment.center,
      children: [
        PageView.builder(
          controller: _pageController,
          itemCount: characters.length,
          onPageChanged: (i) {
            ref.read(selectedCharacterIndexProvider.notifier).state = i;
          },
          itemBuilder: (context, index) {
            final isSelected = index == selectedIndex;
            return CharacterCard(
              character: characters[index],
              isSelected: isSelected,
            );
          },
        ),

        // Flecha izquierda
        Positioned(
          left: 4,
          child: _arrowButton(
            icon: Icons.chevron_left,
            enabled: selectedIndex > 0,
            onTap: () => _goTo(selectedIndex - 1, characters.length),
          ),
        ),

        // Flecha derecha
        Positioned(
          right: 4,
          child: _arrowButton(
            icon: Icons.chevron_right,
            enabled: selectedIndex < characters.length - 1,
            onTap: () => _goTo(selectedIndex + 1, characters.length),
          ),
        ),
      ],
    );
  }

  Widget _arrowButton({
    required IconData icon,
    required bool enabled,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.black.withValues(alpha: enabled ? 0.45 : 0.15),
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: enabled ? onTap : null,
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Icon(
            icon,
            color: enabled ? Colors.white : Colors.white24,
            size: 32,
          ),
        ),
      ),
    );
  }

  // ============================================
  // INDICADOR DE PÁGINAS (puntitos)
  // ============================================
  Widget _buildPageIndicator(int total, int selected) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(total, (i) {
        final active = i == selected;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: active ? 24 : 8,
          height: 8,
          decoration: BoxDecoration(
            color: active
                ? Colors.tealAccent.shade400
                : Colors.white.withValues(alpha: 0.4),
            borderRadius: BorderRadius.circular(4),
          ),
        );
      }),
    );
  }
}
