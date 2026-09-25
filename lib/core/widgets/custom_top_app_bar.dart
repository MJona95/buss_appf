import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import 'custom_avatar.dart';
import 'pressable_scale.dart';

class CustomTopAppBar extends StatelessWidget implements PreferredSizeWidget {
  static const String defaultProfileImageUrl = CustomAvatar.defaultImageUrl;

  final String? title;
  final bool showSearch;
  final VoidCallback? onSearchPressed;
  final VoidCallback? onMenuPressed;
  final String profileImageUrl;
  final double height;

  const CustomTopAppBar({
    super.key,
    this.title,
    this.showSearch = true,
    this.onSearchPressed,
    this.onMenuPressed,
    this.profileImageUrl = defaultProfileImageUrl,
    this.height = 56.0,
  });

  @override
  Size get preferredSize => Size.fromHeight(height);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: const BoxDecoration(
                color: AppTheme.surfaceContainer,
                shape: BoxShape.circle,
              ),
              child: PressableScale(
                pressedScale: 0.88,
                child: IconButton(
                  icon: const Icon(
                    Icons.menu,
                    color: AppTheme.onBackgroundColor,
                  ),
                  onPressed: onMenuPressed ?? () {},
                ),
              ),
            ),
            if (title != null && title!.isNotEmpty) ...[
              const SizedBox(width: 16),
              Text(
                title!,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.4,
                  color: AppTheme.primaryColor,
                ),
              ),
            ],
          ],
        ),
        Row(
          children: [
            if (showSearch) ...[
              Container(
                width: 48,
                height: 48,
                decoration: const BoxDecoration(
                  color: AppTheme.surfaceContainer,
                  shape: BoxShape.circle,
                ),
                child: PressableScale(
                  pressedScale: 0.88,
                  child: IconButton(
                    icon: const Icon(
                      Icons.search,
                      color: AppTheme.onBackgroundColor,
                    ),
                    onPressed: onSearchPressed,
                  ),
                ),
              ),
              const SizedBox(width: 12),
            ],
            CustomAvatar(imageUrl: profileImageUrl, size: 40),
          ],
        ),
      ],
    );
  }
}
