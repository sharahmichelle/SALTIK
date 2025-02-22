import 'package:flutter/material.dart';
import '../screens/reservoir.dart';
import '../screens/ponds.dart';
import '../screens/history.dart';
import '../screens/profile.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({Key? key}) : super(key: key);

  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    const ReservoirPage(),
    const PondPage(),
    const HistoryPage(),
    const ProfilePage(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: _pages,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
        onTap: _onItemTapped,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.propane_tank),
            activeIcon: Icon(Icons.propane_tank_outlined),
            label: 'Reservoir',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.circle_rounded),
            activeIcon: Icon(Icons.circle_outlined),
            label: 'Pond',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.timelapse),
            activeIcon: Icon(Icons.timelapse_outlined),
            label: 'History',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}