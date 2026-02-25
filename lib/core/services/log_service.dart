import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

enum LogLevel { debug, info, warning, error }

class LogService extends ChangeNotifier {
  static final LogService instance = LogService._internal();
  LogService._internal();

  static const int _maxBytes = 5 * 1024 * 1024; // 5MB
  static const int _maxRecent = 500;

  bool _initialized = false;
  String _logsDirectoryPath = '';
  String _activeLogFilePath = '';
  final List<String> _recent = [];

  String get logsDirectoryPath => _logsDirectoryPath;
  String get activeLogFilePath => _activeLogFilePath;
  List<String> get recent => List.unmodifiable(_recent);

  Future<void> initialize() async {
    if (_initialized) return;
    final appDir = await getApplicationSupportDirectory();
    final logsDir = Directory(p.join(appDir.path, 'LocalX', 'logs'));
    if (!await logsDir.exists()) {
      await logsDir.create(recursive: true);
    }
    _logsDirectoryPath = logsDir.path;
    _activeLogFilePath = p.join(_logsDirectoryPath, 'localx.log');
    _initialized = true;
    await _rotateIfNeeded();
    await info('system', 'Log system initialized at $_activeLogFilePath');
  }

  Future<void> debug(String category, String message) {
    return _write(LogLevel.debug, category, message);
  }

  Future<void> info(String category, String message) {
    return _write(LogLevel.info, category, message);
  }

  Future<void> warning(String category, String message) {
    return _write(LogLevel.warning, category, message);
  }

  Future<void> error(
    String category,
    String message, {
    Object? error,
    StackTrace? stackTrace,
  }) async {
    final suffix = [
      if (error != null) 'error=$error',
      if (stackTrace != null) 'stack=$stackTrace',
    ].join(' | ');
    final full = suffix.isEmpty ? message : '$message | $suffix';
    await _write(LogLevel.error, category, full);
  }

  Future<void> _write(LogLevel level, String category, String message) async {
    try {
      if (!_initialized) {
        await initialize();
      }
      await _rotateIfNeeded();

      final now = DateTime.now().toIso8601String();
      final line = '[$now] [${_levelName(level)}] [$category] $message';
      _recent.add(line);
      if (_recent.length > _maxRecent) {
        _recent.removeAt(0);
      }

      final file = File(_activeLogFilePath);
      await file.writeAsString('$line\n', mode: FileMode.append, flush: true);
      notifyListeners();
    } catch (_) {
      // Intentionally swallow logger exceptions to never block app flow.
    }
  }

  String _levelName(LogLevel level) {
    switch (level) {
      case LogLevel.debug:
        return 'DEBUG';
      case LogLevel.info:
        return 'INFO';
      case LogLevel.warning:
        return 'WARN';
      case LogLevel.error:
        return 'ERROR';
    }
  }

  Future<void> _rotateIfNeeded() async {
    if (_activeLogFilePath.isEmpty) return;
    final file = File(_activeLogFilePath);
    if (!await file.exists()) return;
    final stat = await file.stat();
    if (stat.size < _maxBytes) return;

    final ts = DateTime.now().toIso8601String().replaceAll(':', '-');
    final rotated = p.join(_logsDirectoryPath, 'localx-$ts.log');
    await file.rename(rotated);
  }

  Future<void> openLogsDirectory() async {
    if (!_initialized) {
      await initialize();
    }
    if (_logsDirectoryPath.isEmpty) return;
    if (Platform.isWindows) {
      await Process.run('explorer', [_logsDirectoryPath], runInShell: true);
      return;
    }
    if (Platform.isLinux) {
      await Process.run('xdg-open', [_logsDirectoryPath], runInShell: true);
      return;
    }
    if (Platform.isMacOS) {
      await Process.run('open', [_logsDirectoryPath], runInShell: true);
      return;
    }
  }
}
