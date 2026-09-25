import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class CustomAvatar extends StatelessWidget {
  static const defaultImageUrl =
      'https://lh3.googleusercontent.com/aida-public/AB6AXuBYWVZyhzmuT3XnSb3UR4urlHPLCPr18MIYPkGz9bwUFVPbCENoY31O5ZbhbeuT5iLLw1ZuPiGthmTU4K_2CS2WPzWjHssoyd2bJlZa0Ub96OjVJnL2MfXL6L4UBYUtF_JmS6UNtfVZUmxYW6UWP8Oq_VmwwNCuyDw5dQNFd28BVrRDgPCRiNykgB_iZQDTLe05yigOovx7CxKCc13P6MMVxaqZBB7adOJsPAiARcYKUeAHao8Yn1DxSGCC1L56pgcJJHDt4WCqJ7Ar';
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
      ),
      clipBehavior: Clip.antiAlias,
      child: Image.network(
        imageUrl,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return ColoredBox(
            color: AppTheme.surfaceContainer,
            child: Icon(
              Icons.person,
              size: size * 0.55,
              color: AppTheme.secondaryColor,
            ),
          );
        },
      ),
    );
  }
}
