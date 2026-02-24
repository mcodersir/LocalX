import 'dart:io';
import 'package:path/path.dart' as p;
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:url_launcher/url_launcher.dart';

class AdminerService extends ChangeNotifier {
  static const int adminerPort = 8081;
  bool isDownloading = false;
  bool isServerRunning = false;
  Process? _serverProcess;

  Future<String> _getAdminerDir() async {
    final appDir = await getApplicationSupportDirectory();
    final dir = Directory(p.join(appDir.path, 'LocalX', 'tools', 'adminer'));
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }
    return dir.path;
  }

  Future<void> ensureAdminerDownloaded() async {
    try {
      final dir = await _getAdminerDir();
      final file = File(p.join(dir, 'index.php'));

      if (!await file.exists()) {
        isDownloading = true;
        notifyListeners();

        final client = HttpClient();
        final request = await client.getUrl(Uri.parse('https://github.com/vrana/adminer/releases/download/v4.8.1/adminer-4.8.1.php'));
        final response = await request.close();
        await response.pipe(file.openWrite());
        client.close();
      }
    } catch (e) {
      if (kDebugMode) print('Failed to download Adminer: \$e');
    } finally {
      isDownloading = false;
      notifyListeners();
    }
  }

  Future<void> startAdminerAndOpen(String phpPath) async {
    await ensureAdminerDownloaded();
    final dir = await _getAdminerDir();

    if (!isServerRunning) {
      final phpExe = Platform.isWindows ? 'php.exe' : 'php';
      final php = p.join(phpPath, phpExe);
      
      try {
        _serverProcess = await Process.start(php, ['-S', '127.0.0.1:$adminerPort'], workingDirectory: dir);
        isServerRunning = true;
        notifyListeners();
      } catch (e) {
        if (kDebugMode) print('Failed to start Adminer PHP Server: \$e');
      }
    }

    // Open in browser
    final url = Uri.parse('http://127.0.0.1:$adminerPort');
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    }
  }

  void stopAdminer() {
    _serverProcess?.kill();
    _serverProcess = null;
    isServerRunning = false;
    notifyListeners();
  }
}
