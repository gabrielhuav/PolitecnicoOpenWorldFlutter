import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:logger/logger.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

class _FileLogOutput extends LogOutput {
  final File logFile;
  _FileLogOutput(this.logFile);

  @override
  void output(OutputEvent event) {
    final lines = event.lines.join('\n');
    logFile.writeAsStringSync('$lines\n', mode: FileMode.append, flush: true);
  }
}

class AppLogger {
  static Logger? _instance;
  static File? _logFile;

  static Future<void> init() async {
    final dir = await getApplicationDocumentsDirectory();
    _logFile = File(p.join(dir.path, 'pow_errors.log'));
    _instance = Logger(
      printer: PrettyPrinter(
        methodCount: 4,
        dateTimeFormat: DateTimeFormat.onlyTimeAndSinceStart,
      ),
      output: MultiOutput([
        ConsoleOutput(),
        _FileLogOutput(_logFile!),
      ]),
      level: kDebugMode ? Level.debug : Level.warning,
    );
  }

  static Logger get log {
    assert(_instance != null, 'AppLogger.init() no fue llamado');
    return _instance!;
  }

  static Future<String> readLog() async {
    if (_logFile == null || !_logFile!.existsSync()) return '';
    return _logFile!.readAsString();
  }

  static Future<void> clearLog() async {
    if (_logFile?.existsSync() == true) await _logFile!.delete();
  }
}
