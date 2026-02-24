import 'dart:io';
import 'package:flutter/foundation.dart';

class SystemService extends ChangeNotifier {
  bool _isAdmin = false;
  bool _isChecking = true;

  bool get isAdmin => _isAdmin;
  bool get isChecking => _isChecking;

  SystemService() {
    _checkAdmin();
  }

  Future<void> _checkAdmin() async {
    if (!Platform.isWindows) {
      _isAdmin = true;
      _isChecking = false;
      notifyListeners();
      return;
    }

    try {
      final result = await Process.run(
        'powershell',
        [
          '-NoProfile',
          '-Command',
          r'[Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()' 
          r' | ForEach-Object { $_.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator) }'
        ],
        runInShell: true,
      );
      _isAdmin = result.stdout.toString().trim().toLowerCase() == 'true';
    } catch (_) {
      _isAdmin = false;
    } finally {
      _isChecking = false;
      notifyListeners();
    }
  }
}
