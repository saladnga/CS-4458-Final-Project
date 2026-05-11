import 'package:flutter/material.dart';
import 'package:flutter_final_project/screens/log_feed_screen.dart';
import 'package:flutter_final_project/screens/new_log_screen.dart';
import 'package:flutter_final_project/screens/profile_screen.dart';

class HomeShell extends StatefulWidget {
  const HomeShell({super.key});
  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int _index = 0;
  final _pages = const [LogFeedScreen(), NewLogScreen(), ProfileScreen()];

  // Bottom Navigation Bar Setup
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_index],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _index,
        onTap: (i) => setState(() {
          _index = i;
        }),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.list), label: 'Log Feed'),
          BottomNavigationBarItem(
            icon: Icon(Icons.add_circle),
            label: 'New Entry',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }
}
