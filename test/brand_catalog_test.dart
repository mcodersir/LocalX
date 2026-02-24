import 'package:flutter_test/flutter_test.dart';
import 'package:localx/core/branding/brand_catalog.dart';
import 'package:localx/core/services/project_service.dart';

void main() {
  test('framework brand uses official asset for Laravel', () {
    final spec = BrandCatalog.framework(ProjectFramework.laravel);
    expect(spec.key, 'laravel');
    expect(spec.svgAsset, isNotNull);
  });

  test('software brand resolves Node.js service brand', () {
    final spec = BrandCatalog.software('Node.js');
    expect(spec.key, 'nodejs');
    expect(spec.svgAsset, contains('nodejs.svg'));
  });
}
