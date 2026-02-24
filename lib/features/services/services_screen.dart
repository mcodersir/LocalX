import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/services/process_manager.dart';
import '../../core/services/version_manager.dart';
import '../../core/services/adminer_service.dart';
import '../../core/services/translation_service.dart';
import 'php_extensions_dialog.dart';

class ServicesScreen extends StatefulWidget {
  const ServicesScreen({super.key});
  @override
  State<ServicesScreen> createState() => _ServicesScreenState();
}

class _ServicesScreenState extends State<ServicesScreen> {
  String _selectedService = 'apache';

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final pm = context.watch<ProcessManager>();
    final vm = context.watch<VersionManager>();
    final txt = isDark ? AppColors.darkText : AppColors.lightText;
    final sub = isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;
    final bg = isDark ? AppColors.darkCard : AppColors.lightCard;
    final brd = isDark ? AppColors.darkBorder : AppColors.lightBorder;
    final accent = isDark ? AppColors.accent : AppColors.accentIndigo;
    final svc = pm.getService(_selectedService);

    bool isInstalled(String software) {
      return vm.installed[software]?.isInstalled == true;
    }

    String softwareForKey(String key) {
      switch (key) {
        case 'apache': return 'Apache';
        case 'mysql': return 'MySQL';
        case 'php': return 'PHP';
        case 'python': return 'Python';
        case 'redis': return 'Redis';
        case 'nodejs': return 'Node.js';
        case 'postgres': return 'PostgreSQL';
        case 'memcached': return 'Memcached';
        case 'mailhog': return 'Mailhog';
        case 'smtp': return 'SMTP';
        case 'websocket': return 'WebSocket';
        default: return '';
      }
    }

    void installForKey(String key) {
      final sw = softwareForKey(key);
      final versions = SoftwareVersions.availableVersions[sw] ?? [];
      if (versions.isEmpty) return;
      vm.installVersion(sw, versions.first);
    }

    final selectedSoftware = softwareForKey(_selectedService);
    final canStartSelected = svc != null && isInstalled(selectedSoftware);

    return Padding(
      padding: const EdgeInsets.all(28),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Text('Services', style: TextStyle(fontSize: 26, fontWeight: FontWeight.w700, color: txt)),
          const Spacer(),
          Text('${pm.runningCount} running', style: TextStyle(fontSize: 14, color: AppColors.running, fontWeight: FontWeight.w500)),
        ]),
        const SizedBox(height: 24),
        Expanded(child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          SizedBox(width: 200, child: Column(
            children: pm.services.entries.map((e) {
              final sel = _selectedService == e.key;
              final run = e.value.status == ServiceStatus.running;
              return _svcItem(e.value.name, sel, run, isDark, accent, txt, () => setState(() => _selectedService = e.key));
            }).toList(),
          )),
          const SizedBox(width: 24),
          Expanded(child: svc == null ? const SizedBox() : Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(14), border: Border.all(color: brd)),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                Text(svc.name, style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: txt)),
                const SizedBox(width: 12),
                _badge(svc.status),
                const Spacer(),
                if (_selectedService == 'mysql' || _selectedService == 'postgres') ...[
                  ElevatedButton.icon(
                    onPressed: () {
                      final vm = context.read<VersionManager>();
                      final phpPath = vm.installed['PHP']?.path;
                      if (phpPath != null) {
                        context.read<AdminerService>().startAdminerAndOpen(phpPath);
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('PHP is required to run Adminer.')));
                      }
                    },
                    icon: context.watch<AdminerService>().isDownloading 
                        ? SizedBox(width: 14, height: 14, child: CircularProgressIndicator(strokeWidth: 2, color: txt)) 
                        : const Icon(Icons.table_chart_outlined, size: 18),
                    label: Text(context.watch<AdminerService>().isDownloading ? 'Downloading...' : 'Open Adminer'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isDark ? AppColors.darkSurface : AppColors.lightSurface,
                      foregroundColor: txt,
                      elevation: 0,
                      side: BorderSide(color: brd),
                    ),
                  ),
                  const SizedBox(width: 12),
                ],
                if (_selectedService == 'php') ...[
                  ElevatedButton.icon(
                    onPressed: () {
                      final vm = context.read<VersionManager>();
                      final phpPath = vm.installed['PHP']?.path;
                      // Fallback to checking process manager logs or something if not found,
                      // but typically version manager knows the path.
                      if (phpPath != null) {
                        showDialog(context: context, builder: (c) => PhpExtensionsDialog(phpPath: phpPath));
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('PHP path not found in Version Manager.')));
                      }
                    },
                    icon: const Icon(Icons.extension_outlined, size: 18),
                    label: const Text('Extensions'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isDark ? AppColors.darkSurface : AppColors.lightSurface,
                      foregroundColor: txt,
                      elevation: 0,
                      side: BorderSide(color: brd),
                    ),
                  ),
                  const SizedBox(width: 12),
                ],
                if (!canStartSelected) ...[
                  ElevatedButton.icon(
                    onPressed: () => installForKey(_selectedService),
                    icon: const Icon(Icons.system_update_alt_outlined, size: 18),
                    label: const Text('Install'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isDark ? AppColors.darkSurface : AppColors.lightSurface,
                      foregroundColor: txt,
                      elevation: 0,
                      side: BorderSide(color: brd),
                    ),
                  ),
                  const SizedBox(width: 12),
                ],
                ElevatedButton.icon(
                  onPressed: canStartSelected
                      ? () => svc.status == ServiceStatus.running ? pm.stopService(_selectedService) : pm.startService(_selectedService)
                      : null,
                  icon: Icon(svc.status == ServiceStatus.running ? Icons.stop : Icons.play_arrow, size: 18),
                  label: Text(svc.status == ServiceStatus.running ? 'Stop' : 'Start'),
                  style: ElevatedButton.styleFrom(backgroundColor: svc.status == ServiceStatus.running ? AppColors.stopped : AppColors.running),
                ),
              ]),
              const SizedBox(height: 20),
              Row(children: [
                _tile('Version', svc.version ?? 'N/A', isDark),
                const SizedBox(width: 12),
                _tile('Port', '${svc.port}', isDark),
                const SizedBox(width: 12),
                _tile('PID', svc.pid?.toString() ?? '-', isDark),
                const SizedBox(width: 12),
                _tile(
                  context.tr('runtime'),
                  svc.runtimeMode == null
                      ? '-'
                      : (svc.isDockerFallback ? context.tr('docker_fallback') : context.tr('native')),
                  isDark,
                ),
              ]),
              const SizedBox(height: 20),
              Text('Logs', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: txt)),
              const SizedBox(height: 10),
              Expanded(child: Container(
                width: double.infinity, padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(color: isDark ? AppColors.darkBackground : AppColors.lightBackground, borderRadius: BorderRadius.circular(10), border: Border.all(color: brd)),
                child: svc.logs.isEmpty
                    ? Center(child: Text('No logs yet', style: TextStyle(fontSize: 13, color: sub)))
                    : ListView.builder(itemCount: svc.logs.length, itemBuilder: (c, i) => Padding(padding: const EdgeInsets.only(bottom: 4), child: Text(svc.logs[i], style: TextStyle(fontSize: 12, fontFamily: 'Consolas', color: sub)))),
              )),
            ]),
          )),
        ])),
      ]),
    );
  }

  Widget _svcItem(String name, bool sel, bool run, bool dk, Color accent, Color txt, VoidCallback onTap) {
    return Padding(padding: const EdgeInsets.only(bottom: 4), child: GestureDetector(onTap: onTap, child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(color: sel ? accent.withValues(alpha: 0.1) : Colors.transparent, borderRadius: BorderRadius.circular(10), border: sel ? Border.all(color: accent.withValues(alpha: 0.3)) : null),
      child: Row(children: [
        Container(width: 8, height: 8, decoration: BoxDecoration(shape: BoxShape.circle, color: run ? AppColors.running : AppColors.darkTextMuted)),
        const SizedBox(width: 12),
        Text(name, style: TextStyle(fontSize: 14, fontWeight: sel ? FontWeight.w600 : FontWeight.w400, color: sel ? accent : txt)),
      ]),
    )));
  }

  Widget _badge(ServiceStatus s) {
    final c = s == ServiceStatus.running ? AppColors.running : s == ServiceStatus.stopped ? AppColors.darkTextMuted : AppColors.warning;
    final l = s == ServiceStatus.running ? 'Running' : s == ServiceStatus.stopped ? 'Stopped' : 'Busy';
    return Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4), decoration: BoxDecoration(color: c.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(20), border: Border.all(color: c.withValues(alpha: 0.3))),
      child: Row(mainAxisSize: MainAxisSize.min, children: [Container(width: 6, height: 6, decoration: BoxDecoration(shape: BoxShape.circle, color: c)), const SizedBox(width: 6), Text(l, style: TextStyle(fontSize: 11, color: c, fontWeight: FontWeight.w500))]));
  }

  Widget _tile(String label, String value, bool dk) {
    final brd = dk ? AppColors.darkBorder : AppColors.lightBorder;
    final txt = dk ? AppColors.darkText : AppColors.lightText;
    final sub = dk ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;
    return Expanded(child: Container(padding: const EdgeInsets.all(14), decoration: BoxDecoration(borderRadius: BorderRadius.circular(10), border: Border.all(color: brd)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(label, style: TextStyle(fontSize: 11, color: sub)), const SizedBox(height: 4), Text(value, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: txt))])));
  }
}
