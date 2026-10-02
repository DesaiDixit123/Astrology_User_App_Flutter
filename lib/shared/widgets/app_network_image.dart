import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../core/constants/api_constants.dart';
import '../../core/theme/app_colors.dart';

class AppNetworkImage extends StatelessWidget {
  final String? url;
  final double? width;
  final double? height;
  final BoxFit fit;
  final BorderRadius? borderRadius;
  final IconData fallbackIcon;
  final Widget? placeholder;
  final Widget? fallbackWidget;

  const AppNetworkImage({
    super.key,
    required this.url,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.borderRadius,
    this.fallbackIcon = Icons.image_outlined,
    this.placeholder,
    this.fallbackWidget,
  });

  @override
  Widget build(BuildContext context) {
    final resolvedUrl = ApiConstants.resolveImage(url ?? '');

    Widget defaultFallback() {
      return Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          borderRadius: borderRadius,
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFFFDF8EE),
              Color(0xFFF3E7D3),
            ],
          ),
        ),
        child: Center(
          child: Icon(
            fallbackIcon,
            size: (width != null && height != null)
                ? (width! < height! ? width! * 0.4 : height! * 0.4).clamp(18.0, 52.0)
                : 34.0,
            color: AppColors.primary.withValues(alpha: 0.6),
          ),
        ),
      );
    }

    if (resolvedUrl.isEmpty) {
      return fallbackWidget ?? defaultFallback();
    }

    Widget imageWidget = CachedNetworkImage(
      imageUrl: resolvedUrl,
      width: width,
      height: height,
      fit: fit,
      placeholder: (context, _) =>
          placeholder ??
          Container(
            width: width,
            height: height,
            color: Colors.grey.shade100,
            child: const Center(
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
          ),
      errorWidget: (context, _, err) => fallbackWidget ?? defaultFallback(),
    );

    if (borderRadius != null) {
      imageWidget = ClipRRect(
        borderRadius: borderRadius!,
        child: imageWidget,
      );
    }

    return imageWidget;
  }
}
