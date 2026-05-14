import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:logger/logger.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

class _FileLogOutput extends LogOutput {
  final File logFile;
  Future<void> _pendingWrite = Future<void>.value();
  _FileLogOutput(this.logFile);

  @override
  void output(OutputEvent event) {
    final lines = event.lines.join('\n');
    _pendingWrite = _pendingWrite.then((_) {
      return logFile.writeAsString('$lines\n', mode: FileMode.append);
    });
  }
}

class AppLogger {
  static Logger? _instance;
  static File? _logFile;
  static const int _maxLogBytes = 512 * 1024;
  static const int _retainTailBytes = 256 * 1024;

  static Future<void> init() async {
    final dir = await getApplicationDocumentsDirectory();
    _logFile = File(p.join(dir.path, 'pow_errors.log'));
    await _trimLogIfNeeded();
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

  static Future<void> _trimLogIfNeeded() async {
    if (_logFile == null || !_logFile!.existsSync()) return;
    final fileSize = await _logFile!.length();
    if (fileSize <= _maxLogBytes) return;

    final content = await _logFile!.readAsString();
    if (content.length <= _retainTailBytes) {
      return;
    }

    final trimmed = content.substring(content.length - _retainTailBytes);
    await _logFile!.writeAsString(trimmed);
  }
}
