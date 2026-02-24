import 'package:flutter/material.dart';
import '../services/project_service.dart';
import '../theme/app_colors.dart';

class BrandSpec {
  final String key;
  final String? svgAsset;
  final IconData fallbackIcon;
  final Color color;

  const BrandSpec({
    required this.key,
    required this.svgAsset,
    required this.fallbackIcon,
    required this.color,
  });
}

class BrandCatalog {
  static const BrandSpec _unknownFramework = BrandSpec(
    key: 'unknown',
    svgAsset: null,
    fallbackIcon: Icons.folder_outlined,
    color: AppColors.darkTextMuted,
  );

  static const Map<ProjectFramework, BrandSpec> frameworks = {
    ProjectFramework.laravel: BrandSpec(
      key: 'laravel',
      svgAsset: 'assets/brands/frameworks/laravel.svg',
      fallbackIcon: Icons.local_fire_department_outlined,
      color: AppColors.laravel,
    ),
    ProjectFramework.react: BrandSpec(
      key: 'react',
      svgAsset: 'assets/brands/frameworks/react.svg',
      fallbackIcon: Icons.science_outlined,
      color: AppColors.react,
    ),
    ProjectFramework.vue: BrandSpec(
      key: 'vue',
      svgAsset: 'assets/brands/frameworks/vue.svg',
      fallbackIcon: Icons.change_history_outlined,
      color: AppColors.vue,
    ),
    ProjectFramework.nextjs: BrandSpec(
      key: 'nextjs',
      svgAsset: 'assets/brands/frameworks/nextjs.svg',
      fallbackIcon: Icons.arrow_forward_outlined,
      color: Color(0xFF111111),
    ),
    ProjectFramework.svelte: BrandSpec(
      key: 'svelte',
      svgAsset: 'assets/brands/frameworks/svelte.svg',
      fallbackIcon: Icons.bolt_outlined,
      color: AppColors.svelte,
    ),
    ProjectFramework.angular: BrandSpec(
      key: 'angular',
      svgAsset: 'assets/brands/frameworks/angular.svg',
      fallbackIcon: Icons.change_circle_outlined,
      color: AppColors.angular,
    ),
    ProjectFramework.nuxt: BrandSpec(
      key: 'nuxt',
      svgAsset: 'assets/brands/frameworks/nuxt.svg',
      fallbackIcon: Icons.rocket_launch_outlined,
      color: AppColors.nuxt,
    ),
    ProjectFramework.nodejs: BrandSpec(
      key: 'nodejs',
      svgAsset: 'assets/brands/frameworks/nodejs.svg',
      fallbackIcon: Icons.javascript_outlined,
      color: AppColors.nodejs,
    ),
    ProjectFramework.php: BrandSpec(
      key: 'php',
      svgAsset: 'assets/brands/frameworks/php.svg',
      fallbackIcon: Icons.code_outlined,
      color: AppColors.php,
    ),
    ProjectFramework.fastapi: BrandSpec(
      key: 'fastapi',
      svgAsset: 'assets/brands/frameworks/fastapi.svg',
      fallbackIcon: Icons.api_outlined,
      color: AppColors.fastapi,
    ),
    ProjectFramework.django: BrandSpec(
      key: 'django',
      svgAsset: 'assets/brands/frameworks/django.svg',
      fallbackIcon: Icons.web_outlined,
      color: AppColors.django,
    ),
    ProjectFramework.wordpress: BrandSpec(
      key: 'wordpress',
      svgAsset: 'assets/brands/frameworks/wordpress.svg',
      fallbackIcon: Icons.language_outlined,
      color: AppColors.wordpress,
    ),
    ProjectFramework.unknown: _unknownFramework,
  };

  static const Map<String, BrandSpec> services = {
    'apache': BrandSpec(
      key: 'apache',
      svgAsset: 'assets/brands/services/apache.svg',
      fallbackIcon: Icons.language_outlined,
      color: AppColors.apache,
    ),
    'mysql': BrandSpec(
      key: 'mysql',
      svgAsset: 'assets/brands/services/mysql.svg',
      fallbackIcon: Icons.storage_outlined,
      color: AppColors.mysql,
    ),
    'php': BrandSpec(
      key: 'php',
      svgAsset: 'assets/brands/services/php.svg',
      fallbackIcon: Icons.code_outlined,
      color: AppColors.php,
    ),
    'python': BrandSpec(
      key: 'python',
      svgAsset: 'assets/brands/services/python.svg',
      fallbackIcon: Icons.code_outlined,
      color: AppColors.python,
    ),
    'redis': BrandSpec(
      key: 'redis',
      svgAsset: 'assets/brands/services/redis.svg',
      fallbackIcon: Icons.memory_outlined,
      color: AppColors.redis,
    ),
    'nodejs': BrandSpec(
      key: 'nodejs',
      svgAsset: 'assets/brands/services/nodejs.svg',
      fallbackIcon: Icons.javascript_outlined,
      color: AppColors.nodejs,
    ),
    'postgres': BrandSpec(
      key: 'postgres',
      svgAsset: 'assets/brands/services/postgresql.svg',
      fallbackIcon: Icons.dns_outlined,
      color: Color(0xFF336791),
    ),
    'memcached': BrandSpec(
      key: 'memcached',
      svgAsset: null,
      fallbackIcon: Icons.sd_storage_outlined,
      color: Color(0xFF51B24B),
    ),
    'mailhog': BrandSpec(
      key: 'mailhog',
      svgAsset: null,
      fallbackIcon: Icons.mail_outlined,
      color: Color(0xFFE83D31),
    ),
    'smtp': BrandSpec(
      key: 'smtp',
      svgAsset: null,
      fallbackIcon: Icons.mark_email_unread_outlined,
      color: AppColors.smtp,
    ),
    'websocket': BrandSpec(
      key: 'websocket',
      svgAsset: null,
      fallbackIcon: Icons.cable_outlined,
      color: AppColors.websocket,
    ),
  };

  static BrandSpec framework(ProjectFramework framework) =>
      frameworks[framework] ?? _unknownFramework;

  static BrandSpec service(String key) =>
      services[key] ??
      const BrandSpec(
        key: 'generic',
        svgAsset: null,
        fallbackIcon: Icons.apps_outlined,
        color: AppColors.accent,
      );

  static BrandSpec software(String software) {
    switch (software) {
      case 'PHP':
        return service('php');
      case 'Python':
        return service('python');
      case 'Node.js':
        return service('nodejs');
      case 'MySQL':
        return service('mysql');
      case 'Apache':
        return service('apache');
      case 'Redis':
        return service('redis');
      case 'PostgreSQL':
        return service('postgres');
      case 'Memcached':
        return service('memcached');
      case 'Mailhog':
        return service('mailhog');
      case 'SMTP':
        return service('smtp');
      case 'WebSocket':
        return service('websocket');
      default:
        return service('generic');
    }
  }
}
