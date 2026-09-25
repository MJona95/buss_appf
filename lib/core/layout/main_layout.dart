import 'package:flutter/material.dart';
import 'package:buss_app/features/buses/presentation/screens/buses_screen.dart';
import 'package:buss_app/features/home/presentation/screens/home_screen.dart';
import 'package:buss_app/features/map/presentation/screens/map_screen.dart';
import 'package:buss_app/features/private_transport/presentation/screens/private_transport_screen.dart';
import '../widgets/custom_app_drawer.dart';
import 'bottom_nav_bar.dart';

class MainNavigationContainer extends StatefulWidget {
  const MainNavigationContainer({super.key});

  @override
  State<MainNavigationContainer> createState() =>
      _MainNavigationContainerState();
}

class _MainNavigationContainerState extends State<MainNavigationContainer> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  int _currentIndex = 0;

  void _openDrawer() => _scaffoldKey.currentState?.openDrawer();

  void _selectSection(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final keyboardVisible = MediaQuery.viewInsetsOf(context).bottom > 0;
    return Scaffold(
      key: _scaffoldKey,
      drawer: CustomAppDrawer(
        currentIndex: _currentIndex,
        onNavigate: _selectSection,
      ),
      extendBody: true,
      body: Stack(
        children: [
          IndexedStack(
            index: _currentIndex,
            children: [
              _TabFadeIn(
                isActive: _currentIndex == 0,
                child: HomeScreen(
                  onMenuPressed: _openDrawer,
                  onSearchPressed: () {
                    setState(() {
                      _currentIndex = 1;
                    });
                  },
                ),
              ),
              _TabFadeIn(
                isActive: _currentIndex == 1,
                child: MapScreen(
                  isActive: _currentIndex == 1,
                  onMenuPressed: _openDrawer,
                ),
              ),
              _TabFadeIn(
                isActive: _currentIndex == 2,
                child: BusesScreen(onMenuPressed: _openDrawer),
              ),
              _TabFadeIn(
                isActive: _currentIndex == 3,
                child: PrivateTransportScreen(onMenuPressed: _openDrawer),
              ),
            ],
          ),
          AnimatedSlide(
            duration: const Duration(milliseconds: 220),
            curve: Curves.easeInOut,
            offset: keyboardVisible ? const Offset(0, 1.4) : Offset.zero,
            child: AnimatedOpacity(
              duration: const Duration(milliseconds: 220),
              opacity: keyboardVisible ? 0 : 1,
              child: Align(
                alignment: Alignment.bottomCenter,
                child: FloatingBottomNavBar(
                  currentIndex: _currentIndex,
                  onTap: (index) {
                    setState(() {
                      _currentIndex = index;
                    });
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TabFadeIn extends StatefulWidget {
  final bool isActive;
  final Widget child;

  const _TabFadeIn({required this.isActive, required this.child});

  @override
  State<_TabFadeIn> createState() => _TabFadeInState();
}

class _TabFadeInState extends State<_TabFadeIn>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _opacity;
  late final Animation<Offset> _slide;
  bool _wasActive = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 280),
      value: widget.isActive ? 1.0 : 0.0,
    );
    _opacity = CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic);
    _slide = Tween<Offset>(
      begin: const Offset(0, 0.03),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));
    _wasActive = widget.isActive;
  }

  @override
  void didUpdateWidget(covariant _TabFadeIn oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isActive != _wasActive) {
      _wasActive = widget.isActive;
      if (widget.isActive) {
        _controller.forward(from: 0);
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _opacity,
      child: SlideTransition(position: _slide, child: widget.child),
    );
  }
}
