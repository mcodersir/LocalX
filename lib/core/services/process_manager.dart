import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'service_runtime.dart';
import 'port_probe.dart';
import 'log_service.dart';

enum ServiceStatus { stopped, starting, running, stopping, error }

class ServiceInfo {
  final String name;
  final String icon;
  final int defaultPort;
  int port;
  ServiceStatus status;
  Process? process;
  int? pid;
  String? version;
  String errorMessage;
  final List<String> logs;

  RuntimeMode? runtimeMode;
  String? binaryPath;
  String? containerName;
  Uri? healthUrl;
  int? lastExitCode;
  bool isDockerFallback;

  ServiceInfo({
    required this.name,
    required this.icon,
    required this.defaultPort,
    int? port,
    this.status = ServiceStatus.stopped,
    this.process,
    this.pid,
    this.version,
    this.errorMessage = '',
    List<String>? logs,
    this.runtimeMode,
    this.binaryPath,
    this.containerName,
    this.healthUrl,
    this.lastExitCode,
    this.isDockerFallback = false,
  }) : port = port ?? defaultPort,
       logs = logs ?? [];
}

class ProcessManager extends ChangeNotifier {
  final Map<String, ServiceInfo> _services = {};
  Timer? _statusTimer;
  static const _prefsRunningKey = 'localxRunningServices';
  bool _restored = false;
  bool _autoStartEnabled = false;

  ProcessManager() {
    _initServices();
    _startStatusMonitor();
  }

  void _initServices() {
    _services['apache'] = ServiceInfo(
      name: 'Apache',
      icon: 'http',
      defaultPort: 80,
    );
    _services['mysql'] = ServiceInfo(
      name: 'MySQL',
      icon: 'storage',
      defaultPort: 3306,
    );
    _services['php'] = ServiceInfo(
      name: 'PHP',
      icon: 'code',
      defaultPort: 9000,
    );
    _services['redis'] = ServiceInfo(
      name: 'Redis',
      icon: 'memory',
      defaultPort: 6379,
    );
    _services['nodejs'] = ServiceInfo(
      name: 'Node.js',
      icon: 'javascript',
      defaultPort: 3000,
    );
    _services['postgres'] = ServiceInfo(
      name: 'PostgreSQL',
      icon: 'dns',
      defaultPort: 5432,
    );
    _services['memcached'] = ServiceInfo(
      name: 'Memcached',
      icon: 'sd_storage',
      defaultPort: 11211,
    );
    _services['mailhog'] = ServiceInfo(
      name: 'Mailhog',
      icon: 'mail',
      defaultPort: 8025,
    );
    _services['smtp'] = ServiceInfo(
      name: 'SMTP',
      icon: 'mail',
      defaultPort: 1026,
    );
    _services['websocket'] = ServiceInfo(
      name: 'WebSocket',
      icon: 'cable',
      defaultPort: 6001,
    );
    _services['python'] = ServiceInfo(
      name: 'Python',
      icon: 'code',
      defaultPort: 8000,
    );

    _detectVersions();
  }

  Map<String, ServiceInfo> get services => Map.unmodifiable(_services);

  ServiceInfo? getService(String key) => _services[key];

  bool get allRunning =>
      _services.values.every((s) => s.status == ServiceStatus.running);
  bool get anyRunning =>
      _services.values.any((s) => s.status == ServiceStatus.running);
  int get runningCount =>
      _services.values.where((s) => s.status == ServiceStatus.running).length;

  Future<void> startService(String key) async {
    final service = _services[key];
    if (service == null ||
        service.status == ServiceStatus.running ||
        service.status == ServiceStatus.starting) {
      return;
    }

    final requestedPort = service.port;
    final resolvedPort = await _resolveServicePort(key, requestedPort, service);
    service.port = resolvedPort;
    service.status = ServiceStatus.starting;
    service.errorMessage = '';
    if (requestedPort != resolvedPort) {
      service.logs.add(
        '[${DateTime.now()}] Port $requestedPort was unavailable. '
        'Switched ${service.name} to port $resolvedPort to avoid conflicts (XAMPP/WAMP/IIS).',
      );
      LogService.instance.warning(
        'service',
        'port conflict key=$key requested=$requestedPort switched=$resolvedPort',
      );
    }
    service.logs.add(
      '[${DateTime.now()}] Starting ${service.name} on port $resolvedPort...',
    );
    LogService.instance.info(
      'service',
      'start requested key=$key name=${service.name} port=$resolvedPort',
    );
    notifyListeners();

    final plan = ServiceRuntimeResolver.resolve(key, resolvedPort);
    final nativeRuntime = NativeServiceRuntime(
      spec: plan.native,
      workingDirectory: Directory.systemTemp.path,
    );

    final nativeResult = await nativeRuntime.start();
    if (nativeResult.success && nativeResult.process != null) {
      _attachProcessLogs(service, nativeResult.process!);
      final started = await _waitForNativeStartup(
        nativeResult.process!,
        nativeResult.healthUrl,
      );
      if (started) {
        _bindNativeProcess(service, key, nativeResult, resolvedPort);
        return;
      }

      service.logs.add(
        '[${DateTime.now()}] Native process exited immediately. Trying Docker fallback...',
      );
      if (!await _hasExited(nativeResult.process!)) {
        nativeResult.process!.kill();
      }
      try {
        service.lastExitCode = await nativeResult.process!.exitCode;
      } catch (_) {}
    } else {
      service.logs.add(
        '[${DateTime.now()}] Native start failed: ${nativeResult.error ?? 'unknown error'}',
      );
      LogService.instance.warning(
        'service',
        'native start failed key=$key error=${nativeResult.error ?? 'unknown error'}',
      );
    }

    final dockerSpec = plan.dockerFallback;
    if (dockerSpec == null) {
      service.status = ServiceStatus.error;
      service.errorMessage =
          nativeResult.error ??
          'Native start failed and no Docker fallback exists.';
      LogService.instance.error(
        'service',
        'start failed key=$key reason=${service.errorMessage}',
      );
      notifyListeners();
      return;
    }

    final dockerRuntime = DockerServiceRuntime(
      spec: dockerSpec,
      containerName: _containerName(key, service.port),
    );

    final dockerResult = await dockerRuntime.start();
    if (!dockerResult.success) {
      service.status = ServiceStatus.error;
      service.errorMessage = dockerResult.error ?? 'Docker fallback failed';
      service.logs.add(
        '[${DateTime.now()}] Docker fallback failed: ${service.errorMessage}',
      );
      LogService.instance.error(
        'service',
        'docker fallback failed key=$key error=${service.errorMessage}',
      );
      notifyListeners();
      return;
    }

    service.status = ServiceStatus.running;
    service.runtimeMode = RuntimeMode.docker;
    service.process = null;
    service.pid = null;
    service.binaryPath = dockerResult.binaryPath;
    service.containerName = dockerResult.containerName;
    service.healthUrl = dockerResult.healthUrl;
    service.isDockerFallback = true;
    service.logs.add(
      '[${DateTime.now()}] ${service.name} started in Docker container ${service.containerName} '
      'on port $resolvedPort.',
    );
    LogService.instance.info(
      'service',
      'started key=$key mode=docker port=$resolvedPort container=${service.containerName}',
    );
    await _persistRunningServices();
    notifyListeners();
  }

  Future<int> _resolveServicePort(
    String key,
    int preferredPort,
    ServiceInfo service,
  ) async {
    final free = await PortProbe.isAvailable(preferredPort);
    if (free) return preferredPort;

    final fallbackStart = preferredPort < 1024 ? 1024 : preferredPort + 1;
    final fallback = await PortProbe.findAvailablePort(
      fallbackStart,
      maxAttempts: 120,
    );
    if (fallback == preferredPort) {
      service.logs.add(
        '[${DateTime.now()}] Port $preferredPort is unavailable and no alternative port was found quickly. '
        'Service may fail to start.',
      );
      return preferredPort;
    }
    return fallback;
  }

  Future<bool> _waitForNativeStartup(Process process, Uri? healthUrl) async {
    final startedAt = DateTime.now();
    while (DateTime.now().difference(startedAt) < const Duration(seconds: 8)) {
      final exited = await _hasExited(process);
      if (exited) return false;

      if (healthUrl == null) {
        if (DateTime.now().difference(startedAt) >=
            const Duration(seconds: 2)) {
          return true;
        }
      } else {
        final ok = await _checkHttpHealth(healthUrl);
        if (ok) return true;
      }
      await Future.delayed(const Duration(milliseconds: 250));
    }
    return healthUrl == null;
  }

  Future<bool> _hasExited(Process process) async {
    try {
      await process.exitCode.timeout(const Duration(milliseconds: 20));
      return true;
    } on TimeoutException {
      return false;
    }
  }

  Future<bool> _checkHttpHealth(Uri uri) async {
    HttpClient? client;
    try {
      client = HttpClient()..connectionTimeout = const Duration(seconds: 1);
      final request = await client.getUrl(uri);
      request.followRedirects = false;
      final response = await request.close().timeout(
        const Duration(seconds: 1),
      );
      return response.statusCode >= 200 && response.statusCode < 500;
    } catch (_) {
      return false;
    } finally {
      client?.close(force: true);
    }
  }

  void _attachProcessLogs(ServiceInfo service, Process process) {
    process.stdout.transform(SystemEncoding().decoder).listen((data) {
      final line = data.trim();
      if (line.isNotEmpty) {
        service.logs.add(line);
        notifyListeners();
      }
    });

    process.stderr.transform(SystemEncoding().decoder).listen((data) {
      final line = data.trim();
      if (line.isNotEmpty) {
        service.logs.add(line);
        notifyListeners();
      }
    });
  }

  void _bindNativeProcess(
    ServiceInfo service,
    String key,
    RuntimeStartResult result,
    int port,
  ) {
    service.status = ServiceStatus.running;
    service.runtimeMode = RuntimeMode.native;
    service.process = result.process;
    service.pid = result.pid;
    service.binaryPath = result.binaryPath;
    service.containerName = null;
    service.healthUrl = result.healthUrl;
    service.isDockerFallback = false;

    result.process!.exitCode.then((code) async {
      service.lastExitCode = code;
      service.process = null;
      service.pid = null;
      service.runtimeMode = null;
      service.status = ServiceStatus.stopped;
      service.logs.add('[${DateTime.now()}] $key exited with code $code');
      LogService.instance.warning(
        'service',
        'process exited key=$key code=$code',
      );
      await _persistRunningServices();
      notifyListeners();
    });

    service.logs.add(
      '[${DateTime.now()}] ${service.name} is running (native, pid=${service.pid}, port=$port).',
    );
    LogService.instance.info(
      'service',
      'started key=$key mode=native pid=${service.pid} port=$port binary=${service.binaryPath}',
    );
    _persistRunningServices();
    notifyListeners();
  }

  Future<void> stopService(String key) async {
    final service = _services[key];
    if (service == null || service.status != ServiceStatus.running) return;

    service.status = ServiceStatus.stopping;
    notifyListeners();

    try {
      if (service.runtimeMode == RuntimeMode.docker &&
          service.containerName != null) {
        await Process.run('docker', [
          'rm',
          '-f',
          service.containerName!,
        ], runInShell: true);
      } else {
        service.process?.kill();
      }

      service.process = null;
      service.pid = null;
      service.containerName = null;
      service.runtimeMode = null;
      service.isDockerFallback = false;
      service.status = ServiceStatus.stopped;
      service.logs.add('[${DateTime.now()}] $key stopped');
      LogService.instance.info('service', 'stopped key=$key');
      await _persistRunningServices();
      notifyListeners();
    } catch (e) {
      service.status = ServiceStatus.error;
      service.errorMessage = e.toString();
      service.logs.add('[${DateTime.now()}] Stop failed: $e');
      LogService.instance.error('service', 'stop failed key=$key', error: e);
      notifyListeners();
    }
  }

  void applySettings({
    required int apachePort,
    required int mysqlPort,
    required int phpPort,
    required int redisPort,
    required int nodePort,
    required int postgresPort,
    required int memcachedPort,
    required int mailhogPort,
    required int smtpPort,
    required int websocketPort,
    int? pythonPort,
    bool autoStartServices = false,
    bool restoreOnLaunch = false,
  }) {
    _services['apache']?.port = apachePort;
    _services['mysql']?.port = mysqlPort;
    _services['php']?.port = phpPort;
    _services['redis']?.port = redisPort;
    _services['nodejs']?.port = nodePort;
    _services['postgres']?.port = postgresPort;
    _services['memcached']?.port = memcachedPort;
    _services['mailhog']?.port = mailhogPort;
    _services['smtp']?.port = smtpPort;
    _services['websocket']?.port = websocketPort;
    if (pythonPort != null) {
      _services['python']?.port = pythonPort;
    }
    _autoStartEnabled = autoStartServices;
    notifyListeners();

    if (restoreOnLaunch) {
      _restoreRunningServicesIfNeeded();
    }
  }

  Future<void> startAll() async {
    for (final key in _services.keys) {
      if (_services[key]!.status != ServiceStatus.running) {
        await startService(key);
      }
    }
    await _persistRunningServices();
  }

  Future<void> stopAll() async {
    for (final key in _services.keys) {
      if (_services[key]!.status == ServiceStatus.running) {
        await stopService(key);
      }
    }
    await _persistRunningServices();
  }

  Future<void> restartService(String key) async {
    await stopService(key);
    await startService(key);
  }

  Future<void> _detectVersions() async {
    try {
      final result = await Process.run('php', ['--version']);
      if (result.exitCode == 0) {
        final version = RegExp(
          r'PHP (\d+\.\d+\.\d+)',
        ).firstMatch(result.stdout.toString());
        _services['php']?.version = version?.group(1) ?? 'Unknown';
      }
    } catch (_) {
      _services['php']?.version = 'Not installed';
    }

    try {
      final result = await Process.run('node', ['--version']);
      if (result.exitCode == 0) {
        _services['nodejs']?.version = result.stdout.toString().trim();
      }
    } catch (_) {
      _services['nodejs']?.version = 'Not installed';
    }

    try {
      final result = await Process.run('python', ['--version']);
      final out = result.stdout.toString().trim();
      final err = result.stderr.toString().trim();
      final output = out.isNotEmpty ? out : err;
      if (result.exitCode == 0 || output.contains('Python')) {
        _services['python']?.version = output.replaceFirst('Python ', '');
      }
    } catch (_) {
      _services['python']?.version = 'Not installed';
    }

    try {
      final result = await Process.run('mysql', ['--version']);
      if (result.exitCode == 0) {
        final version = RegExp(
          r'(\d+\.\d+\.\d+)',
        ).firstMatch(result.stdout.toString());
        _services['mysql']?.version = version?.group(1) ?? 'Unknown';
      }
    } catch (_) {
      _services['mysql']?.version = 'Not installed';
    }

    try {
      final result = await Process.run('MailHog', ['-version']);
      if (result.exitCode == 0) {
        final version = RegExp(
          r'(\d+\.\d+\.\d+)',
        ).firstMatch(result.stdout.toString());
        _services['mailhog']?.version = version?.group(1) ?? 'Unknown';
      }
    } catch (_) {
      _services['mailhog']?.version = 'Not installed';
    }

    try {
      final result = await Process.run('mailpit', ['--version']);
      if (result.exitCode == 0) {
        final version = RegExp(
          r'(\d+\.\d+\.\d+)',
        ).firstMatch(result.stdout.toString());
        _services['smtp']?.version = version?.group(1) ?? 'Unknown';
      }
    } catch (_) {
      _services['smtp']?.version = 'Not installed';
    }

    try {
      final result = await Process.run('websocat', ['--version']);
      if (result.exitCode == 0) {
        final version = RegExp(
          r'(\d+\.\d+\.\d+)',
        ).firstMatch(result.stdout.toString());
        _services['websocket']?.version = version?.group(1) ?? 'Unknown';
      }
    } catch (_) {
      _services['websocket']?.version = 'Not installed';
    }

    notifyListeners();
  }

  void _startStatusMonitor() {
    _statusTimer = Timer.periodic(const Duration(seconds: 5), (_) async {
      await _refreshDockerStatuses();
      notifyListeners();
    });
  }

  Future<void> _refreshDockerStatuses() async {
    for (final entry in _services.entries) {
      final service = entry.value;
      if (service.status != ServiceStatus.running ||
          service.runtimeMode != RuntimeMode.docker ||
          service.containerName == null) {
        continue;
      }

      final check = await Process.run('docker', [
        'ps',
        '--filter',
        'name=${service.containerName}',
        '--format',
        '{{.Names}}',
      ], runInShell: true);

      final running =
          check.exitCode == 0 && check.stdout.toString().trim().isNotEmpty;
      if (!running) {
        service.status = ServiceStatus.stopped;
        service.logs.add(
          '[${DateTime.now()}] Docker container ${service.containerName} is not running.',
        );
        service.containerName = null;
        service.runtimeMode = null;
        service.isDockerFallback = false;
      }
    }
  }

  String _containerName(String key, int port) => 'localx-$key-$port';

  Future<void> _persistRunningServices() async {
    final prefs = await SharedPreferences.getInstance();
    final running = _services.entries
        .where((e) => e.value.status == ServiceStatus.running)
        .map((e) => e.key)
        .toList();
    await prefs.setStringList(_prefsRunningKey, running);
  }

  Future<List<String>> _loadRunningServices() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(_prefsRunningKey) ?? [];
  }

  Future<void> _restoreRunningServicesIfNeeded() async {
    if (_restored || !_autoStartEnabled) return;
    _restored = true;
    final running = await _loadRunningServices();
    for (final key in running) {
      if (_services.containsKey(key)) {
        await startService(key);
      }
    }
  }

  @override
  void dispose() {
    _statusTimer?.cancel();
    super.dispose();
  }
}
