import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../state/character_provider.dart';
// Asumiendo que tienes un provider para el mapa, impórtalo aquí
// import '../state/map_provider.dart';
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

  // === NUEVO: Estado de carga ===
  bool _isLoading = false;

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

  // === NUEVO: Lógica asíncrona de precarga ===
  Future<void> _startGame(BuildContext context) async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Aquí invocas la precarga del mapa usando Riverpod.
      // Ejemplo: await ref.read(mapProvider.notifier).preloadWorldData();

      // Simulamos un tiempo de carga mientras implementas el provider real
      await Future.delayed(const Duration(seconds: 2));

      // Revisamos si el widget sigue montado antes de navegar
      if (!mounted) return;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const WorldMapScreen()),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al cargar el mapa: $e'),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final characters = ref.watch(availableCharactersProvider);
    final selectedIndex = ref.watch(selectedCharacterIndexProvider);

    return Scaffold(
      body: Container(
        // === LADO VISUAL: Fondo con Gradiente (Código 1) ===
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
          // === FUNCIONALIDAD: Layout Responsivo (Código 2) ===
          child: OrientationBuilder(
            builder: (context, orientation) {
              return orientation == Orientation.portrait
                  ? _buildVerticalLayout(context, characters, selectedIndex)
                  : _buildHorizontalLayout(context, characters, selectedIndex);
            },
          ),
        ),
      ),
    );
  }

  // --- VERTICAL ---
  Widget _buildVerticalLayout(
      BuildContext context, List characters, int selectedIndex) {
    return Column(
      children: [
        _buildTopBar(context),
        const SizedBox(height: 8),
        Expanded(
          child: _buildCarousel(characters, selectedIndex),
        ),
        const SizedBox(height: 16),
        _buildPageIndicator(characters.length, selectedIndex),
        // Botón en la parte inferior, ancho completo
        Padding(
          padding: const EdgeInsets.all(20.0),
          child: _buildStartButton(context, double.infinity),
        ),
      ],
    );
  }

  // --- HORIZONTAL ---
  Widget _buildHorizontalLayout(
      BuildContext context, List characters, int selectedIndex) {
    return Row(
      children: [
        // Lado izquierdo: Personajes y TopBar
        Expanded(
          flex: 2,
          child: Column(
            children: [
              _buildTopBar(context),
              Expanded(
                child: _buildCarousel(characters, selectedIndex),
              ),
              const SizedBox(height: 16),
              _buildPageIndicator(characters.length, selectedIndex),
              const SizedBox(height: 16),
            ],
          ),
        ),
        // Lado derecho: Botón de iniciar centrado
        Expanded(
          flex: 1,
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: _buildStartButton(context, null),
            ),
          ),
        ),
      ],
    );
  }

  // ============================================
  // TOP BAR
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
        ],
      ),
    );
  }

  // ============================================
  // BOTÓN "INICIAR PARTIDA" (Modificado con _isLoading)
  // ============================================
  Widget _buildStartButton(BuildContext context, double? minWidth) {
    // Si está cargando, mostramos el indicador en lugar del botón
    if (_isLoading) {
      return SizedBox(
        height: 50, // Altura estándar del botón para evitar saltos en la UI
        width: minWidth,
        child: const Center(
          child: CircularProgressIndicator(
            color: Colors.tealAccent,
          ),
        ),
      );
    }

    return ElevatedButton.icon(
      onPressed: () => _startGame(context),
      icon: const Icon(Icons.play_arrow_rounded, size: 26),
      label: const Text(
        'Iniciar Partida',
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.tealAccent.shade700,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        minimumSize: minWidth != null ? Size(minWidth, 50) : null,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        elevation: 6,
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
            enabled: selectedIndex > 0 &&
                !_isLoading, // Deshabilita si está cargando
            onTap: () => _goTo(selectedIndex - 1, characters.length),
          ),
        ),

        // Flecha derecha
        Positioned(
          right: 4,
          child: _arrowButton(
            icon: Icons.chevron_right,
            enabled: selectedIndex < characters.length - 1 &&
                !_isLoading, // Deshabilita si está cargando
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
      color: Colors.black.withOpacity(enabled ? 0.45 : 0.15),
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
                : Colors.white.withOpacity(0.4),
            borderRadius: BorderRadius.circular(4),
          ),
        );
      }),
    );
  }
}
