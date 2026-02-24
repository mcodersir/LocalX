import 'dart:io';
import 'package:archive/archive.dart';
import 'package:flutter/services.dart';
import 'package:path/path.dart' as p;

enum TemplateType { laravel, react, vue, nextjs, svelte, angular, nuxt, nodejs, php, fastapi, django, wordpress }

class TemplateManager {
  static const Map<TemplateType, String> _assets = {
    TemplateType.laravel: 'assets/templates/laravel.zip',
    TemplateType.react: 'assets/templates/react.zip',
    TemplateType.vue: 'assets/templates/vue.zip',
    TemplateType.nextjs: 'assets/templates/next.zip',
    TemplateType.svelte: 'assets/templates/svelte.zip',
    TemplateType.angular: 'assets/templates/angular.zip',
    TemplateType.nuxt: 'assets/templates/nuxt.zip',
    TemplateType.nodejs: 'assets/templates/node.zip',
    TemplateType.php: 'assets/templates/php.zip',
    TemplateType.fastapi: 'assets/templates/fastapi.zip',
    TemplateType.django: 'assets/templates/django.zip',
    TemplateType.wordpress: 'assets/templates/wordpress.zip',
  };

  static Future<bool> hasTemplate(TemplateType type) async {
    final asset = _assets[type];
    if (asset == null) return false;
    try {
      await rootBundle.load(asset);
      return true;
    } catch (_) {
      return false;
    }
  }

  static Future<void> extractTemplate(TemplateType type, String destinationPath) async {
    final asset = _assets[type];
    if (asset == null) throw Exception('Template not found');
    final data = await rootBundle.load(asset);
    final bytes = data.buffer.asUint8List();
    final archive = ZipDecoder().decodeBytes(bytes);

    final destDir = Directory(destinationPath);
    if (!await destDir.exists()) {
      await destDir.create(recursive: true);
    }

    for (final file in archive) {
      final filename = file.name;
      if (filename.isEmpty) continue;
      final outPath = p.join(destinationPath, filename);
      if (file.isFile) {
        final outFile = File(outPath);
        await outFile.parent.create(recursive: true);
        final content = file.content as Uint8List;
        await outFile.writeAsBytes(content, flush: true);
      } else {
        await Directory(outPath).create(recursive: true);
      }
    }
  }
}
