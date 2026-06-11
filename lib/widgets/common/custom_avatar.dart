import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

class CustomAvatar extends StatelessWidget {
  final String imageUrl;
  final double size;
  final double borderWidth;
  final Color? borderColor;

  const CustomAvatar({
    super.key,
    required this.imageUrl,
    this.size = 40.0,
    this.borderWidth = 1.0,
    this.borderColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: borderColor ?? AppTheme.borderVariantColor.withOpacity(0.3),
          width: borderWidth,
        ),
        image: DecorationImage(
          image: NetworkImage(imageUrl),
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}
