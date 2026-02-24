import 'dart:convert';
import 'dart:io';
import 'package:package_info_plus/package_info_plus.dart';

class UpdateInfo {
  final String currentVersion;
  final String latestVersion;
  final String url;
  final bool isUpdateAvailable;
  final String? notes;

  UpdateInfo({
    required this.currentVersion,
    required this.latestVersion,
    required this.url,
    required this.isUpdateAvailable,
    this.notes,
  });
}

class UpdateService {
  static const String repo = 'mcodersir/LocalX';

  static Future<UpdateInfo> checkForUpdates() async {
    final info = await PackageInfo.fromPlatform();
    final current = info.version;
    final client = HttpClient();
    final request = await client.getUrl(Uri.parse('https://api.github.com/repos/$repo/releases/latest'));
    request.headers.set('User-Agent', 'LocalX');
    final response = await request.close();
    if (response.statusCode != 200) {
      throw Exception('Update check failed: ${response.statusCode}');
    }
    final body = await response.transform(SystemEncoding().decoder).join();
    client.close();
    final json = jsonDecode(body) as Map<String, dynamic>;
    final latest = (json['tag_name'] as String?)?.replaceFirst('v', '') ?? current;
    final url = json['html_url'] as String? ?? 'https://github.com/$repo/releases';
    final notes = json['body'] as String?;
    final isUpdate = _compareVersions(current, latest) < 0;
    return UpdateInfo(
      currentVersion: current,
      latestVersion: latest,
      url: url,
      isUpdateAvailable: isUpdate,
      notes: notes,
    );
  }

  static int _compareVersions(String a, String b) {
    List<int> parse(String v) => v.split('.').map((e) => int.tryParse(e) ?? 0).toList();
    final pa = parse(a);
    final pb = parse(b);
    final len = pa.length > pb.length ? pa.length : pb.length;
    while (pa.length < len) { pa.add(0); }
    while (pb.length < len) { pb.add(0); }
    for (int i = 0; i < len; i++) {
      if (pa[i] != pb[i]) return pa[i].compareTo(pb[i]);
    }
    return 0;
  }
}
