import 'package:flutter/material.dart';
import 'widgets/nav_bar.dart';
import 'screens/home_screen.dart';
import 'screens/about_screen.dart';
import 'screens/events_screen.dart';
import 'screens/jobs_screen.dart';
import 'screens/services_screen.dart';
import 'screens/gallery_screen.dart';
import 'screens/village_map_screen.dart';
import 'screens/farming_screen.dart';
import 'screens/quiz_screen.dart';

class MainLayout extends StatefulWidget {
  const MainLayout({super.key});

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    const HomeScreen(),
    const AboutScreen(),
    const EventsScreen(),
    const JobsScreen(),
    const ServicesScreen(),
    const GalleryScreen(),
    const VillageMapScreen(),
    const FarmingScreen(),
    const QuizScreen(),
  ];

  void _onDestinationSelected(int index) {
    setState(() {
      _selectedIndex = index;
    });
    if (MediaQuery.of(context).size.width <= 800) {
      Navigator.pop(context); // Close drawer if mobile
    }
  }

  @override
  Widget build(BuildContext context) {
    bool isMobile = MediaQuery.of(context).size.width <= 800;

    return Scaffold(
      appBar: VillageNavBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: _onDestinationSelected,
      ),
      drawer: isMobile
          ? VillageDrawer(
              selectedIndex: _selectedIndex,
              onDestinationSelected: _onDestinationSelected,
            )
          : null,
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 400),
        child: _screens[_selectedIndex],
        transitionBuilder: (Widget child, Animation<double> animation) {
          return FadeTransition(opacity: animation, child: child);
        },
      ),
    );
  }
}
