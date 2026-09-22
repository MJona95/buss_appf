import 'package:flutter/material.dart';
import 'package:buss_app/features/buses/presentation/screens/buses_screen.dart';
import 'package:buss_app/features/home/presentation/screens/home_screen.dart';
import 'package:buss_app/features/map/presentation/screens/map_screen.dart';
import 'package:buss_app/features/private_transport/presentation/screens/private_transport_screen.dart';
import 'bottom_nav_bar.dart';

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
