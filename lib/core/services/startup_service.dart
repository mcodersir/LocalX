import 'dart:io';
import 'package:flutter/foundation.dart';
import 'log_service.dart';

class StartupService {
  static const _regPath = r'HKCU\Software\Microsoft\Windows\CurrentVersion\Run';
  static const _valueName = 'LocalX';

  static Future<void> setEnabled(bool enabled) async {
    if (!Platform.isWindows) return;
    try {
      if (enabled) {
        final exe = Platform.resolvedExecutable;
        final value = '"$exe"';
        await Process.run('reg', [
          'add',
          _regPath,
          '/v',
          _valueName,
          '/t',
          'REG_SZ',
          '/d',
          value,
          '/f',
        ], runInShell: true);
        LogService.instance.info('startup', 'startup entry enabled');
      } else {
        await Process.run('reg', [
          'delete',
          _regPath,
          '/v',
          _valueName,
          '/f',
        ], runInShell: true);
        LogService.instance.info('startup', 'startup entry disabled');
      }
    } catch (e) {
      debugPrint('[StartupService] Failed to update startup entry: $e');
      LogService.instance.error(
        'startup',
        'failed to update startup entry',
        error: e,
      );
    }
  }
}
