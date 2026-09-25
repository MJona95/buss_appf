import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:buss_app/core/theme/app_theme.dart';
import 'package:buss_app/core/theme/theme_controller.dart';
import 'package:buss_app/core/widgets/custom_avatar.dart';
import 'package:buss_app/core/widgets/pressable_scale.dart';

class CustomAppDrawer extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onNavigate;

  const CustomAppDrawer({
    super.key,
    required this.currentIndex,
    required this.onNavigate,
  });

  static const _sectionTitles = ['Inicio', 'Mapa', 'Unidades', 'Privado'];
  static const _sectionIcons = [
    Icons.home_rounded,
    Icons.map_rounded,
    Icons.directions_bus_rounded,
    Icons.local_taxi_rounded,
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 296,
      decoration: const BoxDecoration(
        color: AppTheme.surfaceContainerLow,
        boxShadow: [BoxShadow(color: Color(0x33FFFFFF), blurRadius: 0)],
      ),
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  const CustomAvatar(
                    imageUrl: CustomAvatar.defaultImageUrl,
                    size: 48,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'BussApp',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            letterSpacing: -0.4,
                            color: AppTheme.primaryColor,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Tu viaje, un toque',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: AppTheme.secondaryColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                  PressableScale(
                    pressedScale: 0.88,
                    child: IconButton(
                      icon: const Icon(
                        Icons.close_rounded,
                        color: AppTheme.onBackgroundColor,
                      ),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            const Divider(
              height: 24,
              indent: 20,
              endIndent: 20,
              color: AppTheme.borderVariantColor,
            ),
            const SizedBox(height: 8),
            for (var i = 0; i < _sectionTitles.length; i++)
              _DrawerItem(
                icon: _sectionIcons[i],
                label: _sectionTitles[i],
                isSelected: i == currentIndex,
                isLast: i == _sectionTitles.length - 1,
                onTap: () {
                  onNavigate(i);
                  Navigator.of(context).pop();
                },
              ),
            const Spacer(),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Divider(height: 1, color: AppTheme.borderVariantColor),
            ),
            const SizedBox(height: 4),
            Consumer<ThemeController>(
              builder: (context, themeController, _) {
                return SwitchListTile(
                  value: themeController.isDarkMode,
                  onChanged: (_) => themeController.toggle(),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 24),
                  secondary: const Icon(
                    Icons.dark_mode_outlined,
                    color: AppTheme.secondaryColor,
                  ),
                  title: const Text(
                    'Modo oscuro',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.onBackgroundColor,
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 12),
            const Padding(
              padding: EdgeInsets.only(bottom: 24),
              child: Text(
                'BussApp v1.0.0',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 12, color: AppTheme.secondaryColor),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DrawerItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final bool isLast;
  final VoidCallback onTap;

  const _DrawerItem({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.isLast,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(left: 20, right: 20, bottom: isLast ? 0 : 8),
      child: Material(
        color: isSelected ? AppTheme.primaryColor : Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                Icon(
                  icon,
                  color: isSelected ? Colors.white : AppTheme.primaryColor,
                  size: 22,
                ),
                const SizedBox(width: 14),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: isSelected
                        ? Colors.white
                        : AppTheme.onBackgroundColor,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
