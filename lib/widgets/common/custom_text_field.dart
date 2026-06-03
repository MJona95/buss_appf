import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

class SearchTextField extends StatelessWidget {
  final String placeholder;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onFilterPressed;
  final TextEditingController? controller;

  const SearchTextField({
    super.key,
    required this.placeholder,
    this.onChanged,
    this.onFilterPressed,
    this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Container(
            height: 56,
            decoration: BoxDecoration(
              color: AppTheme.surfaceContainerLow,
              borderRadius: BorderRadius.circular(28),
              border: Border.all(
                color: AppTheme.borderVariantColor.withOpacity(0.1),
                width: 1.0,
              ),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                const Icon(
                  Icons.search,
                  color: AppTheme.secondaryColor,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    controller: controller,
                    onChanged: onChanged,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: AppTheme.onBackgroundColor,
                    ),
                    decoration: InputDecoration(
                      hintText: placeholder,
                      hintStyle: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: AppTheme.secondaryColor.withOpacity(0.6),
                      ),
                      border: InputBorder.none,
                      isDense: true,
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        if (onFilterPressed != null) ...[
          const SizedBox(width: 12),
          InkWell(
            onTap: onFilterPressed,
            borderRadius: BorderRadius.circular(16),
            child: Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: AppTheme.surfaceContainerLow,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: AppTheme.borderVariantColor.withOpacity(0.1),
                  width: 1.0,
                ),
              ),
              child: const Icon(
                Icons.tune,
                color: AppTheme.primaryColor,
                size: 24,
              ),
            ),
          ),
        ],
      ],
    );
  }
}

class CustomTextField extends StatelessWidget {
  final String label;
  final String placeholder;
  final ValueChanged<String>? onChanged;
  final TextEditingController? controller;
  final TextInputType keyboardType;
  final IconData? prefixIcon;
  final bool readOnly;
  final VoidCallback? onTap;

  const CustomTextField({
    super.key,
    required this.label,
    required this.placeholder,
    this.onChanged,
    this.controller,
    this.keyboardType = TextInputType.text,
    this.prefixIcon,
    this.readOnly = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label.isNotEmpty) ...[
          Row(
            children: [
              if (prefixIcon != null) ...[
                Icon(
                  prefixIcon,
                  size: 16,
                  color: AppTheme.secondaryColor,
                ),
                const SizedBox(width: 4),
              ],
              Text(
                label,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.secondaryColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
        ],
        Container(
          decoration: BoxDecoration(
            color: AppTheme.surfaceContainerLow,
            borderRadius: BorderRadius.circular(AppTheme.elementRadius),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: TextField(
            controller: controller,
            onChanged: onChanged,
            keyboardType: keyboardType,
            readOnly: readOnly,
            onTap: onTap,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: AppTheme.onBackgroundColor,
            ),
            decoration: InputDecoration(
              hintText: placeholder,
              hintStyle: TextStyle(
                fontSize: 14,
                color: AppTheme.secondaryColor.withOpacity(0.5),
              ),
              border: InputBorder.none,
            ),
          ),
        ),
      ],
    );
  }
}
