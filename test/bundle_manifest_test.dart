import 'package:flutter_test/flutter_test.dart';
import 'package:localx/core/services/version_manager.dart';

void main() {
  test('bundle manifest entry parsing', () {
    final entry = BundleManifestEntry.fromJson({
      'software': 'php',
      'version': '8.5.1',
      'platform': 'windows',
      'archive': 'php/8.5.1-windows.zip',
      'sha256': 'abc',
      'sourceUrl': 'https://example.com/a.zip',
      'installMode': 'archive',
    });

    expect(entry.software, 'php');
    expect(entry.version, '8.5.1');
    expect(entry.platform, 'windows');
    expect(entry.installMode, 'archive');
  });
}
