import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:file_picker/file_picker.dart';
import '../../core/branding/brand_catalog.dart';
import '../../core/theme/app_colors.dart';
import '../../core/services/project_service.dart';
import '../../core/services/translation_service.dart';
import '../../core/services/template_manager.dart';
import '../../core/services/process_manager.dart';
import '../../shared/brand_icon.dart';

class WizardScreen extends StatefulWidget {
  const WizardScreen({super.key});
  @override
  State<WizardScreen> createState() => _WizardScreenState();
}

class _WizardScreenState extends State<WizardScreen> {
  int _step = 0;
  ProjectFramework? _framework;
  String _projectName = '';
  String _projectPath = '';
  String _templateVersion = '';
  bool _isCreating = false;
  final List<String> _logs = [];
  final ScrollController _scrollController = ScrollController();

  final _primaryFrameworks = [
    _FW('Laravel', 'PHP Framework', ProjectFramework.laravel, supportsVersion: true, templateType: TemplateType.laravel),
    _FW('React', 'UI Library', ProjectFramework.react, supportsVersion: true, templateType: TemplateType.react),
    _FW('Vue.js', 'Progressive Framework', ProjectFramework.vue, supportsVersion: true, templateType: TemplateType.vue),
    _FW('Next.js', 'React Framework', ProjectFramework.nextjs, supportsVersion: true, templateType: TemplateType.nextjs),
    _FW('Svelte', 'UI Framework', ProjectFramework.svelte, supportsVersion: true, templateType: TemplateType.svelte),
    _FW('Angular', 'UI Framework', ProjectFramework.angular, supportsVersion: true, templateType: TemplateType.angular),
    _FW('Nuxt', 'Vue Framework', ProjectFramework.nuxt, supportsVersion: true, templateType: TemplateType.nuxt),
    _FW('Node.js', 'JS Runtime', ProjectFramework.nodejs, templateType: TemplateType.nodejs),
    _FW('PHP', 'Plain PHP', ProjectFramework.php, templateType: TemplateType.php),
    _FW('FastAPI', 'Python API', ProjectFramework.fastapi, supportsVersion: true, templateType: TemplateType.fastapi),
    _FW('Django', 'Python Web', ProjectFramework.django, supportsVersion: true, templateType: TemplateType.django),
  ];

  final _cmsFrameworks = [
    _FW('WordPress', 'CMS', ProjectFramework.wordpress, templateType: TemplateType.wordpress),
  ];

  List<_FW> get _frameworks => [..._primaryFrameworks, ..._cmsFrameworks];

  void _appendLog(String log) {
    if (!mounted) return;
    setState(() {
      _logs.add(log);
    });
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
        );
      }
    });
  }

  _FW? _selectedFramework() {
    if (_framework == null) return null;
    for (final fw in _frameworks) {
      if (fw.type == _framework) return fw;
    }
    return null;
  }

  Future<void> _createProject() async {
    if (_projectName.isEmpty || _projectPath.isEmpty || _framework == null) return;
    final projectService = context.read<ProjectService>();
    final createdText = context.tr('project_created');

    setState(() {
      _isCreating = true;
      _logs.clear();
      _logs.add('Starting project creation...\n');
    });

    await _ensureServicesForFramework(_framework!);

    await projectService.createProject(
      name: _projectName,
      path: _projectPath,
      framework: _framework!,
      version: _templateVersion.isNotEmpty ? _templateVersion : null,
      onLog: _appendLog,
    );

    if (mounted) {
      setState(() {
        _isCreating = false;
        _logs.add('\nOK: $createdText');
      });
    }
  }

  Future<void> _ensureServicesForFramework(ProjectFramework fw) async {
    final pm = context.read<ProcessManager>();
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

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final txt = isDark ? AppColors.darkText : AppColors.lightText;
    final sub = isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;
    final accent = isDark ? AppColors.accent : AppColors.accentIndigo;
    final brd = isDark ? AppColors.darkBorder : AppColors.lightBorder;
    final bg = isDark ? AppColors.darkCard : AppColors.lightCard;

    return Padding(
      padding: const EdgeInsets.all(28),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(context.tr('wizard_title'), style: TextStyle(fontSize: 26, fontWeight: FontWeight.w700, color: txt)),
        const SizedBox(height: 4),
        Text(context.tr('wizard_desc'), style: TextStyle(fontSize: 14, color: sub)),
        const SizedBox(height: 28),
        // Progress
        Row(children: List.generate(3, (i) {
          final active = i <= _step;
          final labels = [context.tr('step_1'), context.tr('step_2'), context.tr('step_3')];
          return Expanded(child: Row(children: [
            if (i > 0) Expanded(child: Container(height: 2, color: active ? accent : brd)),
            Container(
              width: 32, height: 32,
              decoration: BoxDecoration(shape: BoxShape.circle, color: active ? accent : Colors.transparent, border: Border.all(color: active ? accent : brd, width: 2)),
              child: Center(child: active && i < _step ? Icon(Icons.check, size: 16, color: isDark ? AppColors.darkBackground : Colors.white) : Text('${i + 1}', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: active ? (isDark ? AppColors.darkBackground : Colors.white) : sub))),
            ),
            const SizedBox(width: 8),
            Text(labels[i], style: TextStyle(fontSize: 13, fontWeight: active ? FontWeight.w600 : FontWeight.w400, color: active ? txt : sub)),
            if (i < 2) const SizedBox(width: 8),
          ]));
        })),
        const SizedBox(height: 32),
        Expanded(child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          child: _step == 0 ? _buildFrameworkStep(isDark, txt, sub, bg, brd, accent)
              : _step == 1 ? _buildDetailsStep(isDark, txt, sub, bg, brd, accent)
              : _buildCreateStep(isDark, txt, sub, bg, brd, accent),
        )),
      ]),
    );
  }

  Widget _buildFrameworkStep(bool dk, Color txt, Color sub, Color bg, Color brd, Color accent) {
    return Column(key: const ValueKey(0), crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(context.tr('step_1'), style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: txt)),
      const SizedBox(height: 16),
      Expanded(
        child: ListView(
          children: [
            Text('Frameworks', style: TextStyle(fontSize: 13, color: sub, fontWeight: FontWeight.w600)),
            const SizedBox(height: 10),
            _frameworkGrid(_primaryFrameworks, txt, sub, bg, brd),
            const SizedBox(height: 18),
            Text('CMS', style: TextStyle(fontSize: 13, color: sub, fontWeight: FontWeight.w600)),
            const SizedBox(height: 10),
            _frameworkGrid(_cmsFrameworks, txt, sub, bg, brd),
          ],
        ),
      ),
    ]);
  }

  Widget _frameworkGrid(List<_FW> list, Color txt, Color sub, Color bg, Color brd) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 280,
        crossAxisSpacing: 14,
        mainAxisSpacing: 14,
        childAspectRatio: 2.2,
      ),
      itemCount: list.length,
      itemBuilder: (context, index) {
        final fw = list[index];
        final sel = _framework == fw.type;
        return GestureDetector(
          onTap: () => setState(() {
            _framework = fw.type;
            _step = 1;
          }),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: bg,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: sel ? fw.brand.color : brd, width: sel ? 2 : 1),
            ),
            child: Row(children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: fw.brand.color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Center(child: BrandIcon(spec: fw.brand, size: 20)),
              ),
              const SizedBox(width: 12),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.center, children: [
                Text(fw.name, style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: txt), overflow: TextOverflow.ellipsis),
                Text(fw.desc, style: TextStyle(fontSize: 11, color: sub), overflow: TextOverflow.ellipsis),
              ])),
              if (fw.templateType != null)
                FutureBuilder<bool>(
                  future: TemplateManager.hasTemplate(fw.templateType!),
                  builder: (context, snapshot) {
                    if (snapshot.data != true) return const SizedBox();
                    return Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                      decoration: BoxDecoration(
                        color: fw.brand.color.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: fw.brand.color.withValues(alpha: 0.25)),
                      ),
                      child: Row(mainAxisSize: MainAxisSize.min, children: [
                        Icon(Icons.offline_bolt_outlined, size: 12, color: fw.brand.color),
                        const SizedBox(width: 4),
                        Text('Offline', style: TextStyle(fontSize: 10, color: fw.brand.color, fontWeight: FontWeight.w600)),
                      ]),
                    );
                  },
                ),
            ]),
          ),
        );
      },
    );
  }

  Widget _buildDetailsStep(bool dk, Color txt, Color sub, Color bg, Color brd, Color accent) {
    final selected = _selectedFramework();
    return Column(key: const ValueKey(1), crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(context.tr('step_2'), style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: txt)),
      const SizedBox(height: 16),
      Expanded(
        child: Scrollbar(
          thumbVisibility: true,
          child: SingleChildScrollView(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              TextField(
                onChanged: (v) => _projectName = v,
                decoration: InputDecoration(labelText: context.tr('project_name'), hintText: 'my-awesome-app', prefixIcon: const Icon(Icons.edit_outlined, size: 20)),
              ),
              const SizedBox(height: 16),
              Row(children: [
                Expanded(child: TextField(
                  controller: TextEditingController(text: _projectPath),
                  readOnly: true,
                  decoration: InputDecoration(labelText: context.tr('project_location'), hintText: 'Select folder...', prefixIcon: const Icon(Icons.folder_outlined, size: 20)),
                )),
                const SizedBox(width: 12),
                Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: OutlinedButton(onPressed: () async {
                    final dir = await FilePicker.platform.getDirectoryPath(dialogTitle: 'Select Project Location');
                    if (dir != null) setState(() => _projectPath = dir);
                  }, child: Text(context.tr('browse'))),
                ),
              ]),
              const SizedBox(height: 16),
              if (selected != null && selected.supportsVersion)
                TextField(
                  onChanged: (v) => _templateVersion = v.trim(),
                  decoration: const InputDecoration(
                    labelText: 'Template Version (Optional)',
                    hintText: 'e.g. 11.0.0, 18.2.0',
                    prefixIcon: Icon(Icons.numbers_outlined, size: 20),
                  ),
                ),
              const SizedBox(height: 16),
            ]),
          ),
        ),
      ),
      const SizedBox(height: 12),
      Row(children: [
        OutlinedButton(onPressed: () => setState(() => _step = 0), child: Text(context.tr('back'))),
        const Spacer(),
        ElevatedButton(onPressed: _projectName.isNotEmpty && _projectPath.isNotEmpty ? () => setState(() => _step = 2) : null, child: Text(context.tr('next'))),
      ]),
    ]);
  }

  Widget _buildCreateStep(bool dk, Color txt, Color sub, Color bg, Color brd, Color accent) {
    final fw = _selectedFramework() ?? _frameworks.first;
    return Column(key: const ValueKey(2), crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(context.tr('step_3'), style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: txt)),
      const SizedBox(height: 16),
      
      if (_logs.isEmpty && !_isCreating)
        Container(padding: const EdgeInsets.all(20), decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(14), border: Border.all(color: brd)),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            _row('Framework', fw.name, fw.brand.color, txt, sub),
            Divider(height: 24, color: brd),
            _row(context.tr('project_name'), _projectName, accent, txt, sub),
            Divider(height: 24, color: brd),
            _row(context.tr('project_location'), '$_projectPath/$_projectName', accent, txt, sub),
          ]),
        )
      else
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: Colors.black87, borderRadius: BorderRadius.circular(12), border: Border.all(color: brd)),
            child: ListView.builder(
              controller: _scrollController,
              itemCount: _logs.length,
              itemBuilder: (ctx, i) => Text(_logs[i], style: const TextStyle(fontFamily: 'Consolas', fontSize: 13, color: Colors.greenAccent)),
            ),
          ),
        ),

      const SizedBox(height: 24),
      Row(children: [
        if (!_isCreating && _logs.isEmpty)
          OutlinedButton(onPressed: () => setState(() => _step = 1), child: Text(context.tr('back')))
        else if (!_isCreating && _logs.isNotEmpty)
          OutlinedButton(onPressed: () => setState(() { _step = 0; _framework = null; _projectName = ''; _projectPath = ''; _templateVersion = ''; _logs.clear(); }), child: Text(context.tr('dashboard'))), // go to start
        
        const Spacer(),
        
        if (_logs.isEmpty)
          ElevatedButton.icon(
            onPressed: _createProject,
            icon: const Icon(Icons.rocket_launch_outlined, size: 18),
            label: Text(context.tr('create')),
          )
        else if (_isCreating)
          ElevatedButton.icon(
            onPressed: null,
            icon: const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)),
            label: Text(context.tr('creating')),
          )
      ]),
    ]);
  }

  Widget _row(String l, String v, Color c, Color txt, Color sub) {
    return Row(children: [
      Text(l, style: TextStyle(fontSize: 13, color: sub, fontWeight: FontWeight.w500)),
      const Spacer(),
      Text(v, style: TextStyle(fontSize: 14, color: txt, fontWeight: FontWeight.w600)),
    ]);
  }
}

class _FW {
  final String name, desc;
  final ProjectFramework type;
  final bool supportsVersion;
  final TemplateType? templateType;
  const _FW(this.name, this.desc, this.type, {this.supportsVersion = false, this.templateType});

  BrandSpec get brand => BrandCatalog.framework(type);
}
