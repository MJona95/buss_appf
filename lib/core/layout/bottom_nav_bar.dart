import 'dart:ui';
import 'package:flutter/material.dart';
import '../widgets/pressable_scale.dart';

class FloatingBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const FloatingBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  static const int _itemCount = 4;
  static const double _height = 64;

  @override
  Widget build(BuildContext context) {
    const horizontalPadding = 8.0;
    final itemWidth = (280 - horizontalPadding * 2) / _itemCount;

    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      height: _height,
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
          child: Stack(
            children: [
              AnimatedPositioned(
                duration: const Duration(milliseconds: 350),
                curve: const _NavBounceCurve(),
                left: horizontalPadding + currentIndex * itemWidth,
                top: 10,
                width: itemWidth,
                height: _height - 20,
                child: Center(
                  child: Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(22),
                    ),
                  ),
                ),
              ),
              Align(
                alignment: Alignment.center,
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
            ],
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
      child: PressableScale(
        pressedScale: 0.85,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(24),
          child: SizedBox(
            width: 44,
            height: 44,
            child: AnimatedScale(
              scale: isActive ? 1.12 : 1.0,
              duration: const Duration(milliseconds: 500),
              curve: const _NavBounceCurve(),
              child: Center(
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  transitionBuilder: (child, animation) =>
                      ScaleTransition(
                    scale: animation,
                    child: FadeTransition(
                      opacity: animation,
                      child: child,
                    ),
                  ),
                  child: Icon(
                    icon,
                    key: ValueKey(isActive),
                    color: isActive
                        ? const Color(0xFF18181B)
                        : const Color(0xFFA1A1AA),
                    size: 24,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _NavBounceCurve extends Curve {
  const _NavBounceCurve();

  @override
  double transformInternal(double t) {
    const overshoot = 1.2;
    final s = overshoot + 1;
    final u = t - 1;
    return u * u * ((s + 1) * u + s) + 1;
  }
}