import 'dart:io';
import 'package:path/path.dart' as p;
import 'package:flutter/foundation.dart';

class PhpExtension {
  final String name;
  bool isEnabled;

  PhpExtension({required this.name, required this.isEnabled});
}

class PhpExtensionManager extends ChangeNotifier {
  final String phpPath;
  List<PhpExtension> extensions = [];
  bool isLoading = false;
  String? error;

  PhpExtensionManager(this.phpPath) {
    _loadExtensions();
  }

  File get _phpIniFile {
    if (Platform.isWindows) {
      return File(p.join(phpPath, 'php.ini'));
    }
    return File(p.join(phpPath, 'etc', 'php.ini')); // Fallback
  }

  Future<void> _loadExtensions() async {
    isLoading = true;
    error = null;
    notifyListeners();

    try {
      final file = _phpIniFile;
      if (!await file.exists()) {
        error = 'php.ini not found at ${file.path}';
        isLoading = false;
        notifyListeners();
        return;
      }

      final lines = await file.readAsLines();
      final extList = <PhpExtension>[];
      final known = <String, bool>{};
      String? extensionDir;

      for (var line in lines) {
        final trimmed = line.trim();
        if (trimmed.startsWith('extension_dir')) {
          final parts = trimmed.split('=');
          if (parts.length > 1) {
            var dir = parts[1].trim().replaceAll('"', '').replaceAll("'", "");
            if (dir.startsWith('./') || dir.startsWith('.\\')) {
              dir = p.normalize(p.join(phpPath, dir));
            }
            extensionDir = dir;
          }
          continue;
        }

        if (trimmed.startsWith('extension=') || trimmed.startsWith(';extension=')) {
          final enabled = trimmed.startsWith('extension=');
          String extName = trimmed.split('=')[1].trim();
          extName = extName.replaceAll('"', '').replaceAll("'", "");
          if (extName.isEmpty) continue;
          known[extName] = enabled;
          extList.add(PhpExtension(name: extName, isEnabled: enabled));
        }
      }

      // Merge from ext dir
      if (extensionDir != null) {
        final extDir = Directory(extensionDir);
        if (await extDir.exists()) {
          final files = await extDir.list().toList();
          for (final f in files) {
            if (f is File) {
              final name = p.basename(f.path);
              final lower = name.toLowerCase();
              if (!(lower.endsWith('.dll') || lower.endsWith('.so'))) continue;
              if (!known.containsKey(name)) {
                extList.add(PhpExtension(name: name, isEnabled: false));
              }
            }
          }
        }
      }

      // Sort alphabetically
      extList.sort((a, b) => a.name.compareTo(b.name));
      extensions = extList;
    } catch (e) {
      error = e.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> toggleExtension(String extName, bool enabled) async {
    try {
      final file = _phpIniFile;
      if (!await file.exists()) throw Exception('php.ini not found');

      final lines = await file.readAsLines();
      final newLines = <String>[];
      bool found = false;

      for (var line in lines) {
        final trimmed = line.trim();
        if (trimmed.startsWith('extension=') || trimmed.startsWith(';extension=')) {
          final currentName = trimmed.split('=')[1].trim().replaceAll('"', '').replaceAll("'", "");
          if (currentName == extName) {
            newLines.add(enabled ? 'extension=$extName' : ';extension=$extName');
            found = true;
            continue;
          }
        }
        newLines.add(line);
      }

      if (!found && enabled) {
        newLines.add('extension=$extName');
      }

      await file.writeAsString(newLines.join('\n'));
      
      // Update local state
      final ext = extensions.firstWhere((e) => e.name == extName);
      ext.isEnabled = enabled;
      notifyListeners();

    } catch (e) {
      error = e.toString();
      notifyListeners();
    }
  }
}
