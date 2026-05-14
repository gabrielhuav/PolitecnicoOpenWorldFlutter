import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/utils/providers.dart';
import 'world_map_screen.dart';

class LoadingScreen extends ConsumerStatefulWidget {
  const LoadingScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<LoadingScreen> createState() => _LoadingScreenState();
}

class _LoadingScreenState extends ConsumerState<LoadingScreen>
    with SingleTickerProviderStateMixin {
  // ── Consejos estáticos (por ahora) ──────────────────────────────────
  static const List<String> _tips = [
    'ESCOM fue fundada en 1974 como parte del IPN.',
    'El campus tiene más de 6,000 estudiantes activos.',
    'Puedes explorar las calles reales del campus con datos de OpenStreetMap.',
    'Usa el D-pad para moverte por el mapa del Politécnico.',
    'El botón de recentrar te regresa a tu posición actual en el mapa.',
    'Próximamente podrás personalizar tu propio personaje.',
  ];

  late final AnimationController _pulseController;
  late final Animation<double> _pulseAnimation;

  String _statusText = 'Inicializando el mundo…';
  bool _hasError = false;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();

    // Animación de pulso para el indicador
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 0.85, end: 1.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    // Arranca la carga en el siguiente frame para que la UI ya esté montada
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadMap());
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  Future<void> _loadMap() async {
    try {
      setState(() => _statusText = 'Descargando calles del campus…');
      await ref.read(mapStateProvider).loadInitialMapData();

      if (!mounted) return;
      setState(() => _statusText = '¡Listo para jugar!');

      // Pequeña pausa para que el usuario vea el mensaje de éxito
      await Future.delayed(const Duration(milliseconds: 600));

      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const WorldMapScreen()),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _hasError = true;
        _errorMessage = e.toString();
        _statusText = 'Error al cargar el mapa';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
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
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32.0),
            child: Column(
              children: [
                const Spacer(flex: 2),

                // ── Logo ────────────────────────────────────────────
                const Icon(
                  Icons.map_outlined,
                  size: 72,
                  color: Colors.white70,
                ),
                const SizedBox(height: 16),
                const Text(
                  'Politécnico Open World',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: 1.5,
                  ),
                ),

                const Spacer(flex: 2),

                // ── Indicador de carga o error ───────────────────────
                if (!_hasError) ...[
                  ScaleTransition(
                    scale: _pulseAnimation,
                    child: Container(
                      width: 72,
                      height: 72,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.tealAccent.withOpacity(0.12),
                        border: Border.all(
                          color: Colors.tealAccent.shade400,
                          width: 2,
                        ),
                      ),
                      child: const Padding(
                        padding: EdgeInsets.all(18.0),
                        child: CircularProgressIndicator(
                          color: Colors.tealAccent,
                          strokeWidth: 3,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    _statusText,
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                      letterSpacing: 0.5,
                    ),
                  ),
                ] else ...[
                  const Icon(Icons.error_outline,
                      color: Colors.redAccent, size: 56),
                  const SizedBox(height: 12),
                  Text(
                    _errorMessage,
                    textAlign: TextAlign.center,
                    style:
                        const TextStyle(color: Colors.redAccent, fontSize: 13),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton.icon(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.arrow_back),
                    label: const Text('Regresar'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white12,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ],

                const Spacer(flex: 2),

                // ── Consejo ─────────────────────────────────────────
                _TipCard(tips: _tips),

                const Spacer(flex: 1),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ── Widget del consejo ────────────────────────────────────────────────
class _TipCard extends StatelessWidget {
  final List<String> tips;

  const _TipCard({required this.tips});

  @override
  Widget build(BuildContext context) {
    // Consejo fijo por ahora; más adelante lo haremos rotativo
    const int tipIndex = 0;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.06),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: Colors.tealAccent.withOpacity(0.25),
          width: 1,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.lightbulb_outline,
              color: Colors.tealAccent, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'CONSEJO',
                  style: TextStyle(
                    color: Colors.tealAccent,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  tips[tipIndex],
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 13,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
