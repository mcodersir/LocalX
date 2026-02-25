import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/services/settings_service.dart';
import '../../core/services/translation_service.dart';
import '../../core/services/version_manager.dart';
import '../../core/services/php_ini_service.dart';
import '../../core/services/port_probe.dart';
import '../../core/services/log_service.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/services/update_service.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final settings = context.watch<SettingsService>();
    final txt = isDark ? AppColors.darkText : AppColors.lightText;
    final sub = isDark
        ? AppColors.darkTextSecondary
        : AppColors.lightTextSecondary;
    final bg = isDark ? AppColors.darkCard : AppColors.lightCard;
    final brd = isDark ? AppColors.darkBorder : AppColors.lightBorder;
    final accent = isDark ? AppColors.accent : AppColors.accentIndigo;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            context.tr('settings'),
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.w700,
              color: txt,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            context.tr('configure_env'),
            style: TextStyle(fontSize: 14, color: sub),
          ),
          const SizedBox(height: 28),

          // Appearance
          _section(
            context.tr('appearance'),
            Icons.palette_outlined,
            accent,
            txt,
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: bg,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: brd),
            ),
            child: Column(
              children: [
                _themeRow(
                  context.tr('theme'),
                  context.tr('choose_theme'),
                  settings.themeMode,
                  (m) => settings.setThemeMode(m),
                  txt,
                  sub,
                  accent,
                  isDark,
                  context,
                ),
                Divider(height: 24, color: brd),
                _langRow(
                  context.tr('language'),
                  context.tr('choose_language'),
                  settings.language,
                  (l) => settings.setLanguage(l),
                  txt,
                  sub,
                  isDark,
                  context,
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Ports
          _section(context.tr('ports'), Icons.lan_outlined, accent, txt),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: bg,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: brd),
            ),
            child: Column(
              children: [
                _portRow(
                  'Apache HTTP',
                  settings.apachePort,
                  (v) => settings.setApachePort(v),
                  txt,
                  sub,
                ),
                Divider(height: 24, color: brd),
                _portRow(
                  'MySQL',
                  settings.mysqlPort,
                  (v) => settings.setMysqlPort(v),
                  txt,
                  sub,
                ),
                Divider(height: 24, color: brd),
                _portRow(
                  'PHP (FPM/CLI)',
                  settings.phpPort,
                  (v) => settings.setPhpPort(v),
                  txt,
                  sub,
                ),
                Divider(height: 24, color: brd),
                _portRow(
                  'Redis',
                  settings.redisPort,
                  (v) => settings.setRedisPort(v),
                  txt,
                  sub,
                ),
                Divider(height: 24, color: brd),
                _portRow(
                  'Node.js',
                  settings.nodePort,
                  (v) => settings.setNodePort(v),
                  txt,
                  sub,
                ),
                Divider(height: 24, color: brd),
                _portRow(
                  'PostgreSQL',
                  settings.postgresPort,
                  (v) => settings.setPostgresPort(v),
                  txt,
                  sub,
                ),
                Divider(height: 24, color: brd),
                _portRow(
                  'Memcached',
                  settings.memcachedPort,
                  (v) => settings.setMemcachedPort(v),
                  txt,
                  sub,
                ),
                Divider(height: 24, color: brd),
                _portRow(
                  'Mailhog (Web UI)',
                  settings.mailhogPort,
                  (v) => settings.setMailhogPort(v),
                  txt,
                  sub,
                ),
                Divider(height: 24, color: brd),
                _portRow(
                  'SMTP (Mailpit)',
                  settings.smtpPort,
                  (v) => settings.setSmtpPort(v),
                  txt,
                  sub,
                ),
                Divider(height: 24, color: brd),
                _portRow(
                  'WebSocket',
                  settings.websocketPort,
                  (v) => settings.setWebsocketPort(v),
                  txt,
                  sub,
                ),
                Divider(height: 24, color: brd),
                _portRow(
                  'Python',
                  settings.pythonPort,
                  (v) => settings.setPythonPort(v),
                  txt,
                  sub,
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // General
          _section(context.tr('general'), Icons.tune_outlined, accent, txt),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: bg,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: brd),
            ),
            child: Column(
              children: [
                _switchRow(
                  context.tr('auto_start'),
                  context.tr('auto_start_desc'),
                  settings.autoStartServices,
                  (v) => settings.setAutoStart(v),
                  txt,
                  sub,
                ),
                Divider(height: 24, color: brd),
                _switchRow(
                  context.tr('start_minimized'),
                  context.tr('start_min_desc'),
                  settings.startMinimized,
                  (v) => settings.setStartMinimized(v),
                  txt,
                  sub,
                ),
                Divider(height: 24, color: brd),
                _switchRow(
                  context.tr('minimize_to_tray'),
                  context.tr('minimize_to_tray_desc'),
                  settings.minimizeToTray,
                  (v) => settings.setMinimizeToTray(v),
                  txt,
                  sub,
                ),
                Divider(height: 24, color: brd),
                _switchRow(
                  context.tr('close_to_tray'),
                  context.tr('close_to_tray_desc'),
                  settings.closeToTray,
                  (v) => settings.setCloseToTray(v),
                  txt,
                  sub,
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // PHP Settings
          _section('PHP Settings', Icons.tune_outlined, accent, txt),
          const SizedBox(height: 12),
          _PhpSettingsCard(
            isDark: isDark,
            bg: bg,
            brd: brd,
            txt: txt,
            sub: sub,
          ),
          const SizedBox(height: 24),

          // About
          _section(context.tr('about'), Icons.info_outlined, accent, txt),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: bg,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: brd),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: AppColors.brandDark,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Center(
                        child: Text(
                          'LX',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'LocalX',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: txt,
                          ),
                        ),
                        Text(
                          'Version 1.4.0',
                          style: TextStyle(fontSize: 13, color: sub),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  'Modern development environment manager.',
                  style: TextStyle(fontSize: 13, color: sub),
                ),
                const SizedBox(height: 8),
                Text(
                  'Designed by MCODERs and Dicode.ir',
                  style: TextStyle(fontSize: 12, color: sub),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _linkButton('GitHub', 'https://github.com/mcodersir', sub),
                    _linkButton(
                      'Updates',
                      'https://github.com/mcodersir/LocalX',
                      sub,
                    ),
                    OutlinedButton.icon(
                      onPressed: () => LogService.instance.openLogsDirectory(),
                      icon: const Icon(Icons.folder_open_outlined, size: 14),
                      label: Text(
                        'Logs Folder',
                        style: TextStyle(fontSize: 12, color: sub),
                      ),
                    ),
                    OutlinedButton.icon(
                      onPressed: () => _showUpdateDialog(context),
                      icon: const Icon(
                        Icons.system_update_alt_outlined,
                        size: 14,
                      ),
                      label: Text(
                        'Check Updates',
                        style: TextStyle(fontSize: 12, color: sub),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _section(String title, IconData icon, Color accent, Color txt) {
    return Row(
      children: [
        Icon(icon, size: 20, color: accent),
        const SizedBox(width: 8),
        Text(
          title,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: txt,
          ),
        ),
      ],
    );
  }

  Widget _themeRow(
    String label,
    String desc,
    ThemeMode mode,
    ValueChanged<ThemeMode> onChanged,
    Color txt,
    Color sub,
    Color accent,
    bool isDark,
    BuildContext context,
  ) {
    return Row(
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: txt,
              ),
            ),
            Text(desc, style: TextStyle(fontSize: 12, color: sub)),
          ],
        ),
        const Spacer(),
        SegmentedButton<ThemeMode>(
          segments: [
            ButtonSegment(
              value: ThemeMode.light,
              icon: const Icon(Icons.light_mode_outlined, size: 16),
              label: Text(context.tr('light')),
            ),
            ButtonSegment(
              value: ThemeMode.dark,
              icon: const Icon(Icons.dark_mode_outlined, size: 16),
              label: Text(context.tr('dark')),
            ),
            ButtonSegment(
              value: ThemeMode.system,
              icon: const Icon(Icons.computer_outlined, size: 16),
              label: Text(context.tr('system')),
            ),
          ],
          selected: {mode},
          onSelectionChanged: (s) => onChanged(s.first),
          style: ButtonStyle(
            backgroundColor: WidgetStateProperty.resolveWith(
              (states) => states.contains(WidgetState.selected)
                  ? accent.withValues(alpha: 0.2)
                  : (isDark ? AppColors.darkSurface : AppColors.lightSurface),
            ),
            foregroundColor: WidgetStatePropertyAll(txt),
            side: WidgetStatePropertyAll(
              BorderSide(
                color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
              ),
            ),
            textStyle: const WidgetStatePropertyAll(
              TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
            ),
          ),
        ),
      ],
    );
  }

  Widget _langRow(
    String label,
    String desc,
    String lang,
    ValueChanged<String> onChanged,
    Color txt,
    Color sub,
    bool isDark,
    BuildContext context,
  ) {
    return Row(
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: txt,
              ),
            ),
            Text(desc, style: TextStyle(fontSize: 12, color: sub)),
          ],
        ),
        const Spacer(),
        SegmentedButton<String>(
          segments: const [
            ButtonSegment(value: 'en', label: Text('English')),
            ButtonSegment(value: 'fa', label: Text('فارسی')),
          ],
          selected: {lang},
          onSelectionChanged: (s) => onChanged(s.first),
          style: ButtonStyle(
            backgroundColor: WidgetStateProperty.resolveWith(
              (states) => states.contains(WidgetState.selected)
                  ? (isDark
                        ? AppColors.accent.withValues(alpha: 0.2)
                        : AppColors.accentIndigo.withValues(alpha: 0.2))
                  : (isDark ? AppColors.darkSurface : AppColors.lightSurface),
            ),
            foregroundColor: WidgetStatePropertyAll(txt),
            side: WidgetStatePropertyAll(
              BorderSide(
                color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
              ),
            ),
            textStyle: const WidgetStatePropertyAll(
              TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
            ),
          ),
        ),
      ],
    );
  }

  Widget _portRow(
    String label,
    int port,
    ValueChanged<int> onChanged,
    Color txt,
    Color sub,
  ) {
    return Row(
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: txt,
              ),
            ),
            Text('Port $port', style: TextStyle(fontSize: 12, color: sub)),
          ],
        ),
        const Spacer(),
        FutureBuilder<bool>(
          future: PortProbe.isAvailable(port),
          builder: (context, snapshot) {
            final ok = snapshot.data == true;
            final color = ok ? AppColors.running : AppColors.warning;
            final label = ok ? 'Available' : 'In Use';
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              margin: const EdgeInsets.only(right: 10),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: color.withValues(alpha: 0.25)),
              ),
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 10,
                  color: color,
                  fontWeight: FontWeight.w600,
                ),
              ),
            );
          },
        ),
        SizedBox(
          width: 100,
          height: 38,
          child: TextField(
            controller: TextEditingController(text: '$port'),
            keyboardType: TextInputType.number,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14, color: txt),
            onSubmitted: (v) {
              final p = int.tryParse(v);
              if (p != null) onChanged(p);
            },
            decoration: InputDecoration(
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 8,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _switchRow(
    String title,
    String desc,
    bool value,
    ValueChanged<bool> onChanged,
    Color txt,
    Color sub,
  ) {
    return Row(
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: txt,
              ),
            ),
            Text(desc, style: TextStyle(fontSize: 12, color: sub)),
          ],
        ),
        const Spacer(),
        Switch(value: value, onChanged: onChanged),
      ],
    );
  }

  Widget _linkButton(String label, String url, Color sub) {
    return OutlinedButton.icon(
      onPressed: () => launchUrl(Uri.parse(url)),
      icon: const Icon(Icons.open_in_new, size: 14),
      label: Text(label, style: TextStyle(fontSize: 12, color: sub)),
    );
  }

  void _showUpdateDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Text('Check Updates'),
          content: FutureBuilder<UpdateInfo>(
            future: UpdateService.checkForUpdates(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Row(
                  children: const [
                    SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                    SizedBox(width: 12),
                    Text('Checking...'),
                  ],
                );
              }
              if (snapshot.hasError) {
                return Text('Update check failed: ${snapshot.error}');
              }
              final info = snapshot.data!;
              return Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Current: ${info.currentVersion}'),
                  Text('Latest: ${info.latestVersion}'),
                  const SizedBox(height: 8),
                  Text(
                    info.isUpdateAvailable
                        ? 'Update available!'
                        : 'You are up to date.',
                  ),
                ],
              );
            },
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }
}

class _PhpSettingsCard extends StatefulWidget {
  final bool isDark;
  final Color bg;
  final Color brd;
  final Color txt;
  final Color sub;
  const _PhpSettingsCard({
    required this.isDark,
    required this.bg,
    required this.brd,
    required this.txt,
    required this.sub,
  });

  @override
  State<_PhpSettingsCard> createState() => _PhpSettingsCardState();
}

class _PhpSettingsCardState extends State<_PhpSettingsCard> {
  final _memoryCtrl = TextEditingController();
  final _uploadCtrl = TextEditingController();
  final _postCtrl = TextEditingController();
  final _execCtrl = TextEditingController();
  final _inputVarsCtrl = TextEditingController();
  bool _loading = true;
  bool _saving = false;
  String? _phpPath;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final vm = context.read<VersionManager>();
    _phpPath = vm.installed['PHP']?.path;
    if (_phpPath == null) {
      setState(() => _loading = false);
      return;
    }

    final settings = await PhpIniService.load(_phpPath!);
    if (settings != null) {
      _memoryCtrl.text = settings.memoryLimit;
      _uploadCtrl.text = settings.uploadMaxFilesize;
      _postCtrl.text = settings.postMaxSize;
      _execCtrl.text = settings.maxExecutionTime;
      _inputVarsCtrl.text = settings.maxInputVars;
    }
    setState(() => _loading = false);
  }

  Future<void> _save() async {
    if (_phpPath == null) return;
    setState(() => _saving = true);
    final settings = PhpIniSettings(
      memoryLimit: _memoryCtrl.text.trim(),
      uploadMaxFilesize: _uploadCtrl.text.trim(),
      postMaxSize: _postCtrl.text.trim(),
      maxExecutionTime: _execCtrl.text.trim(),
      maxInputVars: _inputVarsCtrl.text.trim(),
    );
    await PhpIniService.save(_phpPath!, settings);
    if (mounted) setState(() => _saving = false);
  }

  @override
  void dispose() {
    _memoryCtrl.dispose();
    _uploadCtrl.dispose();
    _postCtrl.dispose();
    _execCtrl.dispose();
    _inputVarsCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: widget.bg,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: widget.brd),
        ),
        child: Row(
          children: [
            const SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
            const SizedBox(width: 12),
            Text(
              'Loading PHP settings...',
              style: TextStyle(fontSize: 13, color: widget.sub),
            ),
          ],
        ),
      );
    }

    if (_phpPath == null) {
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: widget.bg,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: widget.brd),
        ),
        child: Text(
          'PHP not installed. Install a PHP version to edit settings.',
          style: TextStyle(fontSize: 13, color: widget.sub),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: widget.bg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: widget.brd),
      ),
      child: Column(
        children: [
          _field('memory_limit', _memoryCtrl),
          Divider(height: 24, color: widget.brd),
          _field('upload_max_filesize', _uploadCtrl),
          Divider(height: 24, color: widget.brd),
          _field('post_max_size', _postCtrl),
          Divider(height: 24, color: widget.brd),
          _field('max_execution_time', _execCtrl),
          Divider(height: 24, color: widget.brd),
          _field('max_input_vars', _inputVarsCtrl),
          const SizedBox(height: 16),
          Align(
            alignment: Alignment.centerRight,
            child: ElevatedButton.icon(
              onPressed: _saving ? null : _save,
              icon: _saving
                  ? const SizedBox(
                      width: 14,
                      height: 14,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(Icons.save_outlined, size: 18),
              label: Text(_saving ? 'Saving...' : 'Save PHP Settings'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _field(String label, TextEditingController controller) {
    return Row(
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 13,
            color: widget.sub,
            fontWeight: FontWeight.w500,
          ),
        ),
        const Spacer(),
        SizedBox(
          width: 180,
          child: TextField(
            controller: controller,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 13, color: widget.txt),
            decoration: InputDecoration(
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 10,
                vertical: 8,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
