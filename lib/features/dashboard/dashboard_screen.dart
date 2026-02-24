import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/branding/brand_catalog.dart';
import '../../core/theme/app_colors.dart';
import '../../core/services/process_manager.dart';
import '../../core/services/settings_service.dart';
import '../../core/services/adminer_service.dart';
import '../../core/services/version_manager.dart';
import '../../core/services/translation_service.dart';
import '../../shared/service_card.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final processManager = context.watch<ProcessManager>();
    final vm = context.watch<VersionManager>();
    final settings = context.watch<SettingsService>();
    final textColor = isDark ? AppColors.darkText : AppColors.lightText;
    final subtitleColor = isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;
    final accentColor = isDark ? AppColors.accent : AppColors.accentIndigo;

    bool isInstalled(String software) => vm.installed[software]?.isInstalled == true;
    bool isInstalling(String software) {
      final versions = SoftwareVersions.availableVersions[software] ?? [];
      if (versions.isEmpty) return false;
      final key = '$software-${versions.first}';
      final progress = vm.installProgress[key];
      return progress != null && progress.status != InstallStatus.done && progress.status != InstallStatus.error;
    }
    void install(String software) {
      final versions = SoftwareVersions.availableVersions[software] ?? [];
      if (versions.isEmpty) return;
      vm.installVersion(software, versions.first);
    }

    final serviceMap = <String, String>{
      'apache': 'Apache',
      'mysql': 'MySQL',
      'php': 'PHP',
      'python': 'Python',
      'redis': 'Redis',
      'nodejs': 'Node.js',
      'postgres': 'PostgreSQL',
      'memcached': 'Memcached',
      'mailhog': 'Mailhog',
      'smtp': 'SMTP',
      'websocket': 'WebSocket',
    };

    return SingleChildScrollView(
      padding: const EdgeInsets.all(28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    context.tr('dashboard'),
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.w700,
                      color: textColor,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    context.tr('configure_env'),
                    style: TextStyle(fontSize: 14, color: subtitleColor),
                  ),
                ],
              ),
              const Spacer(),
              // Quick actions
              _QuickActionButton(
                label: processManager.anyRunning ? context.tr('stop_all') : context.tr('start_all'),
                icon: processManager.anyRunning ? Icons.stop_circle_outlined : Icons.play_circle_outlined,
                color: processManager.anyRunning ? AppColors.stopped : AppColors.running,
                onTap: () {
                  if (processManager.anyRunning) {
                    processManager.stopAll();
                  } else {
                    for (final entry in serviceMap.entries) {
                      if (isInstalled(entry.value)) {
                        processManager.startService(entry.key);
                      }
                    }
                  }
                },
              ),
            ],
          ),

          const SizedBox(height: 28),

          // Stats row
          Row(
            children: [
              _StatCard(
                title: 'Services Running',
                value: '${processManager.runningCount}/${processManager.services.length}',
                icon: Icons.dns_outlined,
                color: AppColors.running,
                isDark: isDark,
              ),
              const SizedBox(width: 16),
              _StatCard(
                title: 'Environment',
                value: 'Ready',
                icon: Icons.check_circle_outlined,
                color: accentColor,
                isDark: isDark,
              ),
              const SizedBox(width: 16),
              _StatCard(
                title: 'Status',
                value: processManager.anyRunning ? 'Active' : 'Idle',
                icon: Icons.monitor_heart_outlined,
                color: processManager.anyRunning ? AppColors.warning : AppColors.info,
                isDark: isDark,
              ),
            ],
          ),

          const SizedBox(height: 28),

          // Services section
          Text(
            context.tr('services'),
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: textColor,
            ),
          ),
          const SizedBox(height: 16),

          // Service cards grid
          LayoutBuilder(
            builder: (context, constraints) {
              final crossAxisCount = constraints.maxWidth > 900 ? 3 : constraints.maxWidth > 600 ? 2 : 1;
              return GridView.count(
                crossAxisCount: crossAxisCount,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 2.2,
                children: [
                  ServiceCard(
                    title: 'Apache',
                    subtitle: 'HTTP Server',
                    brand: BrandCatalog.service('apache'),
                    brandColor: AppColors.apache,
                    status: processManager.getService('apache')?.status ?? ServiceStatus.stopped,
                    version: processManager.getService('apache')?.version,
                    onToggle: () => _toggleService(processManager, 'apache'),
                    enabled: isInstalled('Apache'),
                    disabledReason: 'Install Apache',
                    onInstall: () => install('Apache'),
                    isInstalling: isInstalling('Apache'),
                  ),
                  ServiceCard(
                    title: 'MySQL',
                    subtitle: 'Database Server',
                    brand: BrandCatalog.service('mysql'),
                    brandColor: AppColors.mysql,
                    status: processManager.getService('mysql')?.status ?? ServiceStatus.stopped,
                    version: processManager.getService('mysql')?.version,
                    onToggle: () => _toggleService(processManager, 'mysql'),
                    enabled: isInstalled('MySQL'),
                    disabledReason: 'Install MySQL',
                    onInstall: () => install('MySQL'),
                    isInstalling: isInstalling('MySQL'),
                  ),
                  ServiceCard(
                    title: 'PHP',
                    subtitle: 'Runtime',
                    brand: BrandCatalog.service('php'),
                    brandColor: AppColors.php,
                    status: processManager.getService('php')?.status ?? ServiceStatus.stopped,
                    version: processManager.getService('php')?.version,
                    onToggle: () => _toggleService(processManager, 'php'),
                    enabled: isInstalled('PHP'),
                    disabledReason: 'Install PHP',
                    onInstall: () => install('PHP'),
                    isInstalling: isInstalling('PHP'),
                  ),
                  ServiceCard(
                    title: 'Python',
                    subtitle: 'Runtime',
                    brand: BrandCatalog.service('python'),
                    brandColor: AppColors.python,
                    status: processManager.getService('python')?.status ?? ServiceStatus.stopped,
                    version: processManager.getService('python')?.version,
                    onToggle: () => _toggleService(processManager, 'python'),
                    enabled: isInstalled('Python'),
                    disabledReason: 'Install Python',
                    onInstall: () => install('Python'),
                    isInstalling: isInstalling('Python'),
                  ),
                  ServiceCard(
                    title: 'Redis',
                    subtitle: 'Cache Server',
                    brand: BrandCatalog.service('redis'),
                    brandColor: AppColors.redis,
                    status: processManager.getService('redis')?.status ?? ServiceStatus.stopped,
                    version: processManager.getService('redis')?.version,
                    onToggle: () => _toggleService(processManager, 'redis'),
                    enabled: isInstalled('Redis'),
                    disabledReason: 'Install Redis',
                    onInstall: () => install('Redis'),
                    isInstalling: isInstalling('Redis'),
                  ),
                  ServiceCard(
                    title: 'Node.js',
                    subtitle: 'JS Runtime',
                    brand: BrandCatalog.service('nodejs'),
                    brandColor: AppColors.nodejs,
                    status: processManager.getService('nodejs')?.status ?? ServiceStatus.stopped,
                    version: processManager.getService('nodejs')?.version,
                    onToggle: () => _toggleService(processManager, 'nodejs'),
                    enabled: isInstalled('Node.js'),
                    disabledReason: 'Install Node.js',
                    onInstall: () => install('Node.js'),
                    isInstalling: isInstalling('Node.js'),
                  ),
                  ServiceCard(
                    title: 'PostgreSQL',
                    subtitle: 'Database Server',
                    brand: BrandCatalog.service('postgres'),
                    brandColor: const Color(0xFF336791), // Postgres Blue
                    status: processManager.getService('postgres')?.status ?? ServiceStatus.stopped,
                    version: processManager.getService('postgres')?.version,
                    onToggle: () => _toggleService(processManager, 'postgres'),
                    enabled: isInstalled('PostgreSQL'),
                    disabledReason: 'Install PostgreSQL',
                    onInstall: () => install('PostgreSQL'),
                    isInstalling: isInstalling('PostgreSQL'),
                  ),
                  ServiceCard(
                    title: 'Memcached',
                    subtitle: 'Cache Server',
                    brand: BrandCatalog.service('memcached'),
                    brandColor: const Color(0xFF51B24B), // Memcached Green
                    status: processManager.getService('memcached')?.status ?? ServiceStatus.stopped,
                    version: processManager.getService('memcached')?.version,
                    onToggle: () => _toggleService(processManager, 'memcached'),
                    enabled: isInstalled('Memcached'),
                    disabledReason: 'Install Memcached',
                    onInstall: () => install('Memcached'),
                    isInstalling: isInstalling('Memcached'),
                  ),
                  ServiceCard(
                    title: 'Mailhog',
                    subtitle: 'Local SMTP',
                    brand: BrandCatalog.service('mailhog'),
                    brandColor: const Color(0xFFE83D31), // Mailhog Red
                    status: processManager.getService('mailhog')?.status ?? ServiceStatus.stopped,
                    version: processManager.getService('mailhog')?.version,
                    onToggle: () => _toggleService(processManager, 'mailhog'),
                    enabled: isInstalled('Mailhog'),
                    disabledReason: 'Install Mailhog',
                    onInstall: () => install('Mailhog'),
                    isInstalling: isInstalling('Mailhog'),
                  ),
                  ServiceCard(
                    title: 'SMTP',
                    subtitle: 'Mailpit Server',
                    brand: BrandCatalog.service('smtp'),
                    brandColor: AppColors.smtp,
                    status: processManager.getService('smtp')?.status ?? ServiceStatus.stopped,
                    version: processManager.getService('smtp')?.version,
                    onToggle: () => _toggleService(processManager, 'smtp'),
                    enabled: isInstalled('SMTP'),
                    disabledReason: 'Install SMTP',
                    onInstall: () => install('SMTP'),
                    isInstalling: isInstalling('SMTP'),
                  ),
                  ServiceCard(
                    title: 'WebSocket',
                    subtitle: 'WebSocket Server',
                    brand: BrandCatalog.service('websocket'),
                    brandColor: AppColors.websocket,
                    status: processManager.getService('websocket')?.status ?? ServiceStatus.stopped,
                    version: processManager.getService('websocket')?.version,
                    onToggle: () => _toggleService(processManager, 'websocket'),
                    enabled: isInstalled('WebSocket'),
                    disabledReason: 'Install WebSocket',
                    onInstall: () => install('WebSocket'),
                    isInstalling: isInstalling('WebSocket'),
                  ),
                ],
              );
            },
          ),

          const SizedBox(height: 28),

          // Quick links
          Text(
            'Quick Links',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: textColor,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _QuickLinkCard(
                title: context.tr('phpmyadmin'),
                subtitle: 'Database Manager',
                icon: Icons.table_chart_outlined,
                color: AppColors.php,
                isDark: isDark,
                onTap: () {
                  final vm = context.read<VersionManager>();
                  final phpPath = vm.installed['PHP']?.path;
                  if (phpPath != null) {
                    context.read<AdminerService>().startAdminerAndOpen(phpPath);
                  }
                },
              ),
              const SizedBox(width: 16),
              _QuickLinkCard(
                title: context.tr('localhost'),
                subtitle: 'http://127.0.0.1:${settings.apachePort}',
                icon: Icons.public_outlined,
                color: AppColors.info,
                isDark: isDark,
                onTap: () {
                  launchUrl(Uri.parse('http://127.0.0.1:${settings.apachePort}'));
                },
              ),
              const SizedBox(width: 16),
              _QuickLinkCard(
                title: context.tr('terminal'),
                subtitle: 'Open shell',
                icon: Icons.terminal_outlined,
                color: AppColors.running,
                isDark: isDark,
                onTap: () {},
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _toggleService(ProcessManager pm, String key) {
    final service = pm.getService(key);
    if (service == null) return;
    if (service.status == ServiceStatus.running) {
      pm.stopService(key);
    } else {
      pm.startService(key);
    }
  }
}

// ─── Stat Card Widget ───
class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;
  final bool isDark;

  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final cardBg = isDark ? AppColors.darkCard : AppColors.lightCard;
    final borderColor = isDark ? AppColors.darkBorder : AppColors.lightBorder;
    final textColor = isDark ? AppColors.darkText : AppColors.lightText;
    final subtitleColor = isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;

    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: cardBg,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: borderColor),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(width: 14),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(value, style: TextStyle(
                  fontSize: 18, fontWeight: FontWeight.w700, color: textColor,
                )),
                Text(title, style: TextStyle(fontSize: 12, color: subtitleColor)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Quick Action Button ───
class _QuickActionButton extends StatefulWidget {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _QuickActionButton({
    required this.label,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  State<_QuickActionButton> createState() => _QuickActionButtonState();
}

class _QuickActionButtonState extends State<_QuickActionButton> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          decoration: BoxDecoration(
            color: _isHovered ? widget.color.withValues(alpha: 0.15) : widget.color.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: widget.color.withValues(alpha: 0.3)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(widget.icon, color: widget.color, size: 20),
              const SizedBox(width: 8),
              Text(widget.label, style: TextStyle(
                color: widget.color, fontSize: 14, fontWeight: FontWeight.w600,
              )),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Quick Link Card ───
class _QuickLinkCard extends StatefulWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final bool isDark;
  final VoidCallback onTap;

  const _QuickLinkCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.isDark,
    required this.onTap,
  });

  @override
  State<_QuickLinkCard> createState() => _QuickLinkCardState();
}

class _QuickLinkCardState extends State<_QuickLinkCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final cardBg = widget.isDark ? AppColors.darkCard : AppColors.lightCard;
    final borderColor = widget.isDark ? AppColors.darkBorder : AppColors.lightBorder;
    final textColor = widget.isDark ? AppColors.darkText : AppColors.lightText;
    final subtitleColor = widget.isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;

    return Expanded(
      child: MouseRegion(
        onEnter: (_) => setState(() => _isHovered = true),
        onExit: (_) => setState(() => _isHovered = false),
        child: GestureDetector(
          onTap: widget.onTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: cardBg,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: _isHovered ? widget.color.withValues(alpha: 0.5) : borderColor,
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: widget.color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(widget.icon, color: widget.color, size: 20),
                ),
                const SizedBox(width: 14),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(widget.title, style: TextStyle(
                      fontSize: 14, fontWeight: FontWeight.w600, color: textColor,
                    )),
                    Text(widget.subtitle, style: TextStyle(fontSize: 12, color: subtitleColor)),
                  ],
                ),
                const Spacer(),
                Icon(Icons.arrow_forward_ios, size: 14, color: subtitleColor),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
