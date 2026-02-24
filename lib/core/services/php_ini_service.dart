import 'dart:io';
import 'package:path/path.dart' as p;

class PhpIniSettings {
  String memoryLimit;
  String uploadMaxFilesize;
  String postMaxSize;
  String maxExecutionTime;
  String maxInputVars;

  PhpIniSettings({
    this.memoryLimit = '256M',
    this.uploadMaxFilesize = '64M',
    this.postMaxSize = '64M',
    this.maxExecutionTime = '120',
    this.maxInputVars = '1000',
  });
}

class PhpIniService {
  static File _phpIniFile(String phpPath) {
    if (Platform.isWindows) {
      return File(p.join(phpPath, 'php.ini'));
    }
    return File(p.join(phpPath, 'etc', 'php.ini'));
  }

  static Future<PhpIniSettings?> load(String phpPath) async {
    final file = _phpIniFile(phpPath);
    if (!await file.exists()) return null;
    final lines = await file.readAsLines();
    String? getValue(String key) {
      for (final line in lines) {
        final trimmed = line.trim();
        if (trimmed.startsWith(';')) continue;
        if (trimmed.startsWith('$key=')) {
          return trimmed.split('=').skip(1).join('=').trim();
        }
      }
      return null;
    }

    return PhpIniSettings(
      memoryLimit: getValue('memory_limit') ?? '256M',
      uploadMaxFilesize: getValue('upload_max_filesize') ?? '64M',
      postMaxSize: getValue('post_max_size') ?? '64M',
      maxExecutionTime: getValue('max_execution_time') ?? '120',
      maxInputVars: getValue('max_input_vars') ?? '1000',
    );
  }

  static Future<bool> save(String phpPath, PhpIniSettings settings) async {
    final file = _phpIniFile(phpPath);
    if (!await file.exists()) return false;
    final lines = await file.readAsLines();
    final updated = <String>[];

    bool setOrAdd(String key, String value, bool found) {
      if (!found) {
        updated.add('$key=$value');
        return true;
      }
      return false;
    }

    final keys = <String, String>{
      'memory_limit': settings.memoryLimit,
      'upload_max_filesize': settings.uploadMaxFilesize,
      'post_max_size': settings.postMaxSize,
      'max_execution_time': settings.maxExecutionTime,
      'max_input_vars': settings.maxInputVars,
    };

    final found = <String, bool>{};
    for (final k in keys.keys) {
      found[k] = false;
    }

    for (final line in lines) {
      var replaced = false;
      final trimmed = line.trim();
      for (final entry in keys.entries) {
        final key = entry.key;
        if (trimmed.startsWith('$key=') || trimmed.startsWith(';$key=')) {
          updated.add('$key=${entry.value}');
          found[key] = true;
          replaced = true;
          break;
        }
      }
      if (!replaced) updated.add(line);
    }

    for (final entry in keys.entries) {
      if (found[entry.key] != true) {
        setOrAdd(entry.key, entry.value, false);
      }
    }

    await file.writeAsString(updated.join('\n'));
    return true;
  }
}
