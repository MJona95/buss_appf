import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import 'pressable_scale.dart';

class CustomCard extends StatelessWidget {
  final Widget child;
  final double borderRadius;
  final Color backgroundColor;
  final Color? borderColor;
  final double borderWidth;
  final List<BoxShadow>? boxShadow;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry? margin;
  final VoidCallback? onTap;

  const CustomCard({
    super.key,
    required this.child,
    this.borderRadius = 24.0,
    this.backgroundColor = Colors.white,
    this.borderColor,
    this.borderWidth = 1.0,
    this.boxShadow,
    this.padding = const EdgeInsets.all(16.0),
    this.margin,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cardBorderColor =
        borderColor ?? AppTheme.borderVariantColor.withValues(alpha: 0.2);
    final cardBoxShadow = boxShadow ??
        [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ];

    Widget cardWidget = AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeOut,
      margin: margin,
      padding: padding,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(
          color: cardBorderColor,
          width: borderWidth,
        ),
        boxShadow: cardBoxShadow,
      ),
      child: child,
    );

    if (onTap != null) {
      return Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(borderRadius),
          child: PressableScale(child: cardWidget),
        ),
      );
    }

    return cardWidget;
  }
}
