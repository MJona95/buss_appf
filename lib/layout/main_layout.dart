import 'package:flutter/material.dart';
import 'bottom_nav_bar.dart';
import '../screens/buses_screen.dart';
import '../screens/home_screen.dart';
import '../screens/map_screen.dart';
import '../screens/private_transport_screen.dart';

class MainNavigationContainer extends StatefulWidget {
  const MainNavigationContainer({super.key});

  @override
  State<MainNavigationContainer> createState() =>
      _MainNavigationContainerState();
}

class _MainNavigationContainerState extends State<MainNavigationContainer> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      body: Stack(
        children: [
          IndexedStack(
            index: _currentIndex,
            children: [
              HomeScreen(
                onSearchPressed: () {
                  setState(() {
                    _currentIndex = 1;
                  });
                },
              ),
              MapScreen(isActive: _currentIndex == 1),
              const BusesScreen(),
              const PrivateTransportScreen(),
            ],
          ),
          Align(
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
        ],
      ),
    );
  }
}
