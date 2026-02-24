import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';
import '../core/services/translation_service.dart';

class SidebarNav extends StatefulWidget {
  final int selectedIndex;
  final ValueChanged<int> onItemSelected;

  const SidebarNav({
    super.key,
    required this.selectedIndex,
    required this.onItemSelected,
  });

  @override
  State<SidebarNav> createState() => _SidebarNavState();
}

class _SidebarNavState extends State<SidebarNav> {
  int? _hoveredIndex;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? AppColors.darkSidebar : AppColors.lightSidebar;
    final borderColor = isDark ? AppColors.darkBorder : AppColors.lightBorder;
    final accentColor = isDark ? AppColors.accent : AppColors.accentIndigo;

    final navItems = [
      _NavItem(Icons.dashboard_outlined, Icons.dashboard, context.tr('dashboard')),
      _NavItem(Icons.folder_outlined, Icons.folder, context.tr('projects')),
      _NavItem(Icons.dns_outlined, Icons.dns, context.tr('services')),
      _NavItem(Icons.auto_fix_high_outlined, Icons.auto_fix_high, context.tr('wizard')),
      _NavItem(Icons.system_update_alt_outlined, Icons.system_update_alt, context.tr('version_manager')),
      _NavItem(Icons.settings_outlined, Icons.settings, context.tr('settings')),
    ];

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      width: 72,
      decoration: BoxDecoration(
        color: bgColor,
        border: Border(
          right: Directionality.of(context) == TextDirection.ltr
              ? BorderSide(color: borderColor, width: 1)
              : BorderSide.none,
          left: Directionality.of(context) == TextDirection.rtl
              ? BorderSide(color: borderColor, width: 1)
              : BorderSide.none,
        ),
      ),
      child: Column(
        children: [
          const SizedBox(height: 16),
          // Logo
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: AppColors.brandDark,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Center(
              child: Text(
                'LX',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.5,
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),
          // Nav items
          Expanded(
            child: ListView.builder(
              itemCount: navItems.length,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              itemBuilder: (context, index) {
                final item = navItems[index];
                final isSelected = widget.selectedIndex == index;
                final isHovered = _hoveredIndex == index;

                return Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: MouseRegion(
                    onEnter: (_) => setState(() => _hoveredIndex = index),
                    onExit: (_) => setState(() => _hoveredIndex = null),
                    child: GestureDetector(
                      onTap: () => widget.onItemSelected(index),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: isSelected
                              ? accentColor.withValues(alpha: 0.12)
                              : isHovered
                                  ? (isDark ? Colors.white.withValues(alpha: 0.05) : Colors.black.withValues(alpha: 0.04))
                                  : Colors.transparent,
                          borderRadius: BorderRadius.circular(12),
                          border: isSelected
                              ? Border.all(color: accentColor.withValues(alpha: 0.3))
                              : null,
                        ),
                        child: Tooltip(
                          message: item.label,
                          preferBelow: false,
                          waitDuration: const Duration(milliseconds: 500),
                          child: Icon(
                            isSelected ? item.activeIcon : item.icon,
                            color: isSelected
                                ? accentColor
                                : isHovered
                                    ? (isDark ? AppColors.darkText : AppColors.lightText)
                                    : (isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary),
                            size: 22,
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          // Bottom indicator
          Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _NavItem {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  const _NavItem(this.icon, this.activeIcon, this.label);
}
