import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'port_probe.dart';
import 'startup_service.dart';

class SettingsService extends ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.dark;
  String _language = 'en';
  int _apachePort = 8080;
  int _mysqlPort = 3307;
  int _redisPort = 6380;
  int _nodePort = 3001;
  int _phpPort = 9000;
  int _postgresPort = 5433;
  int _memcachedPort = 11212;
  int _mailhogPort = 8026;
  int _smtpPort = 1026;
  int _websocketPort = 6001;
  int _pythonPort = 8001;
  String _htdocsPath = '';
  bool _autoStartServices = false;
  bool _startMinimized = false;
  bool _minimizeToTray = false;
  bool _closeToTray = true;

  ThemeMode get themeMode => _themeMode;
  String get language => _language;
  int get apachePort => _apachePort;
  int get mysqlPort => _mysqlPort;
  int get redisPort => _redisPort;
  int get nodePort => _nodePort;
  int get phpPort => _phpPort;
  int get postgresPort => _postgresPort;
  int get memcachedPort => _memcachedPort;
  int get mailhogPort => _mailhogPort;
  int get smtpPort => _smtpPort;
  int get websocketPort => _websocketPort;
  int get pythonPort => _pythonPort;
  String get htdocsPath => _htdocsPath;
  bool get autoStartServices => _autoStartServices;
  bool get startMinimized => _startMinimized;
  bool get minimizeToTray => _minimizeToTray;
  bool get closeToTray => _closeToTray;
  bool get isDark => _themeMode == ThemeMode.dark;

  Future<void> loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    final themeIndex = prefs.getInt('themeMode') ?? 2; // dark by default
    _themeMode = ThemeMode.values[themeIndex];
    _language = prefs.getString('language') ?? 'en';
    _apachePort = prefs.getInt('apachePort') ?? 8080;
    _mysqlPort = prefs.getInt('mysqlPort') ?? 3307;
    _redisPort = prefs.getInt('redisPort') ?? 6380;
    _nodePort = prefs.getInt('nodePort') ?? 3001;
    _phpPort = prefs.getInt('phpPort') ?? 9000;
    _postgresPort = prefs.getInt('postgresPort') ?? 5433;
    _memcachedPort = prefs.getInt('memcachedPort') ?? 11212;
    _mailhogPort = prefs.getInt('mailhogPort') ?? 8026;
    _smtpPort = prefs.getInt('smtpPort') ?? 1026;
    _websocketPort = prefs.getInt('websocketPort') ?? 6001;
    _pythonPort = prefs.getInt('pythonPort') ?? 8001;
    _htdocsPath = prefs.getString('htdocsPath') ?? '';
    _autoStartServices = prefs.getBool('autoStart') ?? false;
    _startMinimized = prefs.getBool('startMinimized') ?? false;
    _minimizeToTray = prefs.getBool('minimizeToTray') ?? false;
    _closeToTray = prefs.getBool('closeToTray') ?? true;
    notifyListeners();
  }

  Future<void> ensureSafeDefaults() async {
    final prefs = await SharedPreferences.getInstance();
    final alreadyConfigured = prefs.getBool('portsAutoConfigured') ?? false;
    if (alreadyConfigured) return;

    _apachePort = await _safePort(_apachePort == 80 ? 8080 : _apachePort);
    _mysqlPort = await _safePort(_mysqlPort == 3306 ? 3307 : _mysqlPort);
    _redisPort = await _safePort(_redisPort == 6379 ? 6380 : _redisPort);
    _nodePort = await _safePort(_nodePort == 3000 ? 3001 : _nodePort);
    _postgresPort = await _safePort(_postgresPort == 5432 ? 5433 : _postgresPort);
    _memcachedPort = await _safePort(_memcachedPort == 11211 ? 11212 : _memcachedPort);
    _mailhogPort = await _safePort(_mailhogPort == 8025 ? 8026 : _mailhogPort);
    _smtpPort = await _safePort(_smtpPort == 1025 ? 1026 : _smtpPort);
    _websocketPort = await _safePort(_websocketPort == 6001 ? 6002 : _websocketPort);
    _pythonPort = await _safePort(_pythonPort == 8000 ? 8001 : _pythonPort);

    await prefs.setInt('apachePort', _apachePort);
    await prefs.setInt('mysqlPort', _mysqlPort);
    await prefs.setInt('redisPort', _redisPort);
    await prefs.setInt('nodePort', _nodePort);
    await prefs.setInt('phpPort', _phpPort);
    await prefs.setInt('postgresPort', _postgresPort);
    await prefs.setInt('memcachedPort', _memcachedPort);
    await prefs.setInt('mailhogPort', _mailhogPort);
    await prefs.setInt('smtpPort', _smtpPort);
    await prefs.setInt('websocketPort', _websocketPort);
    await prefs.setInt('pythonPort', _pythonPort);
    await prefs.setBool('portsAutoConfigured', true);
    notifyListeners();
  }

  Future<int> _safePort(int preferred) async {
    final available = await PortProbe.isAvailable(preferred);
    if (available) return preferred;
    return PortProbe.findAvailablePort(preferred + 1, maxAttempts: 50);
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    _themeMode = mode;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('themeMode', mode.index);
    notifyListeners();
  }

  Future<void> setLanguage(String langCode) async {
    _language = langCode;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('language', langCode);
    notifyListeners();
  }

  Future<void> setApachePort(int port) async {
    _apachePort = port;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('apachePort', port);
    notifyListeners();
  }

  Future<void> setMysqlPort(int port) async {
    _mysqlPort = port;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('mysqlPort', port);
    notifyListeners();
  }

  Future<void> setRedisPort(int port) async {
    _redisPort = port;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('redisPort', port);
    notifyListeners();
  }

  Future<void> setNodePort(int port) async {
    _nodePort = port;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('nodePort', port);
    notifyListeners();
  }

  Future<void> setPhpPort(int port) async {
    _phpPort = port;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('phpPort', port);
    notifyListeners();
  }

  Future<void> setPostgresPort(int port) async {
    _postgresPort = port;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('postgresPort', port);
    notifyListeners();
  }

  Future<void> setMemcachedPort(int port) async {
    _memcachedPort = port;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('memcachedPort', port);
    notifyListeners();
  }

  Future<void> setMailhogPort(int port) async {
    _mailhogPort = port;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('mailhogPort', port);
    notifyListeners();
  }

  Future<void> setSmtpPort(int port) async {
    _smtpPort = port;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('smtpPort', port);
    notifyListeners();
  }

  Future<void> setWebsocketPort(int port) async {
    _websocketPort = port;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('websocketPort', port);
    notifyListeners();
  }

  Future<void> setPythonPort(int port) async {
    _pythonPort = port;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('pythonPort', port);
    notifyListeners();
  }

  Future<void> setHtdocsPath(String path) async {
    _htdocsPath = path;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('htdocsPath', path);
    notifyListeners();
  }

  Future<void> setAutoStart(bool value) async {
    _autoStartServices = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('autoStart', value);
    await StartupService.setEnabled(value);
    notifyListeners();
  }

  Future<void> setStartMinimized(bool value) async {
    _startMinimized = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('startMinimized', value);
    notifyListeners();
  }

  Future<void> setMinimizeToTray(bool value) async {
    _minimizeToTray = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('minimizeToTray', value);
    notifyListeners();
  }

  Future<void> setCloseToTray(bool value) async {
    _closeToTray = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('closeToTray', value);
    notifyListeners();
  }
}
