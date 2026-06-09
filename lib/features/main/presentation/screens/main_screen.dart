// Pacage imports:
import 'package:flutter/material.dart';

// Core imports:
import '/core/widgets/navigation/bottom_navigation_bar.dart';

// Feature imports:
import '/features/home/presentation/screens/home_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  static const List<NavBarItem> _bottomNavItems = [
    NavBarItem(
      icon: Icons.home_outlined,
      activeIcon: Icons.home,
      label: 'Home',
    ),
    NavBarItem(
      icon: Icons.travel_explore_outlined,
      activeIcon: Icons.travel_explore,
      label: 'Explore',
    ),
    NavBarItem(
      icon: Icons.person_outline,
      activeIcon: Icons.person,
      label: 'Profile',
    ),
  ];

  static const List<Widget> _pages = [HomeScreen(), Scaffold(), Scaffold()];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _selectedIndex, children: _pages),
      bottomNavigationBar: CustomNavigationBar(
        selectedIndex: _selectedIndex,
        items: _bottomNavItems,
        onItemSelected: (i) => setState(() => _selectedIndex = i),
      ),
    );
  }
}
