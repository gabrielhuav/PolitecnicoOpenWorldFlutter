import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/utils/app_logger.dart';
import '../../../ui/theme/app_theme.dart';
import '../../../ui/theme/theme_extensions.dart';
import '../../map_exterior/ui/loading_screen.dart';
import '../state/character_provider.dart';
import 'components/character_card.dart';

class CharacterSelectionScreen extends ConsumerStatefulWidget {
  const CharacterSelectionScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<CharacterSelectionScreen> createState() =>
      _CharacterSelectionScreenState();
}

class _CharacterSelectionScreenState
    extends ConsumerState<CharacterSelectionScreen> {
  late final PageController _pageController;
  bool _gameStarting = false;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(
      initialPage: ref.read(selectedCharacterIndexProvider),
      viewportFraction: 0.62,
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
    if (_gameStarting) return;
    setState(() => _gameStarting = true);

    AppLogger.log.i(
      'Iniciando partida con personaje: ${ref.read(selectedCharacterProvider).id}',
    );

    try {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const LoadingScreen()),
      );
    } catch (_) {
      if (mounted) setState(() => _gameStarting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = ref.appTheme;
    final characters = ref.watch(availableCharactersProvider);
    final selectedIndex = ref.watch(selectedCharacterIndexProvider);

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: theme.backgroundGradient,
          ),
        ),
        child: OrientationBuilder(
          builder: (context, orientation) {
            final isPortrait = orientation == Orientation.portrait;
            return SafeArea(
              left: isPortrait,
              right: isPortrait,
              child: isPortrait
                  ? _buildVerticalLayout(theme, characters, selectedIndex)
                  : _buildHorizontalLayout(theme, characters, selectedIndex),
            );
          },
        ),
      ),
    );
  }

  Widget _buildVerticalLayout(
      AppTheme theme, List characters, int selectedIndex) {
    return Column(
      children: [
        _buildTopBar(theme, arrowOffset: 4.0),
        const SizedBox(height: 8),
        Expanded(
          child:
              _buildCarousel(theme, characters, selectedIndex, arrowOffset: 4),
        ),
        const SizedBox(height: 14),
        _buildPageIndicator(theme, characters.length, selectedIndex),
        Padding(
          padding: const EdgeInsets.all(10.0),
          child: Row(
            children: [
              Expanded(child: _buildEditButton(theme)),
              const SizedBox(width: 12),
              Expanded(child: _buildStartButton(theme, double.infinity)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildHorizontalLayout(
      AppTheme theme, List characters, int selectedIndex) {
    return Column(
      children: [
        _buildTopBar(theme, arrowOffset: 60.0),
        Expanded(
          child:
              _buildCarousel(theme, characters, selectedIndex, arrowOffset: 60),
        ),
        const SizedBox(height: 8),
        _buildPageIndicator(theme, characters.length, selectedIndex),
        const SizedBox(height: 6),
        Padding(
          padding: const EdgeInsets.fromLTRB(50.0, 0, 50.0, 14.0),
          child: Row(
            children: [
              Expanded(child: _buildEditButton(theme)),
              const SizedBox(width: 12),
              Expanded(child: _buildStartButton(theme, double.infinity)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTopBar(AppTheme theme, {double arrowOffset = 4.0}) {
    return Padding(
      padding: EdgeInsets.fromLTRB(arrowOffset + 8, 8, 16, 8),
      child: Row(
        children: [
          IconButton(
            icon: Icon(Icons.arrow_back, color: theme.textPrimary, size: 28),
            onPressed: () => Navigator.pop(context),
          ),
          const SizedBox(width: 4),
          Text(
            'Elegir Personaje',
            style: TextStyle(
              color: theme.textPrimary,
              fontSize: 22,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.0,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStartButton(AppTheme theme, double? minWidth) {
    final isCustomSlot = ref.watch(selectedCharacterProvider).isCustomSlot;
    final enabled = !isCustomSlot && !_gameStarting;

    return ElevatedButton.icon(
      onPressed: enabled ? () => _startGame(context) : null,
      icon: Icon(
        isCustomSlot
            ? Icons.lock_outline
            : (_gameStarting ? Icons.hourglass_top : Icons.play_arrow_rounded),
        size: 22,
      ),
      label: Text(
        isCustomSlot
            ? 'Personaje no disponible'
            : (_gameStarting ? 'Iniciando...' : 'Iniciar Partida'),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: theme.buttonPrimary,
        foregroundColor: theme.buttonPrimaryText,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        minimumSize: minWidth != null ? Size(minWidth, 50) : null,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 2,
        disabledBackgroundColor: theme.surfaceOverlay,
        disabledForegroundColor: theme.textTertiary,
      ),
    );
  }

  Widget _buildEditButton(AppTheme theme) {
    final isCustomSlot = ref.watch(selectedCharacterProvider).isCustomSlot;

    return ElevatedButton.icon(
      onPressed: () {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Editor de personaje próximamente...')),
        );
      },
      icon: Icon(
        isCustomSlot ? Icons.add_circle_outline : Icons.edit_outlined,
        size: 22,
      ),
      label: Text(
        isCustomSlot ? 'Crear personaje' : 'Editar personaje',
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: theme.surfacePrimary,
        foregroundColor: theme.textPrimary,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
        minimumSize: const Size(double.infinity, 50),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(
            color: theme.accentSecondary.withValues(alpha: 0.5),
            width: 1.5,
          ),
        ),
        elevation: 2,
      ),
    );
  }

  Widget _buildCarousel(
    AppTheme theme,
    List characters,
    int selectedIndex, {
    double arrowOffset = 4.0,
  }) {
    return Stack(
      alignment: Alignment.center,
      children: [
        PageView.builder(
          controller: _pageController,
          itemCount: characters.length,
          onPageChanged: (i) =>
              ref.read(selectedCharacterIndexProvider.notifier).state = i,
          itemBuilder: (context, index) => CharacterCard(
            character: characters[index],
            isSelected: index == selectedIndex,
          ),
        ),
        Positioned(
          left: arrowOffset,
          child: _arrowButton(
            theme: theme,
            icon: Icons.chevron_left,
            enabled: selectedIndex > 0,
            onTap: () => _goTo(selectedIndex - 1, characters.length),
          ),
        ),
        Positioned(
          right: arrowOffset,
          child: _arrowButton(
            theme: theme,
            icon: Icons.chevron_right,
            enabled: selectedIndex < characters.length - 1,
            onTap: () => _goTo(selectedIndex + 1, characters.length),
          ),
        ),
      ],
    );
  }

  Widget _arrowButton({
    required AppTheme theme,
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
            color: enabled ? theme.textPrimary : theme.textTertiary,
            size: 32,
          ),
        ),
      ),
    );
  }

  Widget _buildPageIndicator(AppTheme theme, int total, int selected) {
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
                ? theme.accentSecondary
                : theme.textPrimary.withValues(alpha: 0.4),
            borderRadius: BorderRadius.circular(4),
          ),
        );
      }),
    );
  }
}
