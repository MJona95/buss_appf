import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

class CustomBadge extends StatelessWidget {
  final String label;
  final bool isSuccess; // green/black style or grayscale style
  final Color? backgroundColor;
  final Color? textColor;
  final Widget? leading;
  final bool showDot;

  const CustomBadge({
    super.key,
    required this.label,
    this.isSuccess = true,
    this.backgroundColor,
    this.textColor,
    this.leading,
    this.showDot = true,
  });

  @override
  Widget build(BuildContext context) {
    final defaultBg = isSuccess
        ? Colors.black.withOpacity(0.75)
        : AppTheme.surfaceContainerHigh.withOpacity(0.85);

    final defaultText = isSuccess
        ? Colors.white
        : AppTheme.primaryColor;

    final defaultDotColor = isSuccess
        ? Colors.greenAccent
        : AppTheme.secondaryColor;

    return Container(
      decoration: BoxDecoration(
        color: backgroundColor ?? defaultBg,
        borderRadius: BorderRadius.circular(20),
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 6,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (showDot) ...[
            leading ?? Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: defaultDotColor,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 6),
          ],
          Text(
            label,
            style: TextStyle(
              color: textColor ?? defaultText,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
