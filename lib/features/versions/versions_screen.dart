import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/branding/brand_catalog.dart';
import '../../core/theme/app_colors.dart';
import '../../core/services/version_manager.dart';
import '../../shared/brand_icon.dart';

class VersionsScreen extends StatelessWidget {
  const VersionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final vm = context.watch<VersionManager>();
    final txt = isDark ? AppColors.darkText : AppColors.lightText;
    final sub = isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;
    final accent = isDark ? AppColors.accent : AppColors.accentIndigo;

    return Padding(
      padding: const EdgeInsets.all(28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Text('Version Manager', style: TextStyle(fontSize: 26, fontWeight: FontWeight.w700, color: txt)),
            const Spacer(),
            OutlinedButton.icon(
              onPressed: vm.isScanning ? null : () => vm.scanInstalled(),
              icon: vm.isScanning
                  ? SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: accent))
                  : Icon(Icons.refresh, size: 18, color: accent),
              label: Text(vm.isScanning ? 'Scanning...' : 'Rescan', style: TextStyle(color: accent)),
            ),
          ]),
          const SizedBox(height: 4),
          Text('Download, install, and switch software versions', style: TextStyle(fontSize: 14, color: sub)),
          const SizedBox(height: 24),
          Expanded(
            child: ListView(
              children: SoftwareVersions.availableVersions.entries.map((entry) {
                final installed = vm.installed[entry.key];
                final spec = BrandCatalog.software(entry.key);
                return _SoftwareCard(
                  software: entry.key,
                  versions: entry.value,
                  installed: installed,
                  brand: spec,
                  isDark: isDark,
                  vm: vm,
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}

class _SoftwareCard extends StatelessWidget {
  final String software;
  final List<String> versions;
  final VersionInfo? installed;
  final BrandSpec brand;
  final bool isDark;
  final VersionManager vm;

  const _SoftwareCard({
    required this.software,
    required this.versions,
    required this.installed,
    required this.brand,
    required this.isDark,
    required this.vm,
  });

  @override
  Widget build(BuildContext context) {
    final bg = isDark ? AppColors.darkCard : AppColors.lightCard;
    final brd = isDark ? AppColors.darkBorder : AppColors.lightBorder;
    final txt = isDark ? AppColors.darkText : AppColors.lightText;
    final sub = isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: brd),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(children: [
            Container(
              width: 44, height: 44,
              decoration: BoxDecoration(
                color: brand.color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(child: BrandIcon(spec: brand, size: 22)),
            ),
            const SizedBox(width: 14),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(software, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: txt)),
                Row(children: [
                  Container(
                    width: 8, height: 8,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: installed?.isInstalled == true ? AppColors.running : AppColors.stopped,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    installed?.isInstalled == true ? 'v${installed!.version}' : 'Not installed',
                    style: TextStyle(
                      fontSize: 12,
                      color: installed?.isInstalled == true ? AppColors.running : AppColors.stopped,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  if (installed?.path != null) ...[
                    const SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        installed!.path!,
                        style: TextStyle(fontSize: 11, color: sub),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ]),
              ],
            ),
            const Spacer(),
            OutlinedButton.icon(
              onPressed: () {
                final url = SoftwareVersions.downloadPageUrls[software];
                if (url != null) launchUrl(Uri.parse(url));
              },
              icon: Icon(Icons.open_in_new, size: 14, color: sub),
              label: Text('Website', style: TextStyle(fontSize: 12, color: sub)),
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: brd),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              ),
            ),
          ]),
          const SizedBox(height: 16),
          if (installed?.isInstalled == true && !_isListed(software, installed!, versions)) ...[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: AppColors.info.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.info.withValues(alpha: 0.2)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.check_circle_outline, size: 16, color: AppColors.info),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Detected system version v${installed!.version}',
                      style: TextStyle(fontSize: 12, color: sub),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
          ],
          Text('Available Versions', style: TextStyle(fontSize: 12, color: sub, fontWeight: FontWeight.w500)),
          const SizedBox(height: 10),
          // Version chips with install buttons
          ...versions.map((v) => _VersionRow(
            software: software,
            version: v,
            isCurrent: _isCurrent(software, installed, v),
            color: brand.color,
            isDark: isDark,
            vm: vm,
          )),
        ],
      ),
    );
  }

  bool _isCurrent(String software, VersionInfo? installed, String version) {
    if (installed == null) return false;
    if (software == 'Node.js' && version.endsWith('.x')) {
      final major = version.split('.').first;
      return installed.version.startsWith('$major.');
    }
    return installed.version == version;
  }

  bool _isListed(String software, VersionInfo installed, List<String> versions) {
    if (software == 'Node.js') {
      return versions.any((v) {
        if (!v.endsWith('.x')) return installed.version == v;
        final major = v.split('.').first;
        return installed.version.startsWith('$major.');
      });
    }
    return versions.contains(installed.version);
  }
}

class _VersionRow extends StatelessWidget {
  final String software;
  final String version;
  final bool isCurrent;
  final Color color;
  final bool isDark;
  final VersionManager vm;

  const _VersionRow({
    required this.software,
    required this.version,
    required this.isCurrent,
    required this.color,
    required this.isDark,
    required this.vm,
  });

  @override
  Widget build(BuildContext context) {
    final brd = isDark ? AppColors.darkBorder : AppColors.lightBorder;
    final txt = isDark ? AppColors.darkText : AppColors.lightText;
    final sub = isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;
    final progressKey = '$software-$version';
    final progress = vm.installProgress[progressKey];
    final isInstalling = progress != null && progress.status != InstallStatus.done && progress.status != InstallStatus.error;

    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: isCurrent ? color.withValues(alpha: 0.06) : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: isCurrent ? color.withValues(alpha: 0.3) : brd),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            if (isCurrent)
              Container(
                width: 6, height: 6, margin: const EdgeInsets.only(right: 8),
                decoration: BoxDecoration(shape: BoxShape.circle, color: color),
              ),
            Text('v$version', style: TextStyle(
              fontSize: 13,
              color: isCurrent ? color : txt,
              fontWeight: isCurrent ? FontWeight.w600 : FontWeight.w400,
            )),
            if (isCurrent) ...[
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text('ACTIVE', style: TextStyle(fontSize: 9, color: color, fontWeight: FontWeight.w700, letterSpacing: 0.5)),
              ),
            ],
            const Spacer(),
            if (isInstalling)
              SizedBox(
                width: 100,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      progress.message,
                      style: TextStyle(fontSize: 10, color: sub),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    LinearProgressIndicator(
                      value: progress.progress,
                      backgroundColor: brd,
                      valueColor: AlwaysStoppedAnimation(color),
                      minHeight: 3,
                    ),
                  ],
                ),
              )
            else if (progress?.status == InstallStatus.error)
              Tooltip(
                message: progress!.error,
                child: Icon(Icons.error_outline, size: 18, color: AppColors.stopped),
              )
            else if (progress?.status == InstallStatus.done)
              Row(mainAxisSize: MainAxisSize.min, children: [
                Icon(Icons.check_circle, size: 16, color: AppColors.running),
                const SizedBox(width: 4),
                Text('Installed', style: TextStyle(fontSize: 11, color: AppColors.running, fontWeight: FontWeight.w500)),
                const SizedBox(width: 8),
                _SmallButton(
                  label: 'Use',
                  color: color,
                  onTap: () => vm.switchVersion(software, version),
                ),
              ])
            else if (!isCurrent)
              FutureBuilder<bool>(
                future: vm.hasLocalBundle(software, version),
                builder: (context, snapshot) {
                  final hasBundle = snapshot.data == true;
                  return _SmallButton(
                    label: hasBundle ? 'Install' : 'Download',
                    color: color,
                    onTap: () => vm.installVersion(software, version),
                  );
                },
              ),
          ]),
        ],
      ),
    );
  }
}

class _SmallButton extends StatefulWidget {
  final String label;
  final Color color;
  final VoidCallback onTap;
  const _SmallButton({required this.label, required this.color, required this.onTap});
  @override
  State<_SmallButton> createState() => _SmallButtonState();
}

class _SmallButtonState extends State<_SmallButton> {
  bool _hovered = false;
  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
          decoration: BoxDecoration(
            color: _hovered ? widget.color.withValues(alpha: 0.15) : widget.color.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: widget.color.withValues(alpha: 0.3)),
          ),
          child: Text(widget.label, style: TextStyle(fontSize: 11, color: widget.color, fontWeight: FontWeight.w600)),
        ),
      ),
    );
  }
}
