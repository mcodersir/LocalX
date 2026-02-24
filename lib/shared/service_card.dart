import 'package:flutter/material.dart';
import '../core/branding/brand_catalog.dart';
import '../core/theme/app_colors.dart';
import '../core/services/process_manager.dart';
import 'brand_icon.dart';

class ServiceCard extends StatefulWidget {
  final String title;
  final String subtitle;
  final BrandSpec brand;
  final Color brandColor;
  final ServiceStatus status;
  final VoidCallback onToggle;
  final VoidCallback? onSettings;
  final bool enabled;
  final String? disabledReason;
  final VoidCallback? onInstall;
  final String? version;
  final bool isInstalling;

  const ServiceCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.brand,
    required this.brandColor,
    required this.status,
    required this.onToggle,
    this.onSettings,
    this.enabled = true,
    this.disabledReason,
    this.onInstall,
    this.version,
    this.isInstalling = false,
  });

  @override
  State<ServiceCard> createState() => _ServiceCardState();
}

class _ServiceCardState extends State<ServiceCard> with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;
  bool _isHovered = false;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    _pulseAnimation = Tween<double>(begin: 0.4, end: 1.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
    if (widget.status == ServiceStatus.running) {
      _pulseController.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(ServiceCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.status == ServiceStatus.running) {
      _pulseController.repeat(reverse: true);
    } else {
      _pulseController.stop();
      _pulseController.reset();
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  Color get _statusColor {
    switch (widget.status) {
      case ServiceStatus.running: return AppColors.running;
      case ServiceStatus.starting:
      case ServiceStatus.stopping: return AppColors.warning;
      case ServiceStatus.error: return AppColors.stopped;
      case ServiceStatus.stopped: return AppColors.darkTextMuted;
    }
  }

  String get _statusLabel {
    switch (widget.status) {
      case ServiceStatus.running: return 'Running';
      case ServiceStatus.starting: return 'Starting...';
      case ServiceStatus.stopping: return 'Stopping...';
      case ServiceStatus.error: return 'Error';
      case ServiceStatus.stopped: return 'Stopped';
    }
  }

  bool get _isLoading =>
      widget.status == ServiceStatus.starting || widget.status == ServiceStatus.stopping;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final borderColor = isDark ? AppColors.darkBorder : AppColors.lightBorder;
    final cardBg = isDark ? AppColors.darkCard : AppColors.lightCard;
    final textColor = isDark ? AppColors.darkText : AppColors.lightText;
    final subtitleColor = isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: cardBg,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: _isHovered
                ? widget.brandColor.withValues(alpha: 0.5)
                : borderColor,
            width: _isHovered ? 1.5 : 1,
          ),
          boxShadow: _isHovered
              ? [BoxShadow(color: widget.brandColor.withValues(alpha: 0.08), blurRadius: 20, spreadRadius: 2)]
              : [],
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: widget.brandColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: widget.brandColor.withValues(alpha: 0.2)),
                    ),
                    child: Center(child: BrandIcon(spec: widget.brand, size: 22)),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(widget.title, style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: textColor,
                        )),
                        const SizedBox(height: 2),
                        Text(
                          widget.version != null ? 'v${widget.version}' : widget.subtitle,
                          style: TextStyle(fontSize: 12, color: subtitleColor),
                        ),
                      ],
                    ),
                  ),
                  if (widget.onSettings != null)
                    IconButton(
                      icon: Icon(Icons.settings_outlined, size: 18, color: subtitleColor),
                      onPressed: widget.onSettings,
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                    ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  AnimatedBuilder(
                    animation: _pulseAnimation,
                    builder: (context, child) {
                      return Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: _statusColor.withValues(
                            alpha: widget.status == ServiceStatus.running
                                ? _pulseAnimation.value
                                : 1.0,
                          ),
                          boxShadow: widget.status == ServiceStatus.running
                              ? [BoxShadow(color: _statusColor.withValues(alpha: 0.5), blurRadius: 6)]
                              : [],
                        ),
                      );
                    },
                  ),
                  const SizedBox(width: 8),
                  Text(
                    _statusLabel,
                    style: TextStyle(fontSize: 12, color: _statusColor, fontWeight: FontWeight.w500),
                  ),
                  if (!widget.enabled) ...[
                    const SizedBox(width: 10),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: AppColors.warning.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: AppColors.warning.withValues(alpha: 0.3)),
                      ),
                      child: Text(
                        widget.disabledReason ?? 'Not installed',
                        style: const TextStyle(fontSize: 10, color: AppColors.warning, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ],
                  const Spacer(),
                  SizedBox(
                    height: 34,
                    child: _isLoading
                        ? SizedBox(
                            width: 34,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation(widget.brandColor),
                            ),
                          )
                        : widget.enabled
                            ? OutlinedButton(
                                onPressed: widget.onToggle,
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: widget.status == ServiceStatus.running
                                      ? AppColors.stopped
                                      : AppColors.running,
                                  side: BorderSide(
                                    color: widget.status == ServiceStatus.running
                                        ? AppColors.stopped.withValues(alpha: 0.4)
                                        : AppColors.running.withValues(alpha: 0.4),
                                  ),
                                  padding: const EdgeInsets.symmetric(horizontal: 16),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                child: Text(
                                  widget.status == ServiceStatus.running ? 'Stop' : 'Start',
                                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                                ),
                              )
                            : OutlinedButton(
                                onPressed: widget.isInstalling ? null : widget.onInstall,
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: AppColors.warning,
                                  side: BorderSide(color: AppColors.warning.withValues(alpha: 0.4)),
                                  padding: const EdgeInsets.symmetric(horizontal: 16),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                child: widget.isInstalling
                                    ? Row(mainAxisSize: MainAxisSize.min, children: const [
                                        SizedBox(width: 12, height: 12, child: CircularProgressIndicator(strokeWidth: 2)),
                                        SizedBox(width: 6),
                                        Text('Installing...', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                                      ])
                                    : const Text('Install', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
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
}
