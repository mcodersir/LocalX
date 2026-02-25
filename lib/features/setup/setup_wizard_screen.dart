import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:window_manager/window_manager.dart';
import '../../core/branding/brand_catalog.dart';
import '../../core/theme/app_colors.dart';
import '../../core/services/settings_service.dart';
import '../../core/services/port_probe.dart';
import '../../core/services/version_manager.dart';
import '../../shared/brand_icon.dart';

class SetupWizardScreen extends StatefulWidget {
  final VoidCallback onComplete;
  const SetupWizardScreen({super.key, required this.onComplete});
  @override
  State<SetupWizardScreen> createState() => _SetupWizardScreenState();
}

class _SetupWizardScreenState extends State<SetupWizardScreen>
    with TickerProviderStateMixin {
  int _currentStep = 0;
  static const int _stepCount = 5;
  late AnimationController _fadeCtrl;
  late Animation<double> _fadeAnim;
  late PageController _pageCtrl;

  bool _isScanning = false;
  bool _autoInstallStarted = false;

  final List<_ScanItem> _scanItems = [
    _ScanItem('PHP', 'php', ['-v'], BrandCatalog.software('PHP')),
    _ScanItem('Python', 'python', [
      '--version',
    ], BrandCatalog.software('Python')),
    _ScanItem('Node.js', 'node', ['-v'], BrandCatalog.software('Node.js')),
    _ScanItem('MySQL', 'mysql', ['--version'], BrandCatalog.software('MySQL')),
    _ScanItem('Apache', 'httpd', ['-v'], BrandCatalog.software('Apache')),
    _ScanItem('Redis', 'redis-server', ['-v'], BrandCatalog.software('Redis')),
    _ScanItem('PostgreSQL', 'psql', [
      '-V',
    ], BrandCatalog.software('PostgreSQL')),
    _ScanItem('Memcached', 'memcached', [
      '-h',
    ], BrandCatalog.software('Memcached')),
    _ScanItem('Mailhog', 'MailHog', [
      '-version',
    ], BrandCatalog.software('Mailhog')),
    _ScanItem('SMTP', 'mailpit', ['--version'], BrandCatalog.software('SMTP')),
    _ScanItem('WebSocket', 'websocat', [
      '--version',
    ], BrandCatalog.software('WebSocket')),
    _ScanItem(
      'Composer',
      'composer',
      ['-V'],
      const BrandSpec(
        key: 'composer',
        svgAsset: null,
        fallbackIcon: Icons.settings_outlined,
        color: AppColors.laravel,
      ),
    ),
    _ScanItem(
      'npm',
      'npm',
      ['-v'],
      const BrandSpec(
        key: 'npm',
        svgAsset: null,
        fallbackIcon: Icons.inventory_2_outlined,
        color: AppColors.nodejs,
      ),
    ),
  ];

  final List<_InstallTarget> _installTargets = const [
    _InstallTarget('Apache'),
    _InstallTarget('MySQL'),
    _InstallTarget('PHP'),
    _InstallTarget('Python'),
    _InstallTarget('Node.js'),
    _InstallTarget('Redis'),
    _InstallTarget('PostgreSQL'),
    _InstallTarget('Mailhog'),
    _InstallTarget('SMTP'),
    _InstallTarget('WebSocket'),
  ];

  @override
  void initState() {
    super.initState();
    _fadeCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fadeAnim = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeOut));
    _pageCtrl = PageController();
    _fadeCtrl.forward();
    _runScan();
  }

  @override
  void dispose() {
    _fadeCtrl.dispose();
    _pageCtrl.dispose();
    super.dispose();
  }

  void _nextStep() {
    if (_currentStep < _stepCount - 1) {
      setState(() => _currentStep++);
      _pageCtrl.animateToPage(
        _currentStep,
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    } else {
      widget.onComplete();
    }
  }

  void _prevStep() {
    if (_currentStep > 0) {
      setState(() => _currentStep--);
      _pageCtrl.animateToPage(
        _currentStep,
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    }
  }

  Future<void> _runScan() async {
    setState(() {
      _isScanning = true;
      for (final i in _scanItems) {
        i.isInstalled = false;
        i.version = 'Scanning...';
        i.isChecking = true;
      }
    });

    for (final item in _scanItems) {
      try {
        final result = await Process.run(
          item.command,
          item.args,
          runInShell: true,
        );
        final stdout = result.stdout.toString();
        final stderr = result.stderr.toString();
        final output = stdout.isNotEmpty ? stdout : stderr;
        if (result.exitCode == 0) {
          item.version = _extractVersion(item.name, output);
          item.isInstalled = true;
        } else {
          item.version = 'Not found';
          item.isInstalled = false;
        }
      } catch (_) {
        item.version = 'Not found';
        item.isInstalled = false;
      } finally {
        item.isChecking = false;
        if (mounted) setState(() {});
      }
    }

    if (mounted) {
      setState(() {
        _isScanning = false;
      });
    }
  }

  String _extractVersion(String name, String output) {
    RegExp? rx;
    switch (name) {
      case 'PHP':
        rx = RegExp(r'PHP (\d+\.\d+\.\d+)');
        break;
      case 'Python':
        rx = RegExp(r'Python (\d+\.\d+\.\d+)');
        break;
      case 'Node.js':
        rx = RegExp(r'v(\d+\.\d+\.\d+)');
        break;
      case 'MySQL':
        rx = RegExp(r'(\d+\.\d+\.\d+)');
        break;
      case 'Apache':
        rx = RegExp(r'Apache/(\d+\.\d+\.\d+)');
        break;
      case 'Redis':
        rx = RegExp(r'v=(\d+\.\d+\.\d+)');
        break;
      case 'PostgreSQL':
        rx = RegExp(r'(\d+\.\d+(\.\d+)?)');
        break;
      case 'Memcached':
        rx = RegExp(r'(\d+\.\d+\.\d+)');
        break;
      case 'Mailhog':
        rx = RegExp(r'(\d+\.\d+\.\d+)');
        break;
      case 'SMTP':
        rx = RegExp(r'(\d+\.\d+\.\d+)');
        break;
      case 'WebSocket':
        rx = RegExp(r'(\d+\.\d+\.\d+)');
        break;
      case 'Composer':
        rx = RegExp(r'(\d+\.\d+\.\d+)');
        break;
      case 'npm':
        rx = RegExp(r'(\d+\.\d+\.\d+)');
        break;
    }
    final match = rx?.firstMatch(output);
    if (match != null) return match.group(1) ?? 'Unknown';
    return 'Unknown';
  }

  Future<void> _autoInstallIfNeeded(BuildContext context) async {
    if (_autoInstallStarted) return;
    _autoInstallStarted = true;

    final vm = context.read<VersionManager>();
    for (final target in _installTargets) {
      final versions = SoftwareVersions.availableVersions[target.software];
      if (versions == null || versions.isEmpty) continue;
      final installed = vm.installed[target.software];
      if (installed?.isInstalled == true) continue;
      await vm.installVersion(target.software, versions.first);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_currentStep == 2) {
      WidgetsBinding.instance.addPostFrameCallback(
        (_) => _autoInstallIfNeeded(context),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.darkBackground,
      body: FadeTransition(
        opacity: _fadeAnim,
        child: GestureDetector(
          onPanStart: (_) => windowManager.startDragging(),
          child: Column(
            children: [
              // Top bar with logo
              Container(
                height: 60,
                padding: const EdgeInsets.symmetric(horizontal: 28),
                child: Row(
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: AppColors.brandDark,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Center(
                        child: Text(
                          'LX',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    ShaderMask(
                      shaderCallback: (b) =>
                          AppColors.accentGradient.createShader(b),
                      child: const Text(
                        'LocalX Setup',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const Spacer(),
                    if (_isScanning)
                      Row(
                        children: const [
                          SizedBox(
                            width: 14,
                            height: 14,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: AppColors.accent,
                            ),
                          ),
                          SizedBox(width: 8),
                          Text(
                            'Scanning...',
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColors.darkTextSecondary,
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
              ),

              // Progress bar
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 80),
                child: Row(
                  children: List.generate(_stepCount, (i) {
                    final active = i <= _currentStep;
                    return Expanded(
                      child: Row(
                        children: [
                          if (i > 0)
                            Expanded(
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 300),
                                height: 2,
                                color: i <= _currentStep
                                    ? AppColors.accent
                                    : AppColors.darkBorder,
                              ),
                            ),
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            width: 28,
                            height: 28,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: active
                                  ? AppColors.accent
                                  : Colors.transparent,
                              border: Border.all(
                                color: active
                                    ? AppColors.accent
                                    : AppColors.darkBorder,
                                width: 2,
                              ),
                            ),
                            child: Center(
                              child: i < _currentStep
                                  ? const Icon(
                                      Icons.check,
                                      size: 14,
                                      color: AppColors.darkBackground,
                                    )
                                  : Text(
                                      '${i + 1}',
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                        color: active
                                            ? AppColors.darkBackground
                                            : AppColors.darkTextSecondary,
                                      ),
                                    ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                ),
              ),

              const SizedBox(height: 24),

              // Steps content
              Expanded(
                child: PageView(
                  controller: _pageCtrl,
                  physics: const NeverScrollableScrollPhysics(),
                  children: [
                    const _LanguageThemeStep(),
                    _EnvironmentStep(items: _scanItems, onRescan: _runScan),
                    _InstallStep(targets: _installTargets),
                    const _ConfigStep(),
                    const _ReadyStep(),
                  ],
                ),
              ),

              // Bottom buttons
              Padding(
                padding: const EdgeInsets.all(28),
                child: Row(
                  children: [
                    if (_currentStep > 0)
                      OutlinedButton.icon(
                        onPressed: _prevStep,
                        icon: const Icon(Icons.arrow_back, size: 16),
                        label: const Text('Back'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.darkText,
                          side: const BorderSide(color: AppColors.darkBorder),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 14,
                          ),
                        ),
                      ),
                    const Spacer(),
                    ElevatedButton.icon(
                      onPressed: _nextStep,
                      icon: Icon(
                        _currentStep == _stepCount - 1
                            ? Icons.rocket_launch_outlined
                            : Icons.arrow_forward,
                        size: 18,
                      ),
                      label: Text(
                        _currentStep == _stepCount - 1
                            ? 'Launch LocalX'
                            : 'Continue',
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.accent,
                        foregroundColor: AppColors.darkBackground,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 28,
                          vertical: 14,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LanguageThemeStep extends StatelessWidget {
  const _LanguageThemeStep();

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsService>();
    final accent = AppColors.accent;
    return Center(
      child: Container(
        padding: const EdgeInsets.all(28),
        width: 620,
        decoration: BoxDecoration(
          color: AppColors.darkCard,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppColors.darkBorder),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Choose Language & Theme',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: AppColors.darkText,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Set the UI before setup starts.',
              style: TextStyle(
                fontSize: 13,
                color: AppColors.darkTextSecondary,
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: _segmented(
                    label: 'Language',
                    child: SegmentedButton<String>(
                      segments: const [
                        ButtonSegment(value: 'en', label: Text('English')),
                        ButtonSegment(value: 'fa', label: Text('فارسی')),
                      ],
                      selected: {settings.language},
                      onSelectionChanged: (s) => settings.setLanguage(s.first),
                      style: ButtonStyle(
                        backgroundColor: WidgetStateProperty.resolveWith(
                          (states) => states.contains(WidgetState.selected)
                              ? accent.withValues(alpha: 0.2)
                              : AppColors.darkSurface,
                        ),
                        foregroundColor: const WidgetStatePropertyAll(
                          AppColors.darkText,
                        ),
                        side: const WidgetStatePropertyAll(
                          BorderSide(color: AppColors.darkBorder),
                        ),
                        textStyle: const WidgetStatePropertyAll(
                          TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _segmented(
                    label: 'Theme',
                    child: SegmentedButton<ThemeMode>(
                      segments: const [
                        ButtonSegment(
                          value: ThemeMode.dark,
                          icon: Icon(Icons.dark_mode_outlined, size: 16),
                          label: Text('Dark'),
                        ),
                        ButtonSegment(
                          value: ThemeMode.light,
                          icon: Icon(Icons.light_mode_outlined, size: 16),
                          label: Text('Light'),
                        ),
                        ButtonSegment(
                          value: ThemeMode.system,
                          icon: Icon(Icons.computer_outlined, size: 16),
                          label: Text('System'),
                        ),
                      ],
                      selected: {settings.themeMode},
                      onSelectionChanged: (s) => settings.setThemeMode(s.first),
                      style: ButtonStyle(
                        backgroundColor: WidgetStateProperty.resolveWith(
                          (states) => states.contains(WidgetState.selected)
                              ? accent.withValues(alpha: 0.2)
                              : AppColors.darkSurface,
                        ),
                        foregroundColor: const WidgetStatePropertyAll(
                          AppColors.darkText,
                        ),
                        side: const WidgetStatePropertyAll(
                          BorderSide(color: AppColors.darkBorder),
                        ),
                        textStyle: const WidgetStatePropertyAll(
                          TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _segmented({required String label, required Widget child}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: AppColors.darkTextSecondary,
          ),
        ),
        const SizedBox(height: 8),
        child,
      ],
    );
  }
}

class _EnvironmentStep extends StatelessWidget {
  final List<_ScanItem> items;
  final VoidCallback onRescan;
  const _EnvironmentStep({required this.items, required this.onRescan});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 80),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text(
                'Environment Check',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: AppColors.darkText,
                ),
              ),
              const Spacer(),
              OutlinedButton.icon(
                onPressed: onRescan,
                icon: const Icon(Icons.refresh, size: 16),
                label: const Text('Rescan'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.darkText,
                  side: const BorderSide(color: AppColors.darkBorder),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Text(
            'LocalX scans your system for installed software:',
            style: TextStyle(fontSize: 14, color: AppColors.darkTextSecondary),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: Scrollbar(
              thumbVisibility: true,
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    ...items.map((i) => _EnvRow(item: i)),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.info.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: AppColors.info.withValues(alpha: 0.2),
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.info_outlined,
                            size: 20,
                            color: AppColors.info,
                          ),
                          const SizedBox(width: 12),
                          const Expanded(
                            child: Text(
                              'Missing software can be installed from the Version Manager or next step.',
                              style: TextStyle(
                                fontSize: 13,
                                color: AppColors.info,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.warning.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: AppColors.warning.withValues(alpha: 0.2),
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.admin_panel_settings_outlined,
                            size: 20,
                            color: AppColors.warning,
                          ),
                          const SizedBox(width: 12),
                          const Expanded(
                            child: Text(
                              'LocalX needs Administrator privileges to edit hosts and bind to protected ports.',
                              style: TextStyle(
                                fontSize: 13,
                                color: AppColors.warning,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _InstallStep extends StatelessWidget {
  final List<_InstallTarget> targets;
  const _InstallStep({required this.targets});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<VersionManager>();
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 80),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Install Core Stack',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: AppColors.darkText,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'LocalX will install missing core services automatically.',
            style: TextStyle(fontSize: 14, color: AppColors.darkTextSecondary),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: Scrollbar(
              thumbVisibility: true,
              child: ListView.separated(
                itemCount: targets.length,
                separatorBuilder: (_, index) => const SizedBox(height: 10),
                itemBuilder: (context, index) {
                  final target = targets[index];
                  final versions =
                      SoftwareVersions.availableVersions[target.software] ?? [];
                  final wanted = versions.isNotEmpty ? versions.first : 'N/A';
                  final installed = vm.installed[target.software];
                  final progress =
                      vm.installProgress['${target.software}-$wanted'];
                  final isInstalling =
                      progress != null &&
                      progress.status != InstallStatus.done &&
                      progress.status != InstallStatus.error &&
                      progress.status != InstallStatus.canceled;

                  return Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.darkCard,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: AppColors.darkBorder),
                    ),
                    child: Builder(
                      builder: (context) {
                        final brand = BrandCatalog.software(target.software);
                        return Row(
                          children: [
                            Container(
                              width: 36,
                              height: 36,
                              decoration: BoxDecoration(
                                color: brand.color.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Center(
                                child: BrandIcon(spec: brand, size: 18),
                              ),
                            ),
                            const SizedBox(width: 14),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  target.software,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.darkText,
                                  ),
                                ),
                                Text(
                                  'Recommended: $wanted',
                                  style: const TextStyle(
                                    fontSize: 11,
                                    color: AppColors.darkTextSecondary,
                                  ),
                                ),
                              ],
                            ),
                            const Spacer(),
                            if (installed?.isInstalled == true)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.running.withValues(
                                    alpha: 0.1,
                                  ),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  'Installed',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: AppColors.running,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              )
                            else if (isInstalling)
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  SizedBox(
                                    width: 140,
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.end,
                                      children: [
                                        Text(
                                          progress.message,
                                          style: const TextStyle(
                                            fontSize: 10,
                                            color: AppColors.darkTextSecondary,
                                          ),
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        const SizedBox(height: 4),
                                        LinearProgressIndicator(
                                          value: progress.progress,
                                          backgroundColor: AppColors.darkBorder,
                                          valueColor:
                                              const AlwaysStoppedAnimation(
                                                AppColors.accent,
                                              ),
                                          minHeight: 3,
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  OutlinedButton(
                                    onPressed: () => vm.cancelInstall(
                                      target.software,
                                      wanted,
                                    ),
                                    style: OutlinedButton.styleFrom(
                                      foregroundColor: AppColors.stopped,
                                      side: BorderSide(
                                        color: AppColors.stopped.withValues(
                                          alpha: 0.4,
                                        ),
                                      ),
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 10,
                                        vertical: 8,
                                      ),
                                    ),
                                    child: const Text(
                                      'Cancel',
                                      style: TextStyle(fontSize: 11),
                                    ),
                                  ),
                                ],
                              )
                            else
                              FutureBuilder<bool>(
                                future: vm.hasLocalBundle(
                                  target.software,
                                  wanted,
                                ),
                                builder: (context, snapshot) {
                                  final hasBundle = snapshot.data == true;
                                  return OutlinedButton(
                                    onPressed: versions.isEmpty
                                        ? null
                                        : () => vm.installVersion(
                                            target.software,
                                            wanted,
                                          ),
                                    child: Text(
                                      hasBundle ? 'Install' : 'Download',
                                    ),
                                  );
                                },
                              ),
                          ],
                        );
                      },
                    ),
                  );
                },
              ),
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.info.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.info.withValues(alpha: 0.2)),
            ),
            child: Row(
              children: [
                Icon(Icons.info_outlined, size: 18, color: AppColors.info),
                const SizedBox(width: 10),
                const Expanded(
                  child: Text(
                    'You can manage or change versions later from Version Manager.',
                    style: TextStyle(fontSize: 12, color: AppColors.info),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _EnvRow extends StatelessWidget {
  final _ScanItem item;
  const _EnvRow({required this.item});

  @override
  Widget build(BuildContext context) {
    final statusColor = item.isChecking
        ? AppColors.warning
        : item.isInstalled
        ? AppColors.running
        : AppColors.stopped;
    final statusText = item.isChecking
        ? 'Scanning...'
        : item.isInstalled
        ? 'Installed'
        : 'Missing';

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.darkCard,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppColors.darkBorder),
        ),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: item.brand.color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(child: BrandIcon(spec: item.brand, size: 18)),
            ),
            const SizedBox(width: 14),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.name,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.darkText,
                  ),
                ),
                Text(
                  item.version,
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.darkTextSecondary,
                  ),
                ),
              ],
            ),
            const Spacer(),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: statusColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                statusText,
                style: TextStyle(
                  fontSize: 11,
                  color: statusColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ConfigStep extends StatelessWidget {
  const _ConfigStep();

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsService>();
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 80),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Quick Configuration',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: AppColors.darkText,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Set up your preferred ports and paths. You can change these later in Settings.',
            style: TextStyle(fontSize: 14, color: AppColors.darkTextSecondary),
          ),
          const SizedBox(height: 24),
          Expanded(
            child: Scrollbar(
              thumbVisibility: true,
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    _ConfigField(
                      'Apache HTTP Port',
                      settings.apachePort,
                      (v) => settings.setApachePort(v),
                      Icons.language_outlined,
                      AppColors.apache,
                    ),
                    const SizedBox(height: 12),
                    _ConfigField(
                      'MySQL Port',
                      settings.mysqlPort,
                      (v) => settings.setMysqlPort(v),
                      Icons.storage_outlined,
                      AppColors.mysql,
                    ),
                    const SizedBox(height: 12),
                    _ConfigField(
                      'PHP Port',
                      settings.phpPort,
                      (v) => settings.setPhpPort(v),
                      Icons.code_outlined,
                      AppColors.php,
                    ),
                    const SizedBox(height: 12),
                    _ConfigField(
                      'Redis Port',
                      settings.redisPort,
                      (v) => settings.setRedisPort(v),
                      Icons.memory_outlined,
                      AppColors.redis,
                    ),
                    const SizedBox(height: 12),
                    _ConfigField(
                      'PostgreSQL Port',
                      settings.postgresPort,
                      (v) => settings.setPostgresPort(v),
                      Icons.dns_outlined,
                      const Color(0xFF336791),
                    ),
                    const SizedBox(height: 12),
                    _ConfigField(
                      'Memcached Port',
                      settings.memcachedPort,
                      (v) => settings.setMemcachedPort(v),
                      Icons.sd_storage_outlined,
                      const Color(0xFF51B24B),
                    ),
                    const SizedBox(height: 12),
                    _ConfigField(
                      'Mailhog Port',
                      settings.mailhogPort,
                      (v) => settings.setMailhogPort(v),
                      Icons.mail_outlined,
                      const Color(0xFFE83D31),
                    ),
                    const SizedBox(height: 12),
                    _ConfigField(
                      'SMTP Port',
                      settings.smtpPort,
                      (v) => settings.setSmtpPort(v),
                      Icons.mail_outlined,
                      const Color(0xFF7C3AED),
                    ),
                    const SizedBox(height: 12),
                    _ConfigField(
                      'WebSocket Port',
                      settings.websocketPort,
                      (v) => settings.setWebsocketPort(v),
                      Icons.cable_outlined,
                      const Color(0xFF10B981),
                    ),
                    const SizedBox(height: 12),
                    _ConfigField(
                      'Node.js Port',
                      settings.nodePort,
                      (v) => settings.setNodePort(v),
                      Icons.javascript_outlined,
                      AppColors.nodejs,
                    ),
                    const SizedBox(height: 12),
                    _ConfigField(
                      'Python Port',
                      settings.pythonPort,
                      (v) => settings.setPythonPort(v),
                      Icons.code_outlined,
                      AppColors.python,
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.accent.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: AppColors.accent.withValues(alpha: 0.2),
                        ),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.tips_and_updates_outlined,
                            size: 20,
                            color: AppColors.accent,
                          ),
                          const SizedBox(width: 12),
                          const Expanded(
                            child: Text(
                              'Default ports are recommended for most setups. Change only if you have conflicts.',
                              style: TextStyle(
                                fontSize: 13,
                                color: AppColors.accent,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ConfigField extends StatelessWidget {
  final String label;
  final int port;
  final ValueChanged<int> onChanged;
  final IconData icon;
  final Color color;
  const _ConfigField(
    this.label,
    this.port,
    this.onChanged,
    this.icon,
    this.color,
  );

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.darkCard,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.darkBorder),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 18),
          ),
          const SizedBox(width: 14),
          Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: AppColors.darkText,
            ),
          ),
          const Spacer(),
          FutureBuilder<bool>(
            future: PortProbe.isAvailable(port),
            builder: (context, snapshot) {
              final ok = snapshot.data == true;
              final tagColor = ok ? AppColors.running : AppColors.warning;
              final tagText = ok ? 'Available' : 'In Use';
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                margin: const EdgeInsets.only(right: 10),
                decoration: BoxDecoration(
                  color: tagColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: tagColor.withValues(alpha: 0.25)),
                ),
                child: Text(
                  tagText,
                  style: TextStyle(
                    fontSize: 10,
                    color: tagColor,
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
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 14, color: AppColors.darkText),
              onSubmitted: (v) {
                final p = int.tryParse(v);
                if (p != null) onChanged(p);
              },
              decoration: InputDecoration(
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                fillColor: AppColors.darkSurface,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ReadyStep extends StatelessWidget {
  const _ReadyStep();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: AppColors.running.withValues(alpha: 0.1),
              shape: BoxShape.circle,
              border: Border.all(
                color: AppColors.running.withValues(alpha: 0.3),
                width: 2,
              ),
            ),
            child: const Icon(
              Icons.check_circle_outlined,
              size: 40,
              color: AppColors.running,
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            "You're All Set!",
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w700,
              color: AppColors.darkText,
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'LocalX is ready to power your development workflow.\nClick "Launch LocalX" to start managing your projects.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 15,
              color: AppColors.darkTextSecondary,
              height: 1.6,
            ),
          ),
          const SizedBox(height: 32),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              _ReadyFeature(
                Icons.public_outlined,
                'Custom Domains',
                'Use http://myapp instead of localhost',
              ),
              SizedBox(width: 24),
              _ReadyFeature(
                Icons.auto_fix_high_outlined,
                'Project Wizard',
                'Create Laravel, React, Vue projects',
              ),
              SizedBox(width: 24),
              _ReadyFeature(
                Icons.swap_vert_outlined,
                'Version Manager',
                'Switch PHP/Node versions easily',
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ReadyFeature extends StatelessWidget {
  final IconData icon;
  final String title, subtitle;
  const _ReadyFeature(this.icon, this.title, this.subtitle);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 200,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.darkCard,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.darkBorder),
      ),
      child: Column(
        children: [
          Icon(icon, size: 28, color: AppColors.accent),
          const SizedBox(height: 10),
          Text(
            title,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.darkText,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 11,
              color: AppColors.darkTextSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

class _ScanItem {
  final String name;
  final String command;
  final List<String> args;
  final BrandSpec brand;
  bool isInstalled;
  bool isChecking;
  String version;

  _ScanItem(this.name, this.command, this.args, this.brand)
    : isInstalled = false,
      isChecking = true,
      version = 'Scanning...';
}

class _InstallTarget {
  final String software;
  const _InstallTarget(this.software);
}
