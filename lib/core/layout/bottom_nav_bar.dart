import 'dart:ui';
import 'package:flutter/material.dart';

class FloatingBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const FloatingBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      height: 64,
      width: 280,
      decoration: BoxDecoration(
        color: const Color(0xE618181B),
        borderRadius: BorderRadius.circular(32),
        boxShadow: const [
          BoxShadow(
            color: Color(0x3D000000),
            blurRadius: 20,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(32),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _NavBarItem(
                  icon: Icons.home,
                  isActive: currentIndex == 0,
                  onTap: () => onTap(0),
                  tooltip: 'Inicio',
                ),
                _NavBarItem(
                  icon: Icons.map,
                  isActive: currentIndex == 1,
                  onTap: () => onTap(1),
                  tooltip: 'Mapa',
                ),
                _NavBarItem(
                  icon: Icons.directions_bus,
                  isActive: currentIndex == 2,
                  onTap: () => onTap(2),
                  tooltip: 'Autobuses',
                ),
                _NavBarItem(
                  icon: Icons.airport_shuttle,
                  isActive: currentIndex == 3,
                  onTap: () => onTap(3),
                  tooltip: 'Privado',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _NavBarItem extends StatelessWidget {
  final IconData icon;
  final bool isActive;
  final VoidCallback onTap;
  final String tooltip;

  const _NavBarItem({
    required this.icon,
    required this.isActive,
    required this.onTap,
    required this.tooltip,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(24),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: isActive ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(22),
          ),
          child: Icon(
            icon,
            color: isActive
                ? const Color(0xFF18181B)
                : const Color(0xFFA1A1AA),
            size: 24,
          ),
        ),
      ),
    );
  }
}
