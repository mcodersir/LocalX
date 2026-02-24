import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DomainMapping {
  final String domain;
  final String projectPath;
  final int port;

  DomainMapping({required this.domain, required this.projectPath, this.port = 80});

  String get url => port == 80 ? 'http://$domain' : 'http://$domain:$port';

  Map<String, dynamic> toJson() => {
    'domain': domain,
    'projectPath': projectPath,
    'port': port,
  };

  static DomainMapping fromJson(Map<String, dynamic> json) {
    return DomainMapping(
      domain: json['domain'] as String,
      projectPath: json['projectPath'] as String,
      port: json['port'] as int? ?? 80,
    );
  }
}

class DomainService extends ChangeNotifier {
  final List<DomainMapping> _mappings = [];
  List<DomainMapping> get mappings => List.unmodifiable(_mappings);
  static const _prefsKey = 'localxDomainMappings';

  DomainService() {
    _load();
  }

  static String get hostsFilePath {
    if (Platform.isWindows) {
      return 'C:\\Windows\\System32\\drivers\\etc\\hosts';
    }
    return '/etc/hosts';
  }

  /// Add a custom domain mapping (e.g., example.com -> project path)
  Future<bool> addDomain(String domain, String projectPath, {int port = 80}) async {
    // Clean domain input
    final cleanDomain = domain.replaceAll('http://', '').replaceAll('https://', '').replaceAll('/', '').trim();
    if (cleanDomain.isEmpty) return false;

    // Check for duplicates
    if (_mappings.any((m) => m.domain == cleanDomain)) return false;

    final mapping = DomainMapping(domain: cleanDomain, projectPath: projectPath, port: port);
    _mappings.add(mapping);

    // Add to hosts file
    await _addToHostsFile(cleanDomain);
    await _save();
    notifyListeners();
    return true;
  }

  /// Remove a domain mapping
  Future<void> removeDomain(String domain) async {
    _mappings.removeWhere((m) => m.domain == domain);
    await _removeFromHostsFile(domain);
    await _save();
    notifyListeners();
  }

  /// Get domain for a project path
  DomainMapping? getDomainForProject(String projectPath) {
    try {
      return _mappings.firstWhere((m) => m.projectPath == projectPath);
    } catch (e) {
      return null;
    }
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_prefsKey);
    if (raw == null || raw.isEmpty) return;
    try {
      final data = jsonDecode(raw) as List;
      _mappings
        ..clear()
        ..addAll(data.map((e) => DomainMapping.fromJson(e as Map<String, dynamic>)));
      notifyListeners();
    } catch (_) {}
  }

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    final data = _mappings.map((e) => e.toJson()).toList();
    await prefs.setString(_prefsKey, jsonEncode(data));
  }

  /// Add entry to hosts file: 127.0.0.1 domain
  Future<void> _addToHostsFile(String domain) async {
    try {
      final hostsFile = File(hostsFilePath);
      final content = await hostsFile.readAsString();
      final entry = '127.0.0.1    $domain    # LocalX';

      // Check if already exists
      if (content.contains(entry)) return;

      // Append the new entry
      final newContent = '$content\n$entry\n';
      await hostsFile.writeAsString(newContent);
      debugPrint('[DomainService] Added $domain to hosts file');
    } catch (e) {
      debugPrint('[DomainService] Error adding to hosts file: $e');
      debugPrint('[DomainService] You may need to run LocalX as Administrator');
    }
  }

  /// Remove entry from hosts file
  Future<void> _removeFromHostsFile(String domain) async {
    try {
      final hostsFile = File(hostsFilePath);
      final lines = await hostsFile.readAsLines();
      final filtered = lines.where((line) => !line.contains('$domain    # LocalX')).toList();
      await hostsFile.writeAsString(filtered.join('\n'));
      debugPrint('[DomainService] Removed $domain from hosts file');
    } catch (e) {
      debugPrint('[DomainService] Error removing from hosts file: $e');
    }
  }

  /// Generate a suggested domain name from project name
  static String suggestDomain(String projectName) {
    final clean = projectName.toLowerCase().replaceAll(RegExp(r'[^a-z0-9-]'), '-').replaceAll(RegExp(r'-+'), '-').replaceAll(RegExp(r'^-|-$'), '');
    return '$clean.local';
  }
}
