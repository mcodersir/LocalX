import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../core/branding/brand_catalog.dart';

class BrandIcon extends StatelessWidget {
  final BrandSpec spec;
  final double size;
  final Color? color;

  const BrandIcon({
    super.key,
    required this.spec,
    this.size = 20,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final iconColor = color ?? spec.color;
    final svg = spec.svgAsset;
    if (svg == null) {
      return Icon(spec.fallbackIcon, size: size, color: iconColor);
    }

    return SvgPicture.asset(
      svg,
      width: size,
      height: size,
      fit: BoxFit.contain,
      placeholderBuilder: (_) =>
          Icon(spec.fallbackIcon, size: size, color: iconColor),
    );
  }
}
