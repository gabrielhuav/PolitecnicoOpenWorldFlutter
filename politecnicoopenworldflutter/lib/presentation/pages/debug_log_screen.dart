import 'package:flutter/material.dart';
import '../../core/utils/app_logger.dart';

class DebugLogScreen extends StatefulWidget {
  const DebugLogScreen({super.key});
  @override
  State<DebugLogScreen> createState() => _DebugLogScreenState();
}

class _DebugLogScreenState extends State<DebugLogScreen> {
  String _content = 'Cargando...';

  @override
  void initState() {
    super.initState();
    AppLogger.readLog().then((s) {
      if (!mounted) return;
      setState(() => _content = s.isEmpty ? '(sin logs)' : s);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Logs de errores'),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_forever),
            onPressed: () async {
              await AppLogger.clearLog();
              if (!mounted) return;
              setState(() => _content = '(log limpiado)');
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(12),
        child: SelectableText(
          _content,
          style: const TextStyle(fontFamily: 'monospace', fontSize: 11),
        ),
      ),
    );
  }
}
