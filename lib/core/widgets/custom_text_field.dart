import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import 'pressable_scale.dart';

class SearchTextField extends StatefulWidget {
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
  State<SearchTextField> createState() => _SearchTextFieldState();
}

class _SearchTextFieldState extends State<SearchTextField> {
  final FocusNode _focusNode = FocusNode();
  bool _focused = false;

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(_onFocusChanged);
  }

  void _onFocusChanged() {
    final focused = _focusNode.hasFocus;
    if (_focused == focused) return;
    setState(() => _focused = focused);
  }

  @override
  void dispose() {
    _focusNode.removeListener(_onFocusChanged);
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 220),
            curve: Curves.easeOutCubic,
            height: 56,
            decoration: BoxDecoration(
              color: AppTheme.surfaceContainerLow,
              borderRadius: BorderRadius.circular(28),
              border: Border.all(
                color: _focused
                    ? AppTheme.primaryColor
                    : AppTheme.borderVariantColor.withValues(alpha: 0.1),
                width: 1.5,
              ),
              boxShadow: _focused
                  ? [
                      BoxShadow(
                        color: AppTheme.primaryColor.withValues(alpha: 0.12),
                        blurRadius: 16,
                        offset: const Offset(0, 6),
                      ),
                    ]
                  : null,
            ),
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                Icon(
                  Icons.search,
                  color: _focused
                      ? AppTheme.primaryColor
                      : AppTheme.secondaryColor,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    controller: widget.controller,
                    focusNode: _focusNode,
                    onChanged: widget.onChanged,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: AppTheme.onBackgroundColor,
                    ),
                    decoration: InputDecoration(
                      hintText: widget.placeholder,
                      hintStyle: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: AppTheme.secondaryColor.withValues(alpha: 0.6),
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
        if (widget.onFilterPressed != null) ...[
          const SizedBox(width: 12),
          PressableScale(
            pressedScale: 0.9,
            child: InkWell(
              onTap: widget.onFilterPressed,
              borderRadius: BorderRadius.circular(16),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 220),
                curve: Curves.easeOutCubic,
                width: 56,
                height: 56,
                decoration: BoxDecoration(
color: _focused
                    ? AppTheme.primaryColor.withValues(alpha: 0.08)
                    : AppTheme.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: _focused
                        ? AppTheme.primaryColor.withValues(alpha: 0.35)
                        : AppTheme.borderVariantColor.withValues(alpha: 0.1),
                    width: 1.0,
                  ),
                ),
                child: Icon(
                  Icons.tune,
                  color: _focused
                      ? AppTheme.primaryColor
                      : AppTheme.primaryColor,
                  size: 24,
                ),
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
                Icon(prefixIcon, size: 16, color: AppTheme.secondaryColor),
                const SizedBox(width: 4),
              ],
              Expanded(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.secondaryColor,
                  ),
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
                color: AppTheme.secondaryColor.withValues(alpha: 0.5),
              ),
              border: InputBorder.none,
            ),
          ),
        ),
      ],
    );
  }
}
