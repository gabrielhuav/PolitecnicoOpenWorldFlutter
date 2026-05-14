import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';

class AppSettingsScreen extends StatelessWidget {
  const AppSettingsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const _AppSettingsView();
  }
}

class _AppSettingsView extends StatefulWidget {
  const _AppSettingsView();

  @override
  State<_AppSettingsView> createState() => _AppSettingsViewState();
}

class _AppSettingsViewState extends State<_AppSettingsView> {
  late final Future<PackageInfo> _packageInfoFuture = PackageInfo.fromPlatform();

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
          child: Column(
            children: [
              // ── Top bar ─────────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.fromLTRB(8, 8, 16, 8),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back,
                          color: Colors.white, size: 28),
                      onPressed: () => Navigator.pop(context),
                    ),
                    const SizedBox(width: 4),
                    const Text(
                      'Acerca de la app',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.0,
                      ),
                    ),
                  ],
                ),
              ),

              // ── Contenido (placeholder) ──────────────────────────────
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    FutureBuilder<PackageInfo>(
                      future: _packageInfoFuture,
                      builder: (context, snapshot) {
                        final package = snapshot.data;
                        final version = package == null
                            ? 'Cargando...'
                            : '${package.version}+${package.buildNumber}';
                        return _buildInfoCard(
                          icon: Icons.info_outline,
                          title: 'Versión',
                          value: version,
                        );
                      },
                    ),
                    _buildInfoCard(
                      icon: Icons.code,
                      title: 'Desarrolladores',
                      value: 'Próximamente...',
                    ),
                    _buildInfoCard(
                      icon: Icons.star_outline,
                      title: 'Créditos',
                      value: 'Próximamente...',
                    ),
                    _buildInfoCard(
                      icon: Icons.map_outlined,
                      title: 'Datos del mapa',
                      value: 'OpenStreetMap contributors',
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoCard({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: Colors.tealAccent.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.tealAccent, size: 22),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white54,
                    fontSize: 12,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
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
