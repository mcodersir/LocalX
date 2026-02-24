import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/services/php_extension_manager.dart';

class PhpExtensionsDialog extends StatelessWidget {
  final String phpPath;
  const PhpExtensionsDialog({super.key, required this.phpPath});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => PhpExtensionManager(phpPath),
      child: const _PhpExtensionsDialogView(),
    );
  }
}

class _PhpExtensionsDialogView extends StatefulWidget {
  const _PhpExtensionsDialogView();

  @override
  State<_PhpExtensionsDialogView> createState() => _PhpExtensionsDialogViewState();
}

class _PhpExtensionsDialogViewState extends State<_PhpExtensionsDialogView> {
  final TextEditingController _searchCtrl = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? AppColors.darkBackground : AppColors.lightBackground;
    final brd = isDark ? AppColors.darkBorder : AppColors.lightBorder;
    final txt = isDark ? AppColors.darkText : AppColors.lightText;
    final sub = isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;

    final manager = context.watch<PhpExtensionManager>();

    List<PhpExtension> displayed = manager.extensions;
    if (_query.isNotEmpty) {
      displayed = displayed.where((e) => e.name.toLowerCase().contains(_query.toLowerCase())).toList();
    }

    return Dialog(
      backgroundColor: bg,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        width: 500,
        height: 600,
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 40, height: 40,
                  decoration: BoxDecoration(color: AppColors.php.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(10)),
                  child: const Icon(Icons.code_outlined, color: AppColors.php, size: 20),
                ),
                const SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('PHP Extensions', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: txt)),
                    const Text('Toggle extensions in php.ini', style: TextStyle(fontSize: 12, color: AppColors.php)),
                  ],
                ),
                const Spacer(),
                IconButton(
                  icon: Icon(Icons.close, color: sub),
                  onPressed: () => Navigator.pop(context),
                )
              ],
            ),
            const SizedBox(height: 20),
            
            // Search Bar
            TextField(
              controller: _searchCtrl,
              onChanged: (v) => setState(() => _query = v),
              style: TextStyle(color: txt, fontSize: 14),
              decoration: InputDecoration(
                hintText: 'Search extensions...',
                hintStyle: TextStyle(color: sub),
                prefixIcon: Icon(Icons.search, color: sub, size: 18),
                filled: true,
                fillColor: isDark ? AppColors.darkSurface : AppColors.lightSurface,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: brd)),
                enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: brd)),
                focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: AppColors.php)),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
            ),
            const SizedBox(height: 16),

            if (manager.error != null)
              Container(
                padding: const EdgeInsets.all(12),
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(color: AppColors.warning.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8), border: Border.all(color: AppColors.warning.withValues(alpha: 0.3))),
                child: Row(
                  children: [
                    const Icon(Icons.warning_amber_rounded, color: AppColors.warning, size: 18),
                    const SizedBox(width: 8),
                    Expanded(child: Text(manager.error!, style: const TextStyle(color: AppColors.warning, fontSize: 12))),
                  ],
                ),
              ),

            // List
            Expanded(
              child: manager.isLoading
                  ? const Center(child: CircularProgressIndicator(color: AppColors.php))
                  : displayed.isEmpty
                      ? Center(child: Text('No extensions found', style: TextStyle(color: sub)))
                      : ListView.builder(
                          itemCount: displayed.length,
                          itemBuilder: (ctx, i) {
                            final ext = displayed[i];
                            return Container(
                              margin: const EdgeInsets.only(bottom: 8),
                              decoration: BoxDecoration(
                                color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(color: brd),
                              ),
                              child: SwitchListTile(
                                title: Text(ext.name, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: txt)),
                                subtitle: Text(ext.isEnabled ? 'Enabled' : 'Disabled', style: TextStyle(fontSize: 12, color: sub)),
                                value: ext.isEnabled,
                                activeThumbColor: AppColors.php,
                                onChanged: (val) {
                                  manager.toggleExtension(ext.name, val);
                                },
                              ),
                            );
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }
}
