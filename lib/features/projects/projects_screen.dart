import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:file_picker/file_picker.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/branding/brand_catalog.dart';
import '../../core/theme/app_colors.dart';
import '../../core/services/project_service.dart';
import '../../core/services/domain_service.dart';
import '../../core/services/settings_service.dart';
import '../../core/services/translation_service.dart';
import '../../core/services/process_manager.dart';
import '../../shared/brand_icon.dart';
import 'packages_dialog.dart';

int _preferredPortForFramework(ProjectFramework fw, SettingsService settings) {
  switch (fw) {
    case ProjectFramework.laravel:
    case ProjectFramework.php:
    case ProjectFramework.wordpress:
      return settings.apachePort;
    case ProjectFramework.fastapi:
    case ProjectFramework.django:
      return settings.pythonPort;
    default:
      return settings.nodePort;
  }
}

Future<void> _ensureServicesForFramework(ProjectFramework fw, ProcessManager pm) async {
  final required = <String>{};
  switch (fw) {
    case ProjectFramework.laravel:
    case ProjectFramework.php:
    case ProjectFramework.wordpress:
      required.addAll(['apache', 'php', 'mysql']);
      break;
    case ProjectFramework.react:
    case ProjectFramework.vue:
    case ProjectFramework.nextjs:
    case ProjectFramework.svelte:
    case ProjectFramework.angular:
    case ProjectFramework.nuxt:
    case ProjectFramework.nodejs:
      required.add('nodejs');
      break;
    case ProjectFramework.fastapi:
    case ProjectFramework.django:
      required.add('python');
      break;
    case ProjectFramework.unknown:
      break;
  }
  for (final key in required) {
    final svc = pm.getService(key);
    if (svc != null && svc.status != ServiceStatus.running) {
      await pm.startService(key);
    }
  }
}

class ProjectsScreen extends StatelessWidget {
  const ProjectsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final projectService = context.watch<ProjectService>();
    final textColor = isDark ? AppColors.darkText : AppColors.lightText;
    final subtitleColor = isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;

    return Padding(
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
                  Text(context.tr('projects'), style: TextStyle(
                    fontSize: 26, fontWeight: FontWeight.w700, color: textColor, letterSpacing: -0.5,
                  )),
                  const SizedBox(height: 4),
                  Text(
                    '${projectService.projects.length} project${projectService.projects.length != 1 ? 's' : ''}',
                    style: TextStyle(fontSize: 14, color: subtitleColor),
                  ),
                ],
              ),
              const Spacer(),
              ElevatedButton.icon(
                onPressed: () => _addProject(context, projectService),
                icon: const Icon(Icons.add, size: 18),
                label: Text(context.tr('add_project')),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Projects list
          Expanded(
            child: projectService.projects.isEmpty
                ? _EmptyState(
                    isDark: isDark,
                    onAdd: () => _addProject(context, projectService),
                  )
                : ListView.separated(
                    itemCount: projectService.projects.length,
                    separatorBuilder: (a, b) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final project = projectService.projects[index];
                      return _ProjectCard(
                        project: project,
                        isDark: isDark,
                        onRemove: () => projectService.removeProject(index),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Future<void> _addProject(BuildContext context, ProjectService projectService) async {
    String? selectedDirectory = await FilePicker.platform.getDirectoryPath(
      dialogTitle: 'Select Project Folder',
    );
    if (selectedDirectory != null && context.mounted) {
      await projectService.addProject(selectedDirectory);
      // Show custom domain dialog
      if (context.mounted) {
        if (projectService.projects.isNotEmpty) {
          final project = projectService.projects.last;
          final settings = context.read<SettingsService>();
          final port = _preferredPortForFramework(project.framework, settings);
          await _showDomainDialog(context, project, port);
        }
      }
    }
  }

  Future<void> _showDomainDialog(BuildContext context, ProjectInfo project, int port) async {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final suggested = DomainService.suggestDomain(project.name);
    final controller = TextEditingController(text: suggested);
    final accent = isDark ? AppColors.accent : AppColors.accentIndigo;
    final domainService = context.read<DomainService>();
    final projectService = context.read<ProjectService>();

    final result = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Row(children: [
          Icon(Icons.public_outlined, color: accent, size: 22),
          const SizedBox(width: 10),
          Text(context.tr('custom_domain')),
        ]),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${context.tr('set_custom_url')} "${project.name}".',
              style: TextStyle(fontSize: 14, color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary),
            ),
            const SizedBox(height: 6),
            Text(
              context.tr('instead_of_localhost'),
              style: TextStyle(fontSize: 13, color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: controller,
              autofocus: true,
              decoration: InputDecoration(
                labelText: context.tr('domain'),
                hintText: 'e.g. myapp.local, example.com, shop',
                prefixIcon: const Icon(Icons.link, size: 20),
                prefixText: 'http://',
              ),
            ),
            const SizedBox(height: 16),
            // Quick suggestions
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _DomainChip(domain: '${project.name.toLowerCase()}.local', onTap: () => controller.text = '${project.name.toLowerCase()}.local', accent: accent),
                _DomainChip(domain: '${project.name.toLowerCase()}.test', onTap: () => controller.text = '${project.name.toLowerCase()}.test', accent: accent),
                _DomainChip(domain: project.name.toLowerCase(), onTap: () => controller.text = project.name.toLowerCase(), accent: accent),
                _DomainChip(domain: '${project.name.toLowerCase()}.com', onTap: () => controller.text = '${project.name.toLowerCase()}.com', accent: accent),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.warning.withValues(alpha: 0.1),
                border: Border.all(color: AppColors.warning.withValues(alpha: 0.3)),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(Icons.warning_amber_rounded, size: 18, color: AppColors.warning),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      context.tr('hosts_mod_info'),
                      style: TextStyle(fontSize: 12, color: AppColors.warning),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(context.tr('skip')),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(ctx).pop(controller.text.trim()),
            child: Text(context.tr('set_domain')),
          ),
        ],
      ),
    );

    if (result != null && result.isNotEmpty && context.mounted) {
      await domainService.addDomain(result, project.path, port: port);
      project.customDomain = result.replaceAll('http://', '').replaceAll('/', '').trim();
      project.customDomainPort = port;
      await projectService.updateProject(project);
    }
  }
}

class _ProjectCard extends StatefulWidget {
  final ProjectInfo project;
  final bool isDark;
  final VoidCallback onRemove;

  const _ProjectCard({
    required this.project,
    required this.isDark,
    required this.onRemove,
  });

  @override
  State<_ProjectCard> createState() => _ProjectCardState();
}

class _ProjectCardState extends State<_ProjectCard> {
  bool _isHovered = false;

  BrandSpec get _frameworkBrand => BrandCatalog.framework(widget.project.framework);
  Color get _frameworkColor => _frameworkBrand.color;

  @override
  Widget build(BuildContext context) {
    final cardBg = widget.isDark ? AppColors.darkCard : AppColors.lightCard;
    final borderColor = widget.isDark ? AppColors.darkBorder : AppColors.lightBorder;
    final textColor = widget.isDark ? AppColors.darkText : AppColors.lightText;
    final subtitleColor = widget.isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;
    final domain = widget.project.customDomain;
    final domainPort = widget.project.customDomainPort;
    final domainUrl = domain == null ? null : (domainPort != null && domainPort != 80 ? 'http://$domain:$domainPort' : 'http://$domain');

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: cardBg,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: _isHovered ? _frameworkColor.withValues(alpha: 0.5) : borderColor,
            width: _isHovered ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: _frameworkColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: _frameworkColor.withValues(alpha: 0.2)),
              ),
              child: Center(child: BrandIcon(spec: _frameworkBrand, size: 24)),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(widget.project.name, style: TextStyle(
                    fontSize: 15, fontWeight: FontWeight.w600, color: textColor,
                  )),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: _frameworkColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          widget.project.frameworkLabel,
                          style: TextStyle(fontSize: 11, color: _frameworkColor, fontWeight: FontWeight.w500),
                        ),
                      ),
                      if (widget.project.customDomain != null) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.info.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Row(mainAxisSize: MainAxisSize.min, children: [
                            const Icon(Icons.link, size: 10, color: AppColors.info),
                            const SizedBox(width: 4),
                            Text(
                              domainUrl ?? '',
                              style: const TextStyle(fontSize: 11, color: AppColors.info, fontWeight: FontWeight.w500),
                            ),
                          ]),
                        ),
                      ],
                      if (widget.project.isRunning) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.running.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Row(mainAxisSize: MainAxisSize.min, children: [
                            const Icon(Icons.play_circle_filled, size: 10, color: AppColors.running),
                            const SizedBox(width: 4),
                            Text(
                              widget.project.runPort != null ? 'RUNNING :${widget.project.runPort}' : 'RUNNING',
                              style: const TextStyle(fontSize: 11, color: AppColors.running, fontWeight: FontWeight.w500),
                            ),
                          ]),
                        ),
                      ],
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          widget.project.path,
                          style: TextStyle(fontSize: 12, color: subtitleColor),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _ActionIconButton(
                  icon: Icons.code,
                  tooltip: 'Open in VS Code',
                  color: const Color(0xFF007ACC),
                  onTap: () {
                    if (Platform.isWindows) {
                      Process.run('code', ['.', '--wait'], workingDirectory: widget.project.path);
                    } else {
                      Process.run('code', ['.'], workingDirectory: widget.project.path);
                    }
                  },
                ),
                _ActionIconButton(
                  icon: Icons.integration_instructions,
                  tooltip: 'Open in PhpStorm',
                  color: const Color(0xFFD91E76),
                  onTap: () async {
                    if (Platform.isWindows) {
                      try {
                        await Process.run('phpstorm64', ['.'], workingDirectory: widget.project.path);
                      } catch (_) {
                        await Process.run('phpstorm', ['.'], workingDirectory: widget.project.path);
                      }
                    } else {
                      Process.run('phpstorm', ['.'], workingDirectory: widget.project.path);
                    }
                  },
                ),
                _ActionIconButton(
                  icon: Icons.inventory_2_outlined,
                  tooltip: 'Packages',
                  color: widget.isDark ? AppColors.accent : AppColors.accentIndigo,
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (ctx) => PackagesDialog(project: widget.project),
                    );
                  },
                ),
                _ActionIconButton(
                  icon: Icons.terminal_outlined,
                  tooltip: 'Open Terminal',
                  color: subtitleColor,
                  onTap: () {
                    if (Platform.isWindows) {
                      Process.start('cmd', ['/c', 'start', 'cmd', '/K', 'cd /d ${widget.project.path}'], runInShell: true);
                    }
                  },
                ),
                _ActionIconButton(
                  icon: widget.project.isRunning ? Icons.stop_circle_outlined : Icons.play_circle_outline,
                  tooltip: widget.project.isRunning ? 'Stop Project' : 'Run Project',
                  color: widget.project.isRunning ? AppColors.stopped : AppColors.running,
                  onTap: () {
                    final service = context.read<ProjectService>();
                    if (widget.project.isRunning) {
                      service.stopProject(widget.project);
                    } else {
                      final settings = context.read<SettingsService>();
                      final preferredPort = _preferredPortForFramework(widget.project.framework, settings);
                      service.startProject(widget.project, preferredPort: preferredPort);
                    }
                  },
                ),
                _ActionIconButton(
                  icon: Icons.public_outlined,
                  tooltip: domainUrl != null ? 'Open $domainUrl' : 'Open in Browser',
                  color: subtitleColor,
                  onTap: () async {
                    final settings = context.read<SettingsService>();
                    final pm = context.read<ProcessManager>();
                    await _ensureServicesForFramework(widget.project.framework, pm);
                    if (domainUrl != null) {
                      launchUrl(Uri.parse(domainUrl));
                    } else if (widget.project.runPort != null) {
                      launchUrl(Uri.parse('http://127.0.0.1:${widget.project.runPort}'));
                    } else {
                      final port = _preferredPortForFramework(widget.project.framework, settings);
                      launchUrl(Uri.parse('http://127.0.0.1:$port'));
                    }
                  },
                ),
                _ActionIconButton(
                  icon: Icons.delete_outline,
                  tooltip: 'Remove',
                  color: AppColors.stopped,
                  onTap: widget.onRemove,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ActionIconButton extends StatefulWidget {
  final IconData icon;
  final String tooltip;
  final Color color;
  final VoidCallback onTap;

  const _ActionIconButton({
    required this.icon,
    required this.tooltip,
    required this.color,
    required this.onTap,
  });

  @override
  State<_ActionIconButton> createState() => _ActionIconButtonState();
}

class _ActionIconButtonState extends State<_ActionIconButton> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: widget.tooltip,
      child: MouseRegion(
        onEnter: (_) => setState(() => _isHovered = true),
        onExit: (_) => setState(() => _isHovered = false),
        child: GestureDetector(
          onTap: widget.onTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            width: 34,
            height: 34,
            margin: const EdgeInsets.only(left: 4),
            decoration: BoxDecoration(
              color: _isHovered ? widget.color.withValues(alpha: 0.1) : Colors.transparent,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(widget.icon, size: 18, color: widget.color),
          ),
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final bool isDark;
  final VoidCallback onAdd;

  const _EmptyState({required this.isDark, required this.onAdd});

  @override
  Widget build(BuildContext context) {
    final subtitleColor = isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;
    final borderColor = isDark ? AppColors.darkBorder : AppColors.lightBorder;

    return Center(
      child: Container(
        padding: const EdgeInsets.all(48),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: borderColor, style: BorderStyle.solid),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.folder_open_outlined, size: 56, color: subtitleColor.withValues(alpha: 0.5)),
            const SizedBox(height: 16),
            Text('No projects yet', style: TextStyle(
              fontSize: 18, fontWeight: FontWeight.w600, color: subtitleColor,
            )),
            const SizedBox(height: 8),
            Text(
              'Add a project folder or create a new one with the wizard',
              style: TextStyle(fontSize: 13, color: subtitleColor.withValues(alpha: 0.7)),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: onAdd,
              icon: const Icon(Icons.add, size: 18),
              label: const Text('Add Project'),
            ),
          ],
        ),
      ),
    );
  }
}

class _DomainChip extends StatelessWidget {
  final String domain;
  final VoidCallback onTap;
  final Color accent;
  const _DomainChip({required this.domain, required this.onTap, required this.accent});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: accent.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: accent.withValues(alpha: 0.2)),
        ),
        child: Text(domain, style: TextStyle(fontSize: 12, color: accent, fontWeight: FontWeight.w500)),
      ),
    );
  }
}
