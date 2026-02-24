import 'dart:io';
import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/services/project_service.dart';

class PackagesDialog extends StatefulWidget {
  final ProjectInfo project;

  const PackagesDialog({super.key, required this.project});

  @override
  State<PackagesDialog> createState() => _PackagesDialogState();
}

class _PackagesDialogState extends State<PackagesDialog> {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _logController = ScrollController();
  
  bool _isInstalling = false;
  final List<String> _logs = [];
  String _packageManager = 'npm';

  @override
  void initState() {
    super.initState();
    _detectPackageManager();
  }

  void _detectPackageManager() {
    if (widget.project.framework == ProjectFramework.laravel || widget.project.framework == ProjectFramework.php) {
      _packageManager = 'composer';
    } else if (widget.project.framework == ProjectFramework.fastapi || widget.project.framework == ProjectFramework.django) {
      _packageManager = 'pip';
    } else {
      _packageManager = 'npm';
    }
  }

  void _appendLog(String text) {
    if (!mounted) return;
    setState(() {
      _logs.add(text.trim());
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_logController.hasClients) {
        _logController.animateTo(
          _logController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _installPackage() async {
    final pkg = _searchController.text.trim();
    if (pkg.isEmpty || _isInstalling) return;

    setState(() {
      _isInstalling = true;
      _logs.add('Installing $_packageManager package: $pkg...');
    });

    try {
      String command;
      List<String> args;

      if (_packageManager == 'composer') {
        command = Platform.isWindows ? 'composer.bat' : 'composer';
        args = ['require', pkg];
      } else if (_packageManager == 'pip') {
        command = Platform.isWindows ? 'python' : 'python3';
        args = ['-m', 'pip', 'install', pkg];
      } else {
        command = Platform.isWindows ? 'npm.cmd' : 'npm';
        args = ['install', pkg];
      }

      final process = await Process.start(
        command,
        args,
        runInShell: true,
        workingDirectory: widget.project.path,
      );

      process.stdout.transform(SystemEncoding().decoder).listen((data) {
        _appendLog(data);
      });

      process.stderr.transform(SystemEncoding().decoder).listen((data) {
        _appendLog(data);
      });

      final exitCode = await process.exitCode;
      _appendLog('\nProcess finished with exit code $exitCode');
    } catch (e) {
      _appendLog('Error: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isInstalling = false;
          _searchController.clear();
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final accent = isDark ? AppColors.accent : AppColors.accentIndigo;
    final bg = isDark ? AppColors.darkCard : AppColors.lightCard;

    return AlertDialog(
      backgroundColor: bg,
      title: Row(
        children: [
          Icon(Icons.inventory_2_outlined, color: accent),
          const SizedBox(width: 10),
          Text('${widget.project.name} Packages'),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: accent.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              _packageManager,
              style: TextStyle(fontSize: 12, color: accent, fontWeight: FontWeight.bold),
            ),
          )
        ],
      ),
      content: SizedBox(
        width: 600,
        height: 400,
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Search for a $_packageManager package (e.g., axios, livewire)',
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                    ),
                    onSubmitted: (_) => _installPackage(),
                  ),
                ),
                const SizedBox(width: 12),
                ElevatedButton.icon(
                  onPressed: _isInstalling ? null : _installPackage,
                  icon: _isInstalling 
                      ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
                      : const Icon(Icons.download_rounded, size: 18),
                  label: Text(_isInstalling ? 'Installing...' : 'Install'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Expanded(
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.black87,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.darkBorder),
                ),
                child: _logs.isEmpty 
                    ? const Center(
                        child: Text(
                          'No active installations. Search and install a package above.',
                          style: TextStyle(color: Colors.white54, fontSize: 13),
                        ),
                      )
                    : ListView.builder(
                        controller: _logController,
                        itemCount: _logs.length,
                        itemBuilder: (ctx, i) {
                          return Text(
                            _logs[i],
                            style: const TextStyle(
                              fontFamily: 'Consolas',
                              fontSize: 12,
                              color: Colors.greenAccent,
                            ),
                          );
                        },
                      ),
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Close'),
        ),
      ],
    );
  }
}
