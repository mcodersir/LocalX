import 'dart:io';

enum RuntimeMode { native, docker }

class NativeRuntimeSpec {
  final String command;
  final List<String> args;
  final Uri? healthUrl;

  const NativeRuntimeSpec({
    required this.command,
    required this.args,
    this.healthUrl,
  });
}

class DockerRuntimeSpec {
  final String image;
  final int hostPort;
  final int containerPort;
  final List<String> env;
  final List<String> command;
  final Uri? healthUrl;

  const DockerRuntimeSpec({
    required this.image,
    required this.hostPort,
    required this.containerPort,
    this.env = const [],
    this.command = const [],
    this.healthUrl,
  });
}

class ServiceRuntimePlan {
  final NativeRuntimeSpec native;
  final DockerRuntimeSpec? dockerFallback;

  const ServiceRuntimePlan({
    required this.native,
    this.dockerFallback,
  });
}

class RuntimeStartResult {
  final bool success;
  final RuntimeMode mode;
  final Process? process;
  final int? pid;
  final String? containerName;
  final Uri? healthUrl;
  final String? error;
  final String binaryPath;

  const RuntimeStartResult({
    required this.success,
    required this.mode,
    required this.binaryPath,
    this.process,
    this.pid,
    this.containerName,
    this.healthUrl,
    this.error,
  });
}

abstract class ServiceRuntime {
  Future<RuntimeStartResult> start();
}

class NativeServiceRuntime implements ServiceRuntime {
  final NativeRuntimeSpec spec;
  final String workingDirectory;

  const NativeServiceRuntime({
    required this.spec,
    required this.workingDirectory,
  });

  @override
  Future<RuntimeStartResult> start() async {
    try {
      final process = await Process.start(
        spec.command,
        spec.args,
        runInShell: true,
        workingDirectory: workingDirectory,
      );
      return RuntimeStartResult(
        success: true,
        mode: RuntimeMode.native,
        process: process,
        pid: process.pid,
        healthUrl: spec.healthUrl,
        binaryPath: spec.command,
      );
    } catch (e) {
      return RuntimeStartResult(
        success: false,
        mode: RuntimeMode.native,
        error: e.toString(),
        binaryPath: spec.command,
      );
    }
  }
}

class DockerServiceRuntime implements ServiceRuntime {
  final DockerRuntimeSpec spec;
  final String containerName;

  const DockerServiceRuntime({
    required this.spec,
    required this.containerName,
  });

  @override
  Future<RuntimeStartResult> start() async {
    try {
      await Process.run('docker', ['rm', '-f', containerName], runInShell: true);

      final args = <String>[
        'run',
        '-d',
        '--name',
        containerName,
        '-p',
        '${spec.hostPort}:${spec.containerPort}',
      ];
      for (final env in spec.env) {
        args.addAll(['-e', env]);
      }
      args.add(spec.image);
      args.addAll(spec.command);

      final run = await Process.run('docker', args, runInShell: true);
      if (run.exitCode != 0) {
        return RuntimeStartResult(
          success: false,
          mode: RuntimeMode.docker,
          error: run.stderr.toString().trim(),
          binaryPath: 'docker',
        );
      }

      return RuntimeStartResult(
        success: true,
        mode: RuntimeMode.docker,
        containerName: containerName,
        healthUrl: spec.healthUrl,
        binaryPath: 'docker',
      );
    } catch (e) {
      return RuntimeStartResult(
        success: false,
        mode: RuntimeMode.docker,
        error: e.toString(),
        binaryPath: 'docker',
      );
    }
  }
}

class ServiceRuntimeResolver {
  static ServiceRuntimePlan resolve(String key, int port) {
    switch (key) {
      case 'apache':
        return ServiceRuntimePlan(
          native: NativeRuntimeSpec(
            command: Platform.isWindows ? 'httpd.exe' : 'httpd',
            args: Platform.isWindows ? ['-DFOREGROUND', '-X'] : ['-DFOREGROUND'],
            healthUrl: Uri.parse('http://127.0.0.1:$port'),
          ),
          dockerFallback: DockerRuntimeSpec(
            image: 'httpd:2.4',
            hostPort: port,
            containerPort: 80,
            healthUrl: Uri.parse('http://127.0.0.1:$port'),
          ),
        );
      case 'mysql':
        return ServiceRuntimePlan(
          native: NativeRuntimeSpec(
            command: Platform.isWindows ? 'mysqld.exe' : 'mysqld',
            args: ['--port=$port'],
          ),
          dockerFallback: DockerRuntimeSpec(
            image: 'mysql:8.4',
            hostPort: port,
            containerPort: 3306,
            env: const ['MYSQL_ROOT_PASSWORD=localx', 'MYSQL_DATABASE=localx'],
          ),
        );
      case 'php':
        return ServiceRuntimePlan(
          native: NativeRuntimeSpec(
            command: Platform.isWindows ? 'php.exe' : 'php',
            args: ['-S', '127.0.0.1:$port'],
            healthUrl: Uri.parse('http://127.0.0.1:$port'),
          ),
          dockerFallback: DockerRuntimeSpec(
            image: 'php:8.4-cli',
            hostPort: port,
            containerPort: port,
            command: ['php', '-S', '0.0.0.0:$port'],
            healthUrl: Uri.parse('http://127.0.0.1:$port'),
          ),
        );
      case 'python':
        return ServiceRuntimePlan(
          native: NativeRuntimeSpec(
            command: Platform.isWindows ? 'python' : 'python3',
            args: ['-m', 'http.server', '$port', '--bind', '127.0.0.1'],
            healthUrl: Uri.parse('http://127.0.0.1:$port'),
          ),
          dockerFallback: DockerRuntimeSpec(
            image: 'python:3.13-alpine',
            hostPort: port,
            containerPort: port,
            command: ['python', '-m', 'http.server', '$port', '--bind', '0.0.0.0'],
            healthUrl: Uri.parse('http://127.0.0.1:$port'),
          ),
        );
      case 'redis':
        return ServiceRuntimePlan(
          native: NativeRuntimeSpec(
            command: Platform.isWindows ? 'redis-server.exe' : 'redis-server',
            args: ['--port', '$port'],
          ),
          dockerFallback: DockerRuntimeSpec(
            image: 'redis:7',
            hostPort: port,
            containerPort: 6379,
          ),
        );
      case 'nodejs':
        final script =
            "require('http').createServer((_,r)=>r.end('LocalX Node')).listen($port,'127.0.0.1')";
        return ServiceRuntimePlan(
          native: NativeRuntimeSpec(
            command: Platform.isWindows ? 'node.exe' : 'node',
            args: ['-e', script],
            healthUrl: Uri.parse('http://127.0.0.1:$port'),
          ),
          dockerFallback: DockerRuntimeSpec(
            image: 'node:22-alpine',
            hostPort: port,
            containerPort: port,
            command: ['node', '-e', script.replaceAll('127.0.0.1', '0.0.0.0')],
            healthUrl: Uri.parse('http://127.0.0.1:$port'),
          ),
        );
      case 'postgres':
        return ServiceRuntimePlan(
          native: NativeRuntimeSpec(
            command: Platform.isWindows ? 'postgres.exe' : 'postgres',
            args: ['-p', '$port'],
          ),
          dockerFallback: DockerRuntimeSpec(
            image: 'postgres:17',
            hostPort: port,
            containerPort: 5432,
            env: const ['POSTGRES_PASSWORD=localx', 'POSTGRES_DB=localx'],
          ),
        );
      case 'memcached':
        return ServiceRuntimePlan(
          native: NativeRuntimeSpec(
            command: Platform.isWindows ? 'memcached.exe' : 'memcached',
            args: ['-p', '$port'],
          ),
          dockerFallback: DockerRuntimeSpec(
            image: 'memcached:1.6',
            hostPort: port,
            containerPort: 11211,
          ),
        );
      case 'mailhog':
        return ServiceRuntimePlan(
          native: NativeRuntimeSpec(
            command: Platform.isWindows ? 'MailHog.exe' : 'MailHog',
            args: ['-ui-bind-addr', '127.0.0.1:$port'],
            healthUrl: Uri.parse('http://127.0.0.1:$port'),
          ),
          dockerFallback: DockerRuntimeSpec(
            image: 'mailhog/mailhog:latest',
            hostPort: port,
            containerPort: 8025,
            healthUrl: Uri.parse('http://127.0.0.1:$port'),
          ),
        );
      case 'smtp':
        return ServiceRuntimePlan(
          native: NativeRuntimeSpec(
            command: Platform.isWindows ? 'mailpit.exe' : 'mailpit',
            args: ['--smtp-bind-addr', '127.0.0.1:$port'],
          ),
          dockerFallback: DockerRuntimeSpec(
            image: 'axllent/mailpit:latest',
            hostPort: port,
            containerPort: 1025,
          ),
        );
      case 'websocket':
        return ServiceRuntimePlan(
          native: NativeRuntimeSpec(
            command: Platform.isWindows ? 'websocat.exe' : 'websocat',
            args: ['-s', '$port'],
          ),
          dockerFallback: DockerRuntimeSpec(
            image: 'vi/websocat:latest',
            hostPort: port,
            containerPort: 8080,
            command: ['-s', '8080'],
          ),
        );
      default:
        return ServiceRuntimePlan(
          native: const NativeRuntimeSpec(command: 'cmd', args: ['/c', 'echo unsupported']),
        );
    }
  }
}
