import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:window_manager/window_manager.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:tray_manager/tray_manager.dart';
import 'package:path_provider/path_provider.dart';

import 'core/theme/app_theme.dart';
import 'core/theme/app_colors.dart';
import 'core/services/translation_service.dart';
import 'core/services/process_manager.dart';
import 'core/services/version_manager.dart';
import 'core/services/project_service.dart';
import 'core/services/settings_service.dart';
import 'core/services/domain_service.dart';
import 'core/services/adminer_service.dart';
import 'core/services/system_service.dart';
import 'shared/sidebar_nav.dart';
import 'shared/command_palette.dart';
import 'features/dashboard/dashboard_screen.dart';
import 'features/projects/projects_screen.dart';
import 'features/services/services_screen.dart';
import 'features/wizard/wizard_screen.dart';
import 'features/versions/versions_screen.dart';
import 'features/settings/settings_screen.dart';
import 'features/setup/setup_wizard_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await windowManager.ensureInitialized();
  if (Platform.isWindows) {
    await windowManager.setPreventClose(true);
  }

  const windowOptions = WindowOptions(
    size: Size(1200, 780),
    minimumSize: Size(1000, 680),
    center: true,
    backgroundColor: Colors.transparent,
    titleBarStyle: TitleBarStyle.hidden,
    title: 'LocalX',
  );

  windowManager.waitUntilReadyToShow(windowOptions, () async {
    await windowManager.show();
    await windowManager.focus();
  });

  final settings = SettingsService();
  await settings.loadSettings();
  await settings.ensureSafeDefaults();

  // Check if this is the first run
  final prefs = await SharedPreferences.getInstance();
  final isFirstRun = prefs.getBool('firstRunComplete') != true;

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProxyProvider<SettingsService, ProcessManager>(
          create: (_) => ProcessManager(),
          update: (_, settings, pm) {
            pm ??= ProcessManager();
            pm.applySettings(
              apachePort: settings.apachePort,
              mysqlPort: settings.mysqlPort,
              phpPort: settings.phpPort,
              redisPort: settings.redisPort,
              nodePort: settings.nodePort,
              postgresPort: settings.postgresPort,
              memcachedPort: settings.memcachedPort,
              mailhogPort: settings.mailhogPort,
              smtpPort: settings.smtpPort,
              websocketPort: settings.websocketPort,
              pythonPort: settings.pythonPort,
              autoStartServices: settings.autoStartServices,
              restoreOnLaunch: true,
            );
            return pm;
          },
        ),
        ChangeNotifierProvider(create: (_) => VersionManager()),
        ChangeNotifierProvider(create: (_) => ProjectService()),
        ChangeNotifierProvider(create: (_) => DomainService()),
        ChangeNotifierProvider(create: (_) => AdminerService()),
        ChangeNotifierProvider(create: (_) => SystemService()),
        ChangeNotifierProvider.value(value: settings),
      ],
      child: LocalXApp(isFirstRun: isFirstRun),
    ),
  );
}

class LocalXApp extends StatelessWidget {
  final bool isFirstRun;
  const LocalXApp({super.key, required this.isFirstRun});

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsService>();
    final locale = Locale(settings.language);
    final isFa = settings.language == 'fa';
    final lightTheme = isFa ? AppTheme.lightThemeWithFonts(displayFont: 'Vazir', bodyFont: 'Vazir') : AppTheme.lightTheme;
    final darkTheme = isFa ? AppTheme.darkThemeWithFonts(displayFont: 'Vazir', bodyFont: 'Vazir') : AppTheme.darkTheme;
    
    return MaterialApp(
      title: context.tr('app_name'),
      debugShowCheckedModeBanner: false,
      theme: lightTheme,
      darkTheme: darkTheme,
      themeMode: settings.themeMode,
      locale: locale,
      supportedLocales: const [Locale('en'), Locale('fa')],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      builder: (context, child) {
        return Directionality(
          textDirection: settings.language == 'fa' ? TextDirection.rtl : TextDirection.ltr,
          child: child!,
        );
      },
      home: isFirstRun ? const _FirstRunWrapper() : const AppShell(),
    );
  }
}

class _FirstRunWrapper extends StatefulWidget {
  const _FirstRunWrapper();
  @override
  State<_FirstRunWrapper> createState() => _FirstRunWrapperState();
}

class _FirstRunWrapperState extends State<_FirstRunWrapper> {
  bool _setupComplete = false;

  @override
  Widget build(BuildContext context) {
    if (_setupComplete) return const AppShell();
    return SetupWizardScreen(
      onComplete: () async {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool('firstRunComplete', true);
        setState(() => _setupComplete = true);
      },
    );
  }
}

class AppShell extends StatefulWidget {
  const AppShell({super.key});
  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> with WindowListener, TrayListener {
  int _selectedIndex = 0;
  bool _showSplash = true;
  bool _trayReady = false;
  String _lastLang = '';
  bool _focusedAfterSplash = false;
  bool _isExiting = false;
  bool _didFirstShellBuild = false;

  @override
  void initState() {
    super.initState();
    windowManager.addListener(this);
    trayManager.addListener(this);
    Future.delayed(const Duration(milliseconds: 2000), () {
      if (mounted) setState(() => _showSplash = false);
    });
    WidgetsBinding.instance.addPostFrameCallback((_) => _initTray());
    WidgetsBinding.instance.addPostFrameCallback((_) => _applyStartMinimized());
  }

  final _screens = const [
    DashboardScreen(),
    ProjectsScreen(),
    ServicesScreen(),
    WizardScreen(),
    VersionsScreen(),
    SettingsScreen(),
  ];

  // Handle global shortcuts (Ctrl+K or Cmd+K)
  void _handleKeyPress(KeyEvent event) {
    if (event is KeyDownEvent) {
      final isCmdOrCtrl = HardwareKeyboard.instance.isLogicalKeyPressed(LogicalKeyboardKey.metaLeft) || 
                          HardwareKeyboard.instance.isLogicalKeyPressed(LogicalKeyboardKey.metaRight) ||
                          HardwareKeyboard.instance.isLogicalKeyPressed(LogicalKeyboardKey.controlLeft) ||
                          HardwareKeyboard.instance.isLogicalKeyPressed(LogicalKeyboardKey.controlRight);
      
      if (isCmdOrCtrl && event.logicalKey == LogicalKeyboardKey.keyK) {
        _showCommandPalette();
      }
    }
  }

  void _showCommandPalette() {
    showDialog(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.5),
      builder: (ctx) => CommandPalette(
        onNavigate: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsService>();
    if (_trayReady && _lastLang != settings.language) {
      _lastLang = settings.language;
      _updateTrayMenu();
    }

    if (_showSplash) return const _SplashView();

    final isDark = Theme.of(context).brightness == Brightness.dark;
    if (!_focusedAfterSplash) {
      _focusedAfterSplash = true;
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        await windowManager.show();
        await windowManager.focus();
      });
    }
    final system = context.watch<SystemService>();
    if (!_didFirstShellBuild) {
      _didFirstShellBuild = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) setState(() {});
      });
    }
    return KeyboardListener(
      focusNode: FocusNode()..requestFocus(),
      onKeyEvent: _handleKeyPress,
      child: Scaffold(
        backgroundColor: isDark ? AppColors.darkBackground : AppColors.lightBackground,
        body: Container(
          decoration: BoxDecoration(
            gradient: isDark ? AppColors.shellGradientDark : AppColors.shellGradientLight,
          ),
          child: Stack(
            children: [
              Positioned(
                right: -120,
                top: -80,
                child: _GlowBlob(color: AppColors.accent.withValues(alpha: 0.25), size: 320),
              ),
              Positioned(
                left: -140,
                bottom: -120,
                child: _GlowBlob(color: AppColors.accentSecondary.withValues(alpha: 0.22), size: 360),
              ),
              Column(
                children: [
                  // Custom title bar
                  _TitleBar(isDark: isDark),
                  if (!system.isChecking && !system.isAdmin)
                    _AdminBanner(isDark: isDark),
                  // Main content
                  Expanded(
                    child: Row(
                      children: [
                        SidebarNav(
                          selectedIndex: _selectedIndex,
                          onItemSelected: (i) => setState(() => _selectedIndex = i),
                        ),
                        Expanded(
                          child: IndexedStack(
                            index: _selectedIndex,
                            children: _screens,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _applyStartMinimized() async {
    final settings = context.read<SettingsService>();
    if (settings.startMinimized) {
      await windowManager.hide();
    }
  }

  Future<void> _initTray() async {
    if (!Platform.isWindows) return;
    final appDir = await getApplicationSupportDirectory();
    final trayPath = '${appDir.path}\\LocalX\\tray.ico';
    final data = await rootBundle.load('assets/icons/localx.ico');
    final file = File(trayPath);
    await file.parent.create(recursive: true);
    await file.writeAsBytes(data.buffer.asUint8List(), flush: true);
    await trayManager.setIcon(trayPath);
    await trayManager.setToolTip('LocalX');
    await _updateTrayMenu();
    _trayReady = true;
    if (mounted) {
      setState(() {});
    }
  }

  Future<void> _updateTrayMenu() async {
    if (!Platform.isWindows) return;
    final settings = context.read<SettingsService>();
    final menu = Menu(items: [
      MenuItem(key: 'open', label: AppTranslations.tr(settings.language, 'tray_open')),
      MenuItem.separator(),
      MenuItem(key: 'exit', label: AppTranslations.tr(settings.language, 'tray_exit')),
    ]);
    await trayManager.setContextMenu(menu);
  }

  Future<void> _showWindow() async {
    await windowManager.show();
    await windowManager.focus();
  }

  @override
  void onTrayIconMouseDown() {
    _showWindow();
  }

  @override
  void onTrayIconRightMouseUp() {
    trayManager.popUpContextMenu();
  }

  @override
  void onTrayMenuItemClick(MenuItem menuItem) {
    if (menuItem.key == 'open') {
      _showWindow();
    } else if (menuItem.key == 'exit') {
      _exitApp();
    }
  }

  @override
  void onWindowMinimize() {
    final settings = context.read<SettingsService>();
    if (settings.minimizeToTray) {
      windowManager.hide();
    }
  }

  @override
  void onWindowClose() async {
    if (_isExiting) {
      await windowManager.setPreventClose(false);
      await windowManager.destroy();
      exit(0);
    }
    final settings = context.read<SettingsService>();
    if (settings.closeToTray) {
      await windowManager.hide();
    } else {
      await windowManager.destroy();
    }
  }

  Future<void> _exitApp() async {
    if (_isExiting) return;
    _isExiting = true;
    try {
      await trayManager.destroy();
    } catch (_) {}
    await windowManager.setPreventClose(false);
    await windowManager.destroy();
    exit(0);
  }

  @override
  void dispose() {
    windowManager.removeListener(this);
    trayManager.removeListener(this);
    super.dispose();
  }
}

class _GlowBlob extends StatelessWidget {
  final Color color;
  final double size;
  const _GlowBlob({required this.color, required this.size});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(color: color, blurRadius: 120, spreadRadius: 10),
        ],
      ),
    );
  }
}

class _AdminBanner extends StatelessWidget {
  final bool isDark;
  const _AdminBanner({required this.isDark});

  @override
  Widget build(BuildContext context) {
    final bg = isDark ? AppColors.darkSurface : AppColors.lightSurface;
    final brd = isDark ? AppColors.darkBorder : AppColors.lightBorder;
    final txt = isDark ? AppColors.darkText : AppColors.lightText;
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: bg.withValues(alpha: 0.85),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: brd),
      ),
      child: Row(
        children: [
          Icon(Icons.admin_panel_settings_outlined, size: 18, color: AppColors.warning),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'LocalX needs Administrator privileges to manage hosts and ports. Restart as admin for full features.',
              style: TextStyle(fontSize: 12, color: txt),
            ),
          ),
        ],
      ),
    );
  }
}

class _TitleBar extends StatelessWidget {
  final bool isDark;
  const _TitleBar({required this.isDark});

  @override
  Widget build(BuildContext context) {
    final bgColor = isDark ? AppColors.darkSurface : AppColors.lightSurface;
    final borderColor = isDark ? AppColors.darkBorder : AppColors.lightBorder;
    final subtitleColor = isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;

    return GestureDetector(
      onPanStart: (_) => windowManager.startDragging(),
      child: Container(
        height: 40,
        decoration: BoxDecoration(
          color: bgColor,
          border: Border(bottom: BorderSide(color: borderColor, width: 1)),
        ),
        child: Row(
          children: [
            const SizedBox(width: 16),
            ShaderMask(
              shaderCallback: (b) => AppColors.accentGradient.createShader(b),
              child: Text('LocalX', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Colors.white)),
            ),
            const SizedBox(width: 8),
            Text('v1.0.0', style: TextStyle(fontSize: 11, color: subtitleColor)),
            const Spacer(),
            // Window controls
            _WinBtn(icon: Icons.remove, onTap: () => windowManager.minimize(), color: subtitleColor),
            _WinBtn(icon: Icons.crop_square, onTap: () async {
              if (await windowManager.isMaximized()) { windowManager.unmaximize(); } else { windowManager.maximize(); }
            }, color: subtitleColor),
            _WinBtn(icon: Icons.close, onTap: () => windowManager.close(), color: AppColors.stopped, isClose: true),
            const SizedBox(width: 4),
          ],
        ),
      ),
    );
  }
}

class _WinBtn extends StatefulWidget {
  final IconData icon;
  final VoidCallback onTap;
  final Color color;
  final bool isClose;
  const _WinBtn({required this.icon, required this.onTap, required this.color, this.isClose = false});
  @override
  State<_WinBtn> createState() => _WinBtnState();
}

class _WinBtnState extends State<_WinBtn> {
  bool _hovered = false;
  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: Container(
          width: 36, height: 28,
          margin: const EdgeInsets.symmetric(horizontal: 1),
          decoration: BoxDecoration(
            color: _hovered ? (widget.isClose ? AppColors.stopped : widget.color.withValues(alpha: 0.1)) : Colors.transparent,
            borderRadius: BorderRadius.circular(6),
          ),
          child: Icon(widget.icon, size: 15, color: _hovered && widget.isClose ? Colors.white : widget.color),
        ),
      ),
    );
  }
}

class _SplashView extends StatefulWidget {
  const _SplashView();
  @override
  State<_SplashView> createState() => _SplashViewState();
}

class _SplashViewState extends State<_SplashView> with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _fadeAnim;
  late Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 1200));
    _fadeAnim = Tween<double>(begin: 0, end: 1).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOut));
    _scaleAnim = Tween<double>(begin: 0.8, end: 1).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOutBack));
    _ctrl.forward();
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.darkBackground,
      body: GestureDetector(
        onPanStart: (_) => windowManager.startDragging(),
        child: Center(
          child: AnimatedBuilder(
            animation: _ctrl,
            builder: (context, child) {
              return Opacity(
                opacity: _fadeAnim.value,
                child: Transform.scale(
                  scale: _scaleAnim.value,
                  child: Column(mainAxisSize: MainAxisSize.min, children: [
                    Container(
                      width: 80, height: 80,
                      decoration: BoxDecoration(color: AppColors.brandDark, borderRadius: BorderRadius.circular(20),
                        boxShadow: [BoxShadow(color: AppColors.brandDark.withValues(alpha: 0.4), blurRadius: 30, spreadRadius: 5)]),
                      child: const Center(child: Text('LX', style: TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.w800, letterSpacing: -1))),
                    ),
                    const SizedBox(height: 24),
                    const Text('LocalX', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w700, color: Colors.white, letterSpacing: -0.5)),
                    const SizedBox(height: 8),
                    const Text('Modern Development Environment', style: TextStyle(fontSize: 14, color: AppColors.darkTextSecondary)),
                    const SizedBox(height: 32),
                    SizedBox(width: 120, child: LinearProgressIndicator(
                      backgroundColor: AppColors.darkBorder,
                      valueColor: const AlwaysStoppedAnimation(AppColors.accent),
                      minHeight: 2,
                    )),
                  ]),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
