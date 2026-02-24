import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:archive/archive.dart';
import 'package:path/path.dart' as p;
import 'port_probe.dart';
import 'template_manager.dart';

enum ProjectFramework {
  laravel,
  react,
  vue,
  nextjs,
  svelte,
  angular,
  nuxt,
  nodejs,
  php,
  fastapi,
  django,
  wordpress,
  unknown,
}

class ProjectInfo {
  final String name;
  final String path;
  final ProjectFramework framework;
  final String? phpVersion;
  final String? nodeVersion;
  String? customDomain;
  int? customDomainPort;
  bool isRunning;
  int? runPort;
  Process? runProcess;
  List<String> logs;

  ProjectInfo({
    required this.name,
    required this.path,
    required this.framework,
    this.phpVersion,
    this.nodeVersion,
    this.customDomain,
    this.customDomainPort,
    this.isRunning = false,
    this.runPort,
    this.runProcess,
    List<String>? logs,
  }) : logs = logs ?? [];

  String get frameworkLabel {
    switch (framework) {
      case ProjectFramework.laravel:
        return 'Laravel';
      case ProjectFramework.react:
        return 'React';
      case ProjectFramework.vue:
        return 'Vue.js';
      case ProjectFramework.nextjs:
        return 'Next.js';
      case ProjectFramework.svelte:
        return 'Svelte';
      case ProjectFramework.angular:
        return 'Angular';
      case ProjectFramework.nuxt:
        return 'Nuxt';
      case ProjectFramework.nodejs:
        return 'Node.js';
      case ProjectFramework.php:
        return 'PHP';
      case ProjectFramework.fastapi:
        return 'FastAPI';
      case ProjectFramework.django:
        return 'Django';
      case ProjectFramework.wordpress:
        return 'WordPress';
      case ProjectFramework.unknown:
        return 'Unknown';
    }
  }

  String get frameworkIcon {
    switch (framework) {
      case ProjectFramework.laravel:
        return 'L';
      case ProjectFramework.react:
        return 'R';
      case ProjectFramework.vue:
        return 'V';
      case ProjectFramework.nextjs:
        return 'N';
      case ProjectFramework.svelte:
        return 'S';
      case ProjectFramework.angular:
        return 'A';
      case ProjectFramework.nuxt:
        return 'Nu';
      case ProjectFramework.nodejs:
        return 'Node';
      case ProjectFramework.php:
        return 'PHP';
      case ProjectFramework.fastapi:
        return 'FA';
      case ProjectFramework.django:
        return 'DJ';
      case ProjectFramework.wordpress:
        return 'WP';
      case ProjectFramework.unknown:
        return '?';
    }
  }

  Map<String, dynamic> toJson() => {
        'name': name,
        'path': path,
        'framework': framework.name,
        'phpVersion': phpVersion,
        'nodeVersion': nodeVersion,
        'customDomain': customDomain,
        'customDomainPort': customDomainPort,
      };

  static ProjectInfo fromJson(Map<String, dynamic> json) {
    final fw = ProjectFramework.values.firstWhere(
      (e) => e.name == json['framework'],
      orElse: () => ProjectFramework.unknown,
    );
    return ProjectInfo(
      name: json['name'] as String,
      path: json['path'] as String,
      framework: fw,
      phpVersion: json['phpVersion'] as String?,
      nodeVersion: json['nodeVersion'] as String?,
      customDomain: json['customDomain'] as String?,
      customDomainPort: json['customDomainPort'] as int?,
    );
  }
}

class ProjectService extends ChangeNotifier {
  final List<ProjectInfo> _projects = [];
  bool _isScanning = false;
  static const _prefsKey = 'localxProjects';

  List<ProjectInfo> get projects => List.unmodifiable(_projects);
  bool get isScanning => _isScanning;

  ProjectService() {
    _load();
  }

  Future<void> addProject(String directoryPath) async {
    final dir = Directory(directoryPath);
    if (!await dir.exists()) return;

    final name = directoryPath.split(Platform.pathSeparator).last;
    final framework = await _detectFramework(directoryPath);

    final project = ProjectInfo(
      name: name,
      path: directoryPath,
      framework: framework,
    );

    if (_projects.any((p) => p.path == directoryPath)) return;

    _projects.add(project);
    await _save();
    notifyListeners();
  }

  void removeProject(int index) {
    if (index >= 0 && index < _projects.length) {
      _projects.removeAt(index);
      _save();
      notifyListeners();
    }
  }

  Future<void> updateProject(ProjectInfo project) async {
    final idx = _projects.indexWhere((p) => p.path == project.path);
    if (idx == -1) return;
    _projects[idx] = project;
    await _save();
    notifyListeners();
  }

  Future<ProjectFramework> _detectFramework(String path) async {
    if (await File('$path${Platform.pathSeparator}artisan').exists()) {
      return ProjectFramework.laravel;
    }

    final packageJsonFile = File('$path${Platform.pathSeparator}package.json');
    if (await packageJsonFile.exists()) {
      final content = await packageJsonFile.readAsString();
      if (content.contains('"next"')) return ProjectFramework.nextjs;
      if (content.contains('"nuxt"')) return ProjectFramework.nuxt;
      if (content.contains('"react"')) return ProjectFramework.react;
      if (content.contains('"vue"')) return ProjectFramework.vue;
      if (content.contains('"svelte"')) return ProjectFramework.svelte;
      if (content.contains('"@angular/core"')) return ProjectFramework.angular;
      return ProjectFramework.nodejs;
    }

    if (await File('$path${Platform.pathSeparator}manage.py').exists()) {
      return ProjectFramework.django;
    }

    if (await File('$path${Platform.pathSeparator}wp-config.php').exists() ||
        await File('$path${Platform.pathSeparator}wp-config-sample.php').exists() ||
        await Directory('$path${Platform.pathSeparator}wp-content').exists()) {
      return ProjectFramework.wordpress;
    }

    final reqFile = File('$path${Platform.pathSeparator}requirements.txt');
    if (await reqFile.exists()) {
      final content = await reqFile.readAsString();
      if (content.toLowerCase().contains('fastapi')) return ProjectFramework.fastapi;
      if (content.toLowerCase().contains('django')) return ProjectFramework.django;
    }

    final pyProject = File('$path${Platform.pathSeparator}pyproject.toml');
    if (await pyProject.exists()) {
      final content = await pyProject.readAsString();
      final lower = content.toLowerCase();
      if (lower.contains('fastapi')) return ProjectFramework.fastapi;
      if (lower.contains('django')) return ProjectFramework.django;
    }

    if (await File('$path${Platform.pathSeparator}index.php').exists()) {
      return ProjectFramework.php;
    }

    return ProjectFramework.unknown;
  }

  Future<void> startProject(ProjectInfo project, {int preferredPort = 3001}) async {
    if (project.isRunning) return;

    final port = await PortProbe.findAvailablePort(preferredPort);
    project.runPort = port;

    try {
      String command = '';
      List<String> args = [];

      if (project.framework == ProjectFramework.laravel) {
        command = Platform.isWindows ? 'php.exe' : 'php';
        args = ['artisan', 'serve', '--host=127.0.0.1', '--port=$port'];
      } else if (project.framework == ProjectFramework.php) {
        command = Platform.isWindows ? 'php.exe' : 'php';
        args = ['-S', '127.0.0.1:$port', '-t', project.path];
      } else if (project.framework == ProjectFramework.django) {
        command = Platform.isWindows ? 'python' : 'python3';
        args = ['manage.py', 'runserver', '127.0.0.1:$port'];
      } else if (project.framework == ProjectFramework.fastapi) {
        command = Platform.isWindows ? 'python' : 'python3';
        args = ['-m', 'uvicorn', 'main:app', '--reload', '--host', '127.0.0.1', '--port', '$port'];
      } else {
        final script = await _detectNodeScript(project.path);
        command = Platform.isWindows ? 'npm.cmd' : 'npm';
        args = ['run', script];
      }

      project.logs.add('[${DateTime.now()}] Starting ${project.frameworkLabel} on $port');
      notifyListeners();

      final proc = await Process.start(
        command,
        args,
        runInShell: true,
        workingDirectory: project.path,
      );
      project.runProcess = proc;
      project.isRunning = true;
      notifyListeners();

      proc.stdout.transform(SystemEncoding().decoder).listen((data) {
        project.logs.add(data.trim());
        notifyListeners();
      });
      proc.stderr.transform(SystemEncoding().decoder).listen((data) {
        project.logs.add(data.trim());
        notifyListeners();
      });
      proc.exitCode.then((code) {
        project.isRunning = false;
        project.logs.add('[${DateTime.now()}] Process exited ($code)');
        notifyListeners();
      });
    } catch (e) {
      project.logs.add('Error: $e');
      project.isRunning = false;
      notifyListeners();
    }
  }

  Future<void> stopProject(ProjectInfo project) async {
    if (!project.isRunning) return;
    try {
      project.runProcess?.kill();
      project.runProcess = null;
      project.isRunning = false;
      project.logs.add('[${DateTime.now()}] Stopped');
      notifyListeners();
    } catch (e) {
      project.logs.add('Error: $e');
      notifyListeners();
    }
  }

  Future<String> _detectNodeScript(String path) async {
    final packageJsonFile = File('$path${Platform.pathSeparator}package.json');
    if (!await packageJsonFile.exists()) return 'start';
    try {
      final content = await packageJsonFile.readAsString();
      final json = jsonDecode(content) as Map<String, dynamic>;
      final scripts = json['scripts'] as Map<String, dynamic>? ?? {};
      if (scripts.containsKey('dev')) return 'dev';
      if (scripts.containsKey('start')) return 'start';
      if (scripts.containsKey('serve')) return 'serve';
    } catch (_) {}
    return 'start';
  }

  Future<void> createProject({
    required String name,
    required String path,
    required ProjectFramework framework,
    String? version,
    Function(String log)? onLog,
  }) async {
    _isScanning = true;
    notifyListeners();

    try {
      String command;
      List<String> args;
      final fullPath = '$path${Platform.pathSeparator}$name';
      final templateType = _mapTemplate(framework);
      final allowTemplateFallback = version == null || version.isEmpty;
      bool usedTemplate = false;

      switch (framework) {
        case ProjectFramework.laravel:
          command = Platform.isWindows ? 'composer.bat' : 'composer';
          final pkg = version != null && version.isNotEmpty ? 'laravel/laravel:$version' : 'laravel/laravel';
          args = ['create-project', pkg, fullPath];
          break;
        case ProjectFramework.react:
          command = Platform.isWindows ? 'npx.cmd' : 'npx';
          final pkg = version != null && version.isNotEmpty ? 'create-react-app@$version' : 'create-react-app';
          args = ['-y', pkg, fullPath];
          break;
        case ProjectFramework.vue:
          command = Platform.isWindows ? 'npx.cmd' : 'npx';
          final pkg = version != null && version.isNotEmpty ? 'create-vue@$version' : 'create-vue@latest';
          args = ['-y', pkg, fullPath, '--default'];
          break;
        case ProjectFramework.nextjs:
          command = Platform.isWindows ? 'npx.cmd' : 'npx';
          final pkg = version != null && version.isNotEmpty ? 'create-next-app@$version' : 'create-next-app@latest';
          args = ['-y', pkg, fullPath, '--yes'];
          break;
        case ProjectFramework.svelte:
          command = Platform.isWindows ? 'npx.cmd' : 'npx';
          final pkg = version != null && version.isNotEmpty ? 'create-svelte@$version' : 'create-svelte@latest';
          args = ['-y', pkg, fullPath];
          break;
        case ProjectFramework.angular:
          command = Platform.isWindows ? 'npx.cmd' : 'npx';
          final pkg = version != null && version.isNotEmpty ? '@angular/cli@$version' : '@angular/cli@latest';
          args = ['-y', pkg, 'new', name, '--directory', fullPath, '--defaults', '--skip-git'];
          break;
        case ProjectFramework.nuxt:
          command = Platform.isWindows ? 'npx.cmd' : 'npx';
          final pkg = version != null && version.isNotEmpty ? 'nuxi@$version' : 'nuxi@latest';
          args = ['-y', pkg, 'init', fullPath];
          break;
        case ProjectFramework.nodejs:
          command = Platform.isWindows ? 'npm.cmd' : 'npm';
          args = ['init', '-y'];
          await Directory(fullPath).create(recursive: true);
          break;
        case ProjectFramework.php:
          await Directory(fullPath).create(recursive: true);
          final file = File('$fullPath${Platform.pathSeparator}index.php');
          await file.writeAsString('<?php\n\necho "Hello LocalX!";\n');
          command = '';
          args = [];
          break;
        case ProjectFramework.fastapi:
          command = Platform.isWindows ? 'python' : 'python3';
          await Directory(fullPath).create(recursive: true);
          final ver = version != null && version.isNotEmpty ? 'fastapi==$version' : 'fastapi';
          args = [
            '-m',
            'pip',
            'install',
            ver,
            'uvicorn',
          ];
          if (onLog != null) onLog('Installing FastAPI dependencies for scaffold...\n');
          break;
        case ProjectFramework.django:
          command = Platform.isWindows ? 'django-admin' : 'django-admin';
          final pkg = version != null && version.isNotEmpty ? 'django==$version' : 'django';
          await Directory(fullPath).create(recursive: true);
          args = ['startproject', 'app', fullPath];
          if (onLog != null) onLog('Attempting Django scaffold (requires $pkg installed)\n');
          break;
        case ProjectFramework.wordpress:
          await Directory(fullPath).create(recursive: true);
          final tpl = _mapTemplate(ProjectFramework.wordpress);
          if (tpl != null && await TemplateManager.hasTemplate(tpl)) {
            if (onLog != null) onLog('Using offline WordPress template...\n');
            await TemplateManager.extractTemplate(tpl, fullPath);
          } else {
            if (onLog != null) onLog('Downloading WordPress from wordpress.org...\n');
            await _downloadAndExtractZip('https://wordpress.org/latest.zip', fullPath);
          }
          command = '';
          args = [];
          break;
        default:
          command = '';
          args = [];
      }

      if (command.isNotEmpty) {
        if (onLog != null) onLog('Executing: $command ${args.join(' ')}\n');

        final workingDir = framework == ProjectFramework.nodejs ? fullPath : path;

        final process = await Process.start(
          command,
          args,
          runInShell: true,
          workingDirectory: workingDir,
        );

        process.stdout.transform(SystemEncoding().decoder).listen((data) {
          if (onLog != null) onLog(data);
        });

        process.stderr.transform(SystemEncoding().decoder).listen((data) {
          if (onLog != null) onLog(data);
        });

        final exitCode = await process.exitCode;
        if (onLog != null) onLog('\nProcess finished with exit code $exitCode\n');
        if (exitCode != 0) {
          if (allowTemplateFallback && templateType != null && await TemplateManager.hasTemplate(templateType)) {
            if (onLog != null) {
              onLog('Generator failed. Falling back to offline template for ${framework.name}...\n');
            }
            await TemplateManager.extractTemplate(templateType, fullPath);
            usedTemplate = true;
          } else {
            throw Exception('Project generator exited with code $exitCode');
          }
        } else {
          if (framework == ProjectFramework.fastapi) {
            final main = File('$fullPath${Platform.pathSeparator}main.py');
            final req = File('$fullPath${Platform.pathSeparator}requirements.txt');
            if (!await main.exists()) {
              await main.writeAsString(
                'from fastapi import FastAPI\n\napp = FastAPI()\n\n@app.get("/")\n'
                'def read_root():\n    return {"status": "ok", "message": "Hello LocalX"}\n',
              );
            }
            if (!await req.exists()) {
              final ver = version != null && version.isNotEmpty ? 'fastapi==$version' : 'fastapi';
              await req.writeAsString('$ver\nuvicorn\n');
            }
          }
          if (framework == ProjectFramework.php) {
            await Directory(fullPath).create(recursive: true);
            final file = File('$fullPath${Platform.pathSeparator}index.php');
            if (!await file.exists()) {
              await file.writeAsString('<?php\n\necho "Hello LocalX!";\n');
            }
          }
        }
      } else if (allowTemplateFallback && templateType != null && !usedTemplate && await TemplateManager.hasTemplate(templateType)) {
        if (onLog != null) onLog('Using offline template for ${framework.name}...\n');
        await TemplateManager.extractTemplate(templateType, fullPath);
        usedTemplate = true;
      }

      await addProject(fullPath);
      await _save();
    } catch (e) {
      debugPrint('Error creating project: $e');
      if (onLog != null) onLog('Error: $e\n');
    }

    _isScanning = false;
    notifyListeners();
  }

  TemplateType? _mapTemplate(ProjectFramework framework) {
    switch (framework) {
      case ProjectFramework.laravel:
        return TemplateType.laravel;
      case ProjectFramework.react:
        return TemplateType.react;
      case ProjectFramework.vue:
        return TemplateType.vue;
      case ProjectFramework.nextjs:
        return TemplateType.nextjs;
      case ProjectFramework.svelte:
        return TemplateType.svelte;
      case ProjectFramework.angular:
        return TemplateType.angular;
      case ProjectFramework.nuxt:
        return TemplateType.nuxt;
      case ProjectFramework.nodejs:
        return TemplateType.nodejs;
      case ProjectFramework.php:
        return TemplateType.php;
      case ProjectFramework.fastapi:
        return TemplateType.fastapi;
      case ProjectFramework.django:
        return TemplateType.django;
      case ProjectFramework.wordpress:
        return TemplateType.wordpress;
      default:
        return null;
    }
  }

  Future<void> _downloadAndExtractZip(String url, String destinationPath) async {
    final httpClient = HttpClient();
    final request = await httpClient.getUrl(Uri.parse(url));
    final response = await request.close();
    if (response.statusCode != 200) {
      throw Exception('Download failed with status ${response.statusCode}');
    }
    final bytes = await response.fold<List<int>>([], (prev, element) => prev..addAll(element));
    httpClient.close();
    final archive = ZipDecoder().decodeBytes(bytes);

    final destDir = Directory(destinationPath);
    if (!await destDir.exists()) {
      await destDir.create(recursive: true);
    }

    for (final file in archive) {
      final filename = file.name;
      if (filename.isEmpty) continue;
      final outPath = p.join(destinationPath, filename.replaceFirst('wordpress/', ''));
      if (file.isFile) {
        final outFile = File(outPath);
        await outFile.parent.create(recursive: true);
        final content = file.content as List<int>;
        await outFile.writeAsBytes(content, flush: true);
      } else {
        await Directory(outPath).create(recursive: true);
      }
    }
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_prefsKey);
    if (raw == null || raw.isEmpty) return;
    try {
      final data = jsonDecode(raw) as List;
      _projects
        ..clear()
        ..addAll(data.map((e) => ProjectInfo.fromJson(e as Map<String, dynamic>)));
      notifyListeners();
    } catch (_) {}
  }

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    final data = _projects.map((e) => e.toJson()).toList();
    await prefs.setString(_prefsKey, jsonEncode(data));
  }
}
