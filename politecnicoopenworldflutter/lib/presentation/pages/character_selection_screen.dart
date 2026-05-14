import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:politecnicoopenworldflutter/core/utils/app_logger.dart';

import '../state/character_provider.dart';
// Asumiendo que tienes un provider para el mapa, impórtalo aquí
// import '../state/map_provider.dart';
import '../widgets/character_card.dart';
import 'world_map_screen.dart';

import '../../core/utils/providers.dart';

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
    final character = ref.read(selectedCharacterProvider);
    AppLogger.log.i('Iniciando partida con personaje: ${character.id}');
    setState(() => _isLoading = true);

    try {
      // === PRECARGA REAL DEL MAPA ===
      await ref.read(mapStateProvider).loadInitialMapData();

      if (!mounted) return;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const WorldMapScreen()),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
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
        child: OrientationBuilder(
          builder: (context, orientation) {
            final isPortrait = orientation == Orientation.portrait;
            return SafeArea(
              // En landscape desactivamos los lados para usar todo el ancho
              left: isPortrait,
              right: isPortrait,
              child: isPortrait
                  ? _buildVerticalLayout(context, characters, selectedIndex)
                  : _buildHorizontalLayout(context, characters, selectedIndex),
            );
          },
        ),
      ),
    );
  }

  // --- VERTICAL ---
  Widget _buildVerticalLayout(
      BuildContext context, List characters, int selectedIndex) {
    return Column(
      children: [
        _buildTopBar(context, arrowOffset: 4.0),
        const SizedBox(height: 8),
        Expanded(
          child: _buildCarousel(characters, selectedIndex, arrowOffset: 4.0),
        ),
        const SizedBox(height: 14),
        _buildPageIndicator(characters.length, selectedIndex),
        Padding(
          padding: const EdgeInsets.all(10.0),
          child: Row(
            children: [
              Expanded(child: _buildEditButton(context)),
              const SizedBox(width: 12),
              Expanded(child: _buildStartButton(context, double.infinity)),
            ],
          ),
        ),
      ],
    );
  }

  // --- HORIZONTAL ---
  Widget _buildHorizontalLayout(
      BuildContext context, List characters, int selectedIndex) {
    return Column(
      children: [
        _buildTopBar(context, arrowOffset: 60.0),
        Expanded(
          child: _buildCarousel(characters, selectedIndex, arrowOffset: 60.0),
        ),
        const SizedBox(height: 8),
        _buildPageIndicator(characters.length, selectedIndex),
        const SizedBox(height: 6), // ← separa puntitos de los botones
        Padding(
          padding: const EdgeInsets.fromLTRB(50.0, 0, 50.0, 14.0),
          child: Row(
            children: [
              Expanded(child: _buildEditButton(context)),
              const SizedBox(width: 12),
              Expanded(child: _buildStartButton(context, double.infinity)),
            ],
          ),
        ),
      ],
    );
  }

  // ============================================
  // TOP BAR
  // ============================================
  Widget _buildTopBar(BuildContext context, {double arrowOffset = 4.0}) {
    return Padding(
      padding: EdgeInsets.fromLTRB(arrowOffset + 8, 8, 16, 8),
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
    final selectedCharacter = ref.watch(selectedCharacterProvider);
    final isCustomSlot = selectedCharacter.isCustomSlot;

    if (_isLoading) {
      return SizedBox(
        height: 50,
        width: minWidth,
        child: const Center(
          child: CircularProgressIndicator(color: Colors.tealAccent),
        ),
      );
    }

    // Si la card seleccionada es "Personalizar", el botón se deshabilita
    final bool enabled = !isCustomSlot;

    return ElevatedButton.icon(
      onPressed: enabled ? () => _startGame(context) : null,
      icon: Icon(
        enabled ? Icons.play_arrow_rounded : Icons.lock_outline,
        size: 22,
      ),
      label: Text(
        enabled ? 'Iniciar Partida' : 'Personaje no disponible',
        style: const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.bold,
        ),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.tealAccent.shade700,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        minimumSize: minWidth != null ? Size(minWidth, 50) : null,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 2,
        disabledBackgroundColor: Colors.grey.shade800,
        disabledForegroundColor: Colors.white38,
      ),
    );
  }

  Widget _buildEditButton(BuildContext context) {
    final isCustomSlot = ref.watch(selectedCharacterProvider).isCustomSlot;

    return ElevatedButton.icon(
      onPressed: _isLoading
          ? null
          : () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                    content: Text('Editor de personaje próximamente...')),
              );
            },
      icon: Icon(
        isCustomSlot ? Icons.add_circle_outline : Icons.edit_outlined,
        size: 22,
      ),
      label: Text(
        isCustomSlot ? 'Crear personaje' : 'Editar personaje',
        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF1F2A3A),
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
        minimumSize: const Size(double.infinity, 50),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side:
              BorderSide(color: Colors.tealAccent.withOpacity(0.5), width: 1.5),
        ),
        elevation: 2,
        disabledBackgroundColor: Colors.grey.shade800,
        disabledForegroundColor: Colors.white38,
      ),
    );
  }

  // ============================================
  // CARRUSEL PRINCIPAL
  // ============================================
  Widget _buildCarousel(List characters, int selectedIndex,
      {double arrowOffset = 4.0}) {
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
        Positioned(
          left: arrowOffset,
          child: _arrowButton(
            icon: Icons.chevron_left,
            enabled: selectedIndex > 0 && !_isLoading,
            onTap: () => _goTo(selectedIndex - 1, characters.length),
          ),
        ),
        Positioned(
          right: arrowOffset,
          child: _arrowButton(
            icon: Icons.chevron_right,
            enabled: selectedIndex < characters.length - 1 && !_isLoading,
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
