import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:crypto/crypto.dart';
import 'package:path_provider/path_provider.dart';

class VersionInfo {
  final String software;
  final String version;
  final bool isInstalled;
  final String? path;

  VersionInfo({
    required this.software,
    required this.version,
    required this.isInstalled,
    this.path,
  });
}

class SoftwareVersions {
  static const Map<String, List<String>> availableVersions = {
    'PHP': ['8.5.1', '8.4.16', '8.3.29', '8.2.30', '8.1.34'],
    'Python': ['3.14.3', '3.13.12', '3.12.10', '3.11.14', '3.10.11'],
    'Node.js': ['25.x', '24.x', '22.x', '20.x', '18.x'],
    'MySQL': ['8.4.8', '8.4.7', '8.4.6', '8.4.5', '8.4.4'],
    'Apache': ['2.4.66', '2.4.65', '2.4.64', '2.4.63', '2.4.62'],
    'Redis': ['7.4.2', '7.2.7', '7.0.15', '6.2.16', '6.0.20'],
    'PostgreSQL': ['17.8', '16.12', '15.16', '14.21', '13.17'],
    'Memcached': ['1.6.39', '1.6.38', '1.6.37', '1.6.36', '1.6.35'],
    'Mailhog': ['1.0.1', '1.0.0', '0.2.1', '0.2.0', '0.1.9'],
    'SMTP': ['1.28.2', '1.28.1', '1.28.0', '1.27.1', '1.27.0'],
    'WebSocket': ['1.13.0', '1.12.0', '1.11.0', '1.10.0', '1.9.0'],
  };

  /// Get real download URLs for Windows
  static String getDownloadUrl(String software, String version) {
    switch (software) {
      case 'PHP':
        if (Platform.isWindows) {
          final vs = version.startsWith('8.4') || version.startsWith('8.5') ? 'vs17' : 'vs16';
          return 'https://windows.php.net/downloads/releases/php-$version-Win32-$vs-x64.zip';
        }
        return 'https://www.php.net/distributions/php-$version.tar.xz';
      case 'Python':
        if (Platform.isWindows) {
          return 'https://www.python.org/ftp/python/$version/python-$version-embed-amd64.zip';
        }
        return 'https://www.python.org/ftp/python/$version/Python-$version.tgz';
      case 'Node.js':
        if (Platform.isWindows) {
          return 'https://nodejs.org/dist/v$version/node-v$version-win-x64.zip';
        }
        return 'https://nodejs.org/dist/v$version/node-v$version-linux-x64.tar.xz';
      case 'MySQL':
        if (Platform.isWindows) {
          return 'https://cdn.mysql.com/Downloads/MySQL-${version.substring(0, 3)}/mysql-$version-winx64.zip';
        }
        return 'https://cdn.mysql.com/Downloads/MySQL-${version.substring(0, 3)}/mysql-$version-linux-glibc2.28-x86_64.tar.xz';
      case 'Redis':
        return 'https://github.com/redis/redis/archive/refs/tags/$version.zip';
      case 'Apache':
        if (Platform.isWindows) {
          if (version == '2.4.66') {
            return 'https://www.apachelounge.com/download/VS18/binaries/httpd-2.4.66-260223-Win64-VS18.zip';
          }
          return 'https://www.apachelounge.com/download/VS17/binaries/httpd-$version-win64-VS17.zip';
        }
        return 'https://downloads.apache.org/httpd/httpd-$version.tar.gz';
      case 'PostgreSQL':
        if (Platform.isWindows) {
          return 'https://get.enterprisedb.com/postgresql/postgresql-$version-1-windows-x64-binaries.zip';
        }
        return 'https://ftp.postgresql.org/pub/source/v$version/postgresql-$version.tar.gz';
      case 'Memcached':
        // Memcached isn't officially supported on Windows natively anymore, using a community build for illustration
        if (Platform.isWindows) {
          return 'https://github.com/nono303/memcached/releases/download/v$version/memcached-$version-win64.zip';
        }
        return 'https://memcached.org/files/memcached-$version.tar.gz';
      case 'Mailhog':
        if (Platform.isWindows) {
          return 'https://github.com/mailhog/MailHog/releases/download/v$version/MailHog_windows_amd64.exe';
        }
        return 'https://github.com/mailhog/MailHog/releases/download/v$version/MailHog_linux_amd64';
      case 'SMTP':
        if (Platform.isWindows) {
          return 'https://github.com/axllent/mailpit/releases/download/v$version/mailpit-windows-amd64.zip';
        }
        return 'https://github.com/axllent/mailpit/releases/download/v$version/mailpit-linux-amd64.tar.gz';
      case 'WebSocket':
        if (Platform.isWindows) {
          return 'https://github.com/vi/websocat/releases/download/v$version/websocat.x86_64-pc-windows-gnu.exe';
        }
        return 'https://github.com/vi/websocat/releases/download/v$version/websocat.x86_64-unknown-linux-musl';
      default:
        return '';
    }
  }

  static const Map<String, String> downloadPageUrls = {
    'PHP': 'https://windows.php.net/downloads/releases/',
    'Python': 'https://www.python.org/downloads/windows/',
    'Node.js': 'https://nodejs.org/en/download/',
    'MySQL': 'https://dev.mysql.com/downloads/mysql/',
    'Apache': 'https://httpd.apache.org/download.cgi',
    'Redis': 'https://github.com/redis/redis/releases/',
    'PostgreSQL': 'https://www.enterprisedb.com/download-postgresql-binaries',
    'Memcached': 'https://github.com/nono303/memcached/releases',
    'Mailhog': 'https://github.com/mailhog/MailHog/releases',
    'SMTP': 'https://github.com/axllent/mailpit/releases',
    'WebSocket': 'https://github.com/vi/websocat/releases',
  };
}

enum InstallStatus { idle, downloading, extracting, configuring, done, error }

class InstallProgress {
  final String software;
  final String version;
  InstallStatus status;
  double progress;
  String message;
  String error;
  int downloadedBytes;
  int totalBytes;

  InstallProgress({
    required this.software,
    required this.version,
    this.status = InstallStatus.idle,
    this.progress = 0,
    this.message = '',
    this.error = '',
    this.downloadedBytes = 0,
    this.totalBytes = 0,
  });
}

class BundleData {
  final String name;
  final List<int> bytes;
  final String? sha256;
  final String installMode;
  final String? sourceUrl;
  const BundleData(
    this.name,
    this.bytes, {
    this.sha256,
    this.installMode = 'archive',
    this.sourceUrl,
  });
}

class BundleManifestEntry {
  final String software;
  final String version;
  final String platform;
  final String archive;
  final String sha256;
  final String sourceUrl;
  final String installMode;

  const BundleManifestEntry({
    required this.software,
    required this.version,
    required this.platform,
    required this.archive,
    required this.sha256,
    required this.sourceUrl,
    required this.installMode,
  });

  factory BundleManifestEntry.fromJson(Map<String, dynamic> json) {
    return BundleManifestEntry(
      software: json['software'] as String? ?? '',
      version: json['version'] as String? ?? '',
      platform: json['platform'] as String? ?? '',
      archive: json['archive'] as String? ?? '',
      sha256: json['sha256'] as String? ?? '',
      sourceUrl: json['sourceUrl'] as String? ?? '',
      installMode: json['installMode'] as String? ?? 'archive',
    );
  }
}

class VersionManager extends ChangeNotifier {
  final Map<String, VersionInfo> _installed = {};
  String _selectedPhpVersion = '';
  String _selectedPythonVersion = '';
  String _selectedNodeVersion = '';
  bool _isScanning = false;
  String _localxHome = '';
  final Map<String, InstallProgress> _installProgress = {};
  List<BundleManifestEntry>? _bundleManifest;

  Map<String, VersionInfo> get installed => Map.unmodifiable(_installed);
  String get selectedPhpVersion => _selectedPhpVersion;
  String get selectedPythonVersion => _selectedPythonVersion;
  String get selectedNodeVersion => _selectedNodeVersion;
  bool get isScanning => _isScanning;
  String get localxHome => _localxHome;
  Map<String, InstallProgress> get installProgress => Map.unmodifiable(_installProgress);

  VersionManager() {
    _initHome();
    scanInstalled();
  }

  Future<void> _initHome() async {
    final appDir = await getApplicationSupportDirectory();
    _localxHome = '${appDir.path}${Platform.pathSeparator}LocalX';
    final dir = Directory(_localxHome);
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }
    // Create version subdirectories
    for (final sw in ['php', 'python', 'nodejs', 'mysql', 'redis', 'apache', 'postgres', 'memcached', 'mailhog', 'smtp', 'websocket']) {
      final swDir = Directory('$_localxHome${Platform.pathSeparator}$sw');
      if (!await swDir.exists()) {
        await swDir.create(recursive: true);
      }
    }
    final bundlesDir = Directory('$_localxHome${Platform.pathSeparator}bundles');
    if (!await bundlesDir.exists()) {
      await bundlesDir.create(recursive: true);
    }
  }

  /// Scan the system for installed software
  Future<void> scanInstalled() async {
    _isScanning = true;
    notifyListeners();

    // Detect PHP
    try {
      final phpResult = await Process.run('php', ['-v']);
      if (phpResult.exitCode == 0) {
        final match = RegExp(r'PHP (\d+\.\d+\.\d+)').firstMatch(phpResult.stdout.toString());
        if (match != null) {
          _selectedPhpVersion = match.group(1)!;
          // Get path
          final which = await Process.run(Platform.isWindows ? 'where' : 'which', ['php']);
          _installed['PHP'] = VersionInfo(
            software: 'PHP',
            version: match.group(1)!,
            isInstalled: true,
            path: which.stdout.toString().trim().split('\n').first,
          );
        }
      }
    } catch (_) {
      _installed['PHP'] = VersionInfo(software: 'PHP', version: 'Not found', isInstalled: false);
    }

    // Detect Python
    try {
      final pyResult = await Process.run('python', ['--version']);
      final out = pyResult.stdout.toString().trim();
      final err = pyResult.stderr.toString().trim();
      final output = out.isNotEmpty ? out : err;
      if (pyResult.exitCode == 0 || output.contains('Python')) {
        final match = RegExp(r'Python (\d+\.\d+\.\d+)').firstMatch(output);
        if (match != null) {
          _selectedPythonVersion = match.group(1)!;
          final which = await Process.run(Platform.isWindows ? 'where' : 'which', ['python']);
          _installed['Python'] = VersionInfo(
            software: 'Python',
            version: _selectedPythonVersion,
            isInstalled: true,
            path: which.stdout.toString().trim().split('\n').first,
          );
        }
      }
    } catch (_) {
      _installed['Python'] = VersionInfo(software: 'Python', version: 'Not found', isInstalled: false);
    }

    // Detect Node.js
    try {
      final nodeResult = await Process.run('node', ['-v']);
      if (nodeResult.exitCode == 0) {
        _selectedNodeVersion = nodeResult.stdout.toString().trim().replaceFirst('v', '');
        final which = await Process.run(Platform.isWindows ? 'where' : 'which', ['node']);
        _installed['Node.js'] = VersionInfo(
          software: 'Node.js',
          version: _selectedNodeVersion,
          isInstalled: true,
          path: which.stdout.toString().trim().split('\n').first,
        );
      }
    } catch (_) {
      _installed['Node.js'] = VersionInfo(software: 'Node.js', version: 'Not found', isInstalled: false);
    }

    // Detect MySQL
    try {
      final mysqlResult = await Process.run('mysql', ['--version']);
      if (mysqlResult.exitCode == 0) {
        final match = RegExp(r'(\d+\.\d+\.\d+)').firstMatch(mysqlResult.stdout.toString());
        final which = await Process.run(Platform.isWindows ? 'where' : 'which', ['mysql']);
        _installed['MySQL'] = VersionInfo(
          software: 'MySQL',
          version: match?.group(1) ?? 'Unknown',
          isInstalled: true,
          path: which.stdout.toString().trim().split('\n').first,
        );
      }
    } catch (_) {
      _installed['MySQL'] = VersionInfo(software: 'MySQL', version: 'Not found', isInstalled: false);
    }

    // Detect Redis
    try {
      final redisResult = await Process.run('redis-server', ['--version']);
      if (redisResult.exitCode == 0) {
        final match = RegExp(r'v=(\d+\.\d+\.\d+)').firstMatch(redisResult.stdout.toString());
        _installed['Redis'] = VersionInfo(
          software: 'Redis',
          version: match?.group(1) ?? 'Unknown',
          isInstalled: true,
        );
      }
    } catch (_) {
      _installed['Redis'] = VersionInfo(software: 'Redis', version: 'Not found', isInstalled: false);
    }

    // Detect Apache
    try {
      final apacheResult = await Process.run(
        Platform.isWindows ? 'httpd' : 'apachectl', ['-v'],
      );
      if (apacheResult.exitCode == 0) {
        final match = RegExp(r'(\d+\.\d+\.\d+)').firstMatch(apacheResult.stdout.toString());
        _installed['Apache'] = VersionInfo(
          software: 'Apache',
          version: match?.group(1) ?? 'Unknown',
          isInstalled: true,
        );
      }
    } catch (_) {
      _installed['Apache'] = VersionInfo(software: 'Apache', version: 'Not found', isInstalled: false);
    }

    // Detect PostgreSQL
    try {
      final psqlResult = await Process.run('psql', ['-V']);
      if (psqlResult.exitCode == 0) {
        final match = RegExp(r'(\d+\.\d+(\.\d+)?)').firstMatch(psqlResult.stdout.toString());
        final which = await Process.run(Platform.isWindows ? 'where' : 'which', ['psql']);
        _installed['PostgreSQL'] = VersionInfo(
          software: 'PostgreSQL',
          version: match?.group(1) ?? 'Unknown',
          isInstalled: true,
          path: which.stdout.toString().trim().split('\n').first,
        );
      }
    } catch (_) {
      _installed['PostgreSQL'] = VersionInfo(software: 'PostgreSQL', version: 'Not found', isInstalled: false);
    }

    // Detect Memcached
    try {
      final memResult = await Process.run('memcached', ['-h']);
      if (memResult.exitCode == 0) {
        final match = RegExp(r'(\d+\.\d+\.\d+)').firstMatch(memResult.stdout.toString());
        final which = await Process.run(Platform.isWindows ? 'where' : 'which', ['memcached']);
        _installed['Memcached'] = VersionInfo(
          software: 'Memcached',
          version: match?.group(1) ?? 'Unknown',
          isInstalled: true,
          path: which.stdout.toString().trim().split('\n').first,
        );
      }
    } catch (_) {
      _installed['Memcached'] = VersionInfo(software: 'Memcached', version: 'Not found', isInstalled: false);
    }

    // Detect Mailhog
    try {
      final mailResult = await Process.run('MailHog', ['-version']);
      if (mailResult.exitCode == 0) {
        final match = RegExp(r'(\d+\.\d+\.\d+)').firstMatch(mailResult.stdout.toString());
        final which = await Process.run(Platform.isWindows ? 'where' : 'which', ['MailHog']);
        _installed['Mailhog'] = VersionInfo(
          software: 'Mailhog',
          version: match?.group(1) ?? 'Unknown',
          isInstalled: true,
          path: which.stdout.toString().trim().split('\n').first,
        );
      }
    } catch (_) {
      _installed['Mailhog'] = VersionInfo(software: 'Mailhog', version: 'Not found', isInstalled: false);
    }

    // Detect SMTP (Mailpit)
    try {
      final smtpResult = await Process.run('mailpit', ['--version']);
      if (smtpResult.exitCode == 0) {
        final match = RegExp(r'(\d+\.\d+\.\d+)').firstMatch(smtpResult.stdout.toString());
        final which = await Process.run(Platform.isWindows ? 'where' : 'which', ['mailpit']);
        _installed['SMTP'] = VersionInfo(
          software: 'SMTP',
          version: match?.group(1) ?? 'Unknown',
          isInstalled: true,
          path: which.stdout.toString().trim().split('\n').first,
        );
      }
    } catch (_) {
      _installed['SMTP'] = VersionInfo(software: 'SMTP', version: 'Not found', isInstalled: false);
    }

    // Detect WebSocket (websocat)
    try {
      final wsResult = await Process.run('websocat', ['--version']);
      if (wsResult.exitCode == 0) {
        final match = RegExp(r'(\d+\.\d+\.\d+)').firstMatch(wsResult.stdout.toString());
        final which = await Process.run(Platform.isWindows ? 'where' : 'which', ['websocat']);
        _installed['WebSocket'] = VersionInfo(
          software: 'WebSocket',
          version: match?.group(1) ?? 'Unknown',
          isInstalled: true,
          path: which.stdout.toString().trim().split('\n').first,
        );
      }
    } catch (_) {
      _installed['WebSocket'] = VersionInfo(software: 'WebSocket', version: 'Not found', isInstalled: false);
    }

    // Also scan LocalX-managed versions
    await _scanLocalVersions();

    _isScanning = false;
    notifyListeners();
  }

  /// Scan versions installed by LocalX in its home directory
  Future<void> _scanLocalVersions() async {
    if (_localxHome.isEmpty) return;

    for (final sw in ['php', 'python', 'nodejs']) {
      final swDir = Directory('$_localxHome${Platform.pathSeparator}$sw');
      if (await swDir.exists()) {
        final subdirs = await swDir.list().where((e) => e is Directory).toList();
        for (final dir in subdirs) {
          final versionDir = dir.path.split(Platform.pathSeparator).last;
          debugPrint('[VersionManager] Found local $sw version: $versionDir');
        }
      }
    }
  }

  String _platformSuffix() {
    if (Platform.isWindows) return '-windows';
    if (Platform.isLinux) return '-linux';
    return '';
  }

  List<String> _bundleCandidates(String version, String effectiveVersion) {
    final suffix = _platformSuffix();
    final versions = <String>{version, effectiveVersion}.where((v) => v.isNotEmpty);
    const exts = ['.zip', '.tar.gz', '.tgz', '.tar.xz', '.tar', '.exe', '.bin'];
    final out = <String>[];
    for (final v in versions) {
      for (final ext in exts) {
        out.add('$v$suffix$ext');
        out.add('$v$ext');
      }
    }
    return out;
  }

  Future<void> _ensureBundleManifestLoaded() async {
    if (_bundleManifest != null) return;
    try {
      final raw = await rootBundle.loadString('assets/bundles/manifest.json');
      final json = jsonDecode(raw) as Map<String, dynamic>;
      final entries = (json['entries'] as List<dynamic>? ?? const [])
          .whereType<Map<String, dynamic>>()
          .map(BundleManifestEntry.fromJson)
          .toList();
      _bundleManifest = entries;
    } catch (_) {
      _bundleManifest = const [];
    }
  }

  String _platformName() => Platform.isWindows ? 'windows' : (Platform.isLinux ? 'linux' : '');

  Future<BundleManifestEntry?> _findManifestEntry(
    String software,
    String version,
    String effectiveVersion,
  ) async {
    await _ensureBundleManifestLoaded();
    final swKey = software.toLowerCase().replaceAll('.', '').replaceAll(' ', '');
    final platform = _platformName();
    final versions = <String>{version, effectiveVersion};
    for (final entry in _bundleManifest ?? const <BundleManifestEntry>[]) {
      if (entry.software != swKey || entry.platform != platform) continue;
      if (versions.contains(entry.version)) return entry;
    }
    return null;
  }

  String _sha256Bytes(List<int> bytes) {
    return sha256.convert(bytes).toString();
  }

  Future<String> _sha256File(String path) async {
    final file = File(path);
    final bytes = await file.readAsBytes();
    return _sha256Bytes(bytes);
  }

  Future<String?> _findLocalBundle(String software, String version, String effectiveVersion) async {
    if (_localxHome.isEmpty) return null;
    final swKey = software.toLowerCase().replaceAll('.', '').replaceAll(' ', '');
    final bundlesDir = Directory('$_localxHome${Platform.pathSeparator}bundles${Platform.pathSeparator}$swKey');
    if (!await bundlesDir.exists()) return null;

    for (final candidate in _bundleCandidates(version, effectiveVersion)) {
      final path = '${bundlesDir.path}${Platform.pathSeparator}$candidate';
      if (await File(path).exists()) return path;
    }
    return null;
  }

  Future<BundleData?> _findEmbeddedBundle(String software, String version, String effectiveVersion) async {
    final manifestEntry = await _findManifestEntry(software, version, effectiveVersion);
    if (manifestEntry != null) {
      final assetPath = 'assets/bundles/${manifestEntry.archive}';
      try {
        final data = await rootBundle.load(assetPath);
        return BundleData(
          _baseName(manifestEntry.archive),
          data.buffer.asUint8List(),
          sha256: manifestEntry.sha256,
          installMode: manifestEntry.installMode,
          sourceUrl: manifestEntry.sourceUrl,
        );
      } catch (_) {}
    }

    final swKey = software.toLowerCase().replaceAll('.', '').replaceAll(' ', '');
    for (final candidate in _bundleCandidates(version, effectiveVersion)) {
      final assetPath = 'assets/bundles/$swKey/$candidate';
      try {
        final data = await rootBundle.load(assetPath);
        return BundleData(candidate, data.buffer.asUint8List());
      } catch (_) {}
    }
    return null;
  }

  Future<void> _downloadFile(String url, String destPath, InstallProgress progress) async {
    final client = HttpClient();
    final request = await client.getUrl(Uri.parse(url));
    request.followRedirects = true;
    request.maxRedirects = 5;
    request.headers.set('User-Agent', 'LocalX');
    final response = await request.close();
    if (response.statusCode != 200) {
      throw Exception('Download failed with status ${response.statusCode}');
    }

    final total = response.contentLength;
    progress.totalBytes = total > 0 ? total : 0;
    progress.downloadedBytes = 0;
    progress.status = InstallStatus.downloading;
    progress.message = 'Downloading...';
    progress.progress = 0.05;
    notifyListeners();

    final file = File(destPath);
    final sink = file.openWrite();
    int received = 0;
    await for (final chunk in response) {
      received += chunk.length;
      sink.add(chunk);
      progress.downloadedBytes = received;
      if (total > 0) {
        final pct = received / total;
        progress.progress = (pct * 0.6).clamp(0.05, 0.6);
        progress.message = 'Downloading ${_formatBytes(received)} / ${_formatBytes(total)} (${(pct * 100).toStringAsFixed(0)}%)';
      } else {
        progress.progress = 0.2;
        progress.message = 'Downloading ${_formatBytes(received)}';
      }
      notifyListeners();
    }
    await sink.flush();
    await sink.close();
    client.close();
  }

  String _baseName(String path) {
    return path.split(RegExp(r'[\\/]')).last;
  }

  bool _isArchiveFile(String path) {
    final lower = path.toLowerCase();
    return lower.endsWith('.zip') ||
        lower.endsWith('.tar.gz') ||
        lower.endsWith('.tgz') ||
        lower.endsWith('.tar.xz') ||
        lower.endsWith('.tar');
  }

  Future<void> _extractArchive(String archivePath, String installDir) async {
    final lower = archivePath.toLowerCase();
    if (lower.endsWith('.zip')) {
      if (Platform.isWindows) {
        final extractResult = await Process.run(
          'powershell',
          ['-Command', 'Expand-Archive', '-Path', archivePath, '-DestinationPath', installDir, '-Force'],
          runInShell: true,
        );
        if (extractResult.exitCode == 0) return;
        final fallback = await Process.run('tar', ['-xf', archivePath, '-C', installDir]);
        if (fallback.exitCode != 0) {
          throw Exception('Extraction failed: ${extractResult.stderr}\n${fallback.stderr}');
        }
        return;
      }
      final extractResult = await Process.run('unzip', ['-o', archivePath, '-d', installDir]);
      if (extractResult.exitCode != 0) {
        throw Exception('Extraction failed: ${extractResult.stderr}');
      }
      return;
    }

    if (lower.endsWith('.tar.gz') || lower.endsWith('.tgz')) {
      final extractResult = await Process.run('tar', ['-xzf', archivePath, '-C', installDir]);
      if (extractResult.exitCode != 0) {
        throw Exception('Extraction failed: ${extractResult.stderr}');
      }
      return;
    }

    if (lower.endsWith('.tar.xz')) {
      final extractResult = await Process.run('tar', ['-xJf', archivePath, '-C', installDir]);
      if (extractResult.exitCode != 0) {
        throw Exception('Extraction failed: ${extractResult.stderr}');
      }
      return;
    }

    if (lower.endsWith('.tar')) {
      final extractResult = await Process.run('tar', ['-xf', archivePath, '-C', installDir]);
      if (extractResult.exitCode != 0) {
        throw Exception('Extraction failed: ${extractResult.stderr}');
      }
      return;
    }

    throw Exception('Unsupported archive format: $archivePath');
  }

  /// Download and install a specific version
  Future<bool> installVersion(String software, String version) async {
    final key = '$software-$version';
    _installProgress[key] = InstallProgress(
      software: software,
      version: version,
      status: InstallStatus.downloading,
      message: 'Downloading $software $version...',
    );
    notifyListeners();

    try {
      final swKey = software.toLowerCase().replaceAll('.', '').replaceAll(' ', '');
      var effectiveVersion = version;
      if (_localxHome.isEmpty) {
        await _initHome();
      }

      BundleData? embeddedBundle;
      String? localBundle;
      BundleManifestEntry? manifestEntry;

      localBundle = await _findLocalBundle(software, version, version);
      embeddedBundle = await _findEmbeddedBundle(software, version, version);
      manifestEntry = await _findManifestEntry(software, version, version);

      if (software == 'Node.js' && version.endsWith('.x') && localBundle == null && embeddedBundle == null) {
        effectiveVersion = await _resolveNodeVersion(version);
        localBundle = await _findLocalBundle(software, version, effectiveVersion);
        embeddedBundle = await _findEmbeddedBundle(software, version, effectiveVersion);
        manifestEntry = await _findManifestEntry(software, version, effectiveVersion);
      }
      final installDir = '$_localxHome${Platform.pathSeparator}$swKey${Platform.pathSeparator}$version';

      await Directory(installDir).create(recursive: true);

      String fileName;
      if (localBundle != null) {
        fileName = _baseName(localBundle);
      } else if (embeddedBundle != null) {
        fileName = embeddedBundle.name;
      } else {
        final url = SoftwareVersions.getDownloadUrl(software, effectiveVersion);
        if (url.isEmpty) {
          throw Exception('No download URL available for $software $version');
        }
        fileName = Uri.parse(url).pathSegments.isNotEmpty
            ? Uri.parse(url).pathSegments.last
            : 'download.bin';
      }

      final downloadPath = '$installDir${Platform.pathSeparator}$fileName';
      var installMode = manifestEntry?.installMode ?? embeddedBundle?.installMode ?? 'archive';

      if (localBundle != null) {
        _installProgress[key]!.status = InstallStatus.downloading;
        _installProgress[key]!.message = 'Using bundled $software $effectiveVersion...';
        _installProgress[key]!.progress = 0.2;
        notifyListeners();
        await File(localBundle).copy(downloadPath);
      } else if (embeddedBundle != null) {
        _installProgress[key]!.status = InstallStatus.downloading;
        _installProgress[key]!.message = 'Using embedded $software $effectiveVersion...';
        _installProgress[key]!.progress = 0.2;
        notifyListeners();
        await File(downloadPath).writeAsBytes(embeddedBundle.bytes, flush: true);
      } else {
        final url = SoftwareVersions.getDownloadUrl(software, effectiveVersion);
        await _downloadFile(url, downloadPath, _installProgress[key]!);
      }

      if (manifestEntry != null) {
        final digest = await _sha256File(downloadPath);
        if (digest != manifestEntry.sha256) {
          throw Exception('Bundle checksum mismatch for ${manifestEntry.archive}');
        }
      } else if (embeddedBundle?.sha256 != null) {
        final digest = await _sha256File(downloadPath);
        if (digest != embeddedBundle!.sha256) {
          throw Exception('Embedded bundle checksum mismatch for ${embeddedBundle.name}');
        }
      }

      final shouldExtract = installMode == 'archive' && _isArchiveFile(downloadPath);
      if (!shouldExtract) {
        _installProgress[key]!.status = InstallStatus.configuring;
        _installProgress[key]!.message = 'Configuring $software $effectiveVersion...';
        _installProgress[key]!.progress = 0.9;
        notifyListeners();

        _installed[software] = VersionInfo(
          software: software,
          version: effectiveVersion,
          isInstalled: true,
          path: downloadPath,
        );

        _installProgress[key]!.status = InstallStatus.done;
        _installProgress[key]!.message = '$software $effectiveVersion installed successfully!';
        _installProgress[key]!.progress = 1.0;
        notifyListeners();
        return true;
      }

      _installProgress[key]!.status = InstallStatus.extracting;
      _installProgress[key]!.message = 'Extracting $software $effectiveVersion...';
      _installProgress[key]!.progress = 0.7;
      notifyListeners();

      await _extractArchive(downloadPath, installDir);

      try {
        await File(downloadPath).delete();
      } catch (_) {}

      _installProgress[key]!.status = InstallStatus.configuring;
      _installProgress[key]!.message = 'Configuring $software $effectiveVersion...';
      _installProgress[key]!.progress = 0.9;
      notifyListeners();

      var resolvedVersion = effectiveVersion;
      if (software == 'Node.js' && version.endsWith('.x')) {
        try {
          final subdirs = await Directory(installDir).list().where((e) => e is Directory).toList();
          for (final entry in subdirs) {
            if (entry is Directory && entry.path.contains('node')) {
              final match = RegExp(r'node-v(\d+\.\d+\.\d+)').firstMatch(entry.path);
              if (match != null) {
                resolvedVersion = match.group(1)!;
                break;
              }
            }
          }
        } catch (_) {}
      }

      _installed[software] = VersionInfo(
        software: software,
        version: resolvedVersion,
        isInstalled: true,
        path: installDir,
      );

      _installProgress[key]!.status = InstallStatus.done;
      _installProgress[key]!.message = '$software $effectiveVersion installed successfully!';
      _installProgress[key]!.progress = 1.0;
      notifyListeners();

      return true;
    } catch (e) {
      _installProgress[key]!.status = InstallStatus.error;
      _installProgress[key]!.error = e.toString();
      _installProgress[key]!.message = 'Failed to install $software $version';
      notifyListeners();
      return false;
    }
  }

  String _formatBytes(int bytes) {
    if (bytes <= 0) return '0 B';
    const units = ['B', 'KB', 'MB', 'GB'];
    double size = bytes.toDouble();
    int idx = 0;
    while (size >= 1024 && idx < units.length - 1) {
      size /= 1024;
      idx++;
    }
    return '${size.toStringAsFixed(idx == 0 ? 0 : 1)} ${units[idx]}';
  }

  /// Switch active version of a software (updates PATH)
  Future<bool> switchVersion(String software, String version) async {
    final swKey = software.toLowerCase().replaceAll('.', '').replaceAll(' ', '');
    final versionDir = '$_localxHome${Platform.pathSeparator}$swKey${Platform.pathSeparator}$version';

    if (!await Directory(versionDir).exists()) {
      debugPrint('[VersionManager] Version directory not found: $versionDir');
      return false;
    }

    // Find the binary path inside the extracted directory
    String binPath = versionDir;
    String? resolvedVersion;
    if (software == 'PHP') {
      // PHP extracts to a subdirectory typically
      final subdirs = await Directory(versionDir).list().toList();
      for (final entry in subdirs) {
        if (entry is Directory && entry.path.contains('php')) {
          binPath = entry.path;
          break;
        }
      }
    } else if (software == 'Node.js') {
      final subdirs = await Directory(versionDir).list().toList();
      for (final entry in subdirs) {
        if (entry is Directory && entry.path.contains('node')) {
          binPath = entry.path;
          final match = RegExp(r'node-v(\d+\.\d+\.\d+)').firstMatch(entry.path);
          if (match != null) {
            resolvedVersion = match.group(1);
          }
          break;
        }
      }
    } else if (software == 'Python') {
      binPath = versionDir;
    }

    // Update PATH for current session (Windows)
    if (Platform.isWindows) {
      try {
        await Process.run(
          'setx',
          ['LOCALX_${software.toUpperCase().replaceAll('.', '_')}', binPath],
          runInShell: true,
        );
        debugPrint('[VersionManager] Set LOCALX path env var for $software to $binPath');
      } catch (e) {
        debugPrint('[VersionManager] Failed to set env var: $e');
      }
    }

    // Update selected version
    if (software == 'PHP') {
      _selectedPhpVersion = version;
    } else if (software == 'Python') {
      _selectedPythonVersion = version;
    } else if (software == 'Node.js') {
      _selectedNodeVersion = resolvedVersion ?? version;
    }

    _installed[software] = VersionInfo(
      software: software,
      version: resolvedVersion ?? version,
      isInstalled: true,
      path: binPath,
    );

    notifyListeners();
    return true;
  }

  /// Get list of locally installed versions for a software
  Future<List<String>> getLocalVersions(String software) async {
    final swKey = software.toLowerCase().replaceAll('.', '').replaceAll(' ', '');
    final swDir = Directory('$_localxHome${Platform.pathSeparator}$swKey');

    if (!await swDir.exists()) return [];

    final versions = <String>[];
    await for (final entry in swDir.list()) {
      if (entry is Directory) {
        versions.add(entry.path.split(Platform.pathSeparator).last);
      }
    }
    return versions;
  }

  Future<String> _resolveNodeVersion(String version) async {
    final major = version.split('.').first;
    final url = Uri.parse('https://nodejs.org/dist/latest-v$major.x/SHASUMS256.txt');
    try {
      final client = HttpClient();
      final request = await client.getUrl(url);
      final response = await request.close();
      final body = await response.transform(SystemEncoding().decoder).join();
      client.close();
      final pattern = Platform.isWindows
          ? r'node-v(\d+\.\d+\.\d+)-win-x64.zip'
          : r'node-v(\d+\.\d+\.\d+)-linux-x64.tar.xz';
      final match = RegExp(pattern).firstMatch(body);
      if (match != null) {
        return match.group(1)!;
      }
    } catch (e) {
      debugPrint('[VersionManager] Failed to resolve Node.js version for $version: $e');
    }
    return version.replaceAll('.x', '.0');
  }

  Future<bool> hasLocalBundle(String software, String version) async {
    if (_localxHome.isEmpty) {
      await _initHome();
    }
    final swKey = software.toLowerCase().replaceAll('.', '').replaceAll(' ', '');
    final bundlesDir = Directory('$_localxHome${Platform.pathSeparator}bundles${Platform.pathSeparator}$swKey');
    if (await bundlesDir.exists()) {
      for (final candidate in _bundleCandidates(version, version)) {
        final path = '${bundlesDir.path}${Platform.pathSeparator}$candidate';
        if (await File(path).exists()) return true;
      }
    }

    final embedded = await _findEmbeddedBundle(software, version, version);
    return embedded != null;
  }

  /// Clear install progress
  void clearProgress(String software, String version) {
    _installProgress.remove('$software-$version');
    notifyListeners();
  }
}
