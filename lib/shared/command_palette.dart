import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/services/process_manager.dart';
import '../../core/services/project_service.dart';
import '../../core/services/version_manager.dart';

class CommandPalette extends StatefulWidget {
  final Function(int) onNavigate;
  const CommandPalette({super.key, required this.onNavigate});

  @override
  State<CommandPalette> createState() => _CommandPaletteState();
}

class _CommandPaletteState extends State<CommandPalette> {
  final TextEditingController _searchCtrl = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  String _query = '';

  @override
  void initState() {
    super.initState();
    _focusNode.requestFocus();
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _handleAction(RunnableAction action) {
    Navigator.of(context).pop();
    action.run();
  }

  List<RunnableAction> _getActions(BuildContext context) {
    final pm = context.read<ProcessManager>();
    final proj = context.read<ProjectService>();
    final vm = context.read<VersionManager>();

    List<RunnableAction> actions = [];

    // Navigation Actions
    final routes = [
      {'name': 'Go to Dashboard', 'icon': Icons.dashboard_outlined, 'index': 0},
      {'name': 'Go to Projects', 'icon': Icons.folder_outlined, 'index': 1},
      {'name': 'Go to Services', 'icon': Icons.grid_view_outlined, 'index': 2},
      {'name': 'Go to Create Project', 'icon': Icons.auto_fix_high_outlined, 'index': 3},
      {'name': 'Go to Version Manager', 'icon': Icons.swap_vert_outlined, 'index': 4},
      {'name': 'Go to Settings', 'icon': Icons.settings_outlined, 'index': 5},
    ];

    for (var r in routes) {
      actions.add(RunnableAction(
        title: r['name'] as String,
        icon: r['icon'] as IconData,
        group: 'Navigation',
        run: () => widget.onNavigate(r['index'] as int),
      ));
    }

    // Service Actions
    for (var entry in pm.services.entries) {
      final s = entry.value;
      final sw = _serviceToSoftware(entry.key);
      final installed = sw.isEmpty ? false : vm.installed[sw]?.isInstalled == true;
      if (!installed) {
        actions.add(RunnableAction(
          title: 'Install ${s.name}',
          icon: Icons.system_update_alt_outlined,
          group: 'Services',
          color: AppColors.warning,
          run: () {
            final versions = SoftwareVersions.availableVersions[sw] ?? [];
            if (versions.isNotEmpty) {
              vm.installVersion(sw, versions.first);
            }
          },
        ));
        continue;
      }

      if (s.status == ServiceStatus.running) {
        actions.add(RunnableAction(
          title: 'Stop ${s.name}',
          icon: Icons.stop_circle_outlined,
          group: 'Services',
          color: AppColors.stopped,
          run: () => pm.stopService(entry.key),
        ));
      } else {
        actions.add(RunnableAction(
          title: 'Start ${s.name}',
          icon: Icons.play_circle_fill_outlined,
          group: 'Services',
          color: AppColors.running,
          run: () => pm.startService(entry.key),
        ));
      }
    }

    // Project Actions
    for (var p in proj.projects) {
      actions.add(RunnableAction(
        title: 'Open ${p.name} in VS Code',
        icon: Icons.code,
        group: 'Projects',
        color: const Color(0xFF007ACC),
        run: () {
          if (Platform.isWindows) {
            Process.run('code', ['.', '--wait'], workingDirectory: p.path);
          }
        },
      ));
    }

    // Filter based on query
    if (_query.isNotEmpty) {
      final q = _query.toLowerCase();
      return actions.where((a) => a.title.toLowerCase().contains(q) || a.group.toLowerCase().contains(q)).toList();
    }

    return actions;
  }

  String _serviceToSoftware(String key) {
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

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? AppColors.darkBackground : AppColors.lightBackground;
    final brd = isDark ? AppColors.darkBorder : AppColors.lightBorder;
    final txt = isDark ? AppColors.darkText : AppColors.lightText;
    final sub = isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;

    final actions = _getActions(context);

    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      insetPadding: const EdgeInsets.symmetric(horizontal: 40, vertical: 24),
      child: Align(
        alignment: Alignment.topCenter,
        child: Container(
          width: 600,
          constraints: const BoxConstraints(maxHeight: 500),
          margin: const EdgeInsets.only(top: 80),
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: brd, width: 1.5),
            boxShadow: [
              BoxShadow(color: Colors.black.withValues(alpha: 0.3), blurRadius: 40, spreadRadius: 10),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Search Input
              Padding(
                padding: const EdgeInsets.all(16),
                child: TextField(
                  controller: _searchCtrl,
                  focusNode: _focusNode,
                  onChanged: (v) => setState(() => _query = v),
                  style: TextStyle(fontSize: 18, color: txt),
                  decoration: InputDecoration(
                    hintText: 'Search commands, projects, or settings...',
                    hintStyle: TextStyle(color: sub, fontSize: 18),
                    prefixIcon: Icon(Icons.search, color: sub, size: 24),
                    border: InputBorder.none,
                    isDense: true,
                  ),
                ),
              ),
              Divider(height: 1, color: brd),
              
              // Results List
              if (actions.isEmpty)
                Padding(
                  padding: const EdgeInsets.all(40),
                  child: Center(
                    child: Text('No results found for "$_query"', style: TextStyle(color: sub)),
                  ),
                )
              else
                Flexible(
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: actions.length,
                    itemBuilder: (ctx, i) {
                      final a = actions[i];
                      final showHeader = i == 0 || actions[i - 1].group != a.group;
                      
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (showHeader)
                            Padding(
                              padding: const EdgeInsets.only(left: 16, top: 12, bottom: 4),
                              child: Text(
                                a.group.toUpperCase(),
                                style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: sub, letterSpacing: 0.5),
                              ),
                            ),
                          InkWell(
                            onTap: () => _handleAction(a),
                            hoverColor: (isDark ? Colors.white : Colors.black).withValues(alpha: 0.05),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                              child: Row(
                                children: [
                                  Icon(a.icon, size: 18, color: a.color ?? txt),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(a.title, style: TextStyle(color: txt, fontSize: 14)),
                                  ),
                                  Icon(Icons.keyboard_return, size: 14, color: sub.withValues(alpha: 0.5)),
                                ],
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class RunnableAction {
  final String title;
  final IconData icon;
  final String group;
  final VoidCallback run;
  final Color? color;

  RunnableAction({
    required this.title,
    required this.icon,
    required this.group,
    required this.run,
    this.color,
  });
}
