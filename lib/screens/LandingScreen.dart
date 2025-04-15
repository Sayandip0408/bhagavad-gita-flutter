import 'package:bhagavad_gita/screens/AboutScreen.dart';
import 'package:bhagavad_gita/screens/ChaptersScreen.dart';
import 'package:bhagavad_gita/screens/HomeScreen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class LandingScreen extends StatefulWidget {
  const LandingScreen({super.key});

  @override
  State<LandingScreen> createState() => _LandingScreenState();
}

class _LandingScreenState extends State<LandingScreen> {
  int currentPageIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: NavigationBar(
        // backgroundColor: Color(0xFF101110),
        backgroundColor: Colors.white,
        onDestinationSelected: (int index) {
          setState(() {
            currentPageIndex = index;
          });
        },
        indicatorColor: Color(0xFF101110),
        selectedIndex: currentPageIndex,
        destinations: const <Widget>[
          NavigationDestination(
            selectedIcon: Icon(CupertinoIcons.house_fill, color: Colors.white,),
            icon: Icon(CupertinoIcons.house),
            label: 'Home',
          ),
          NavigationDestination(
            selectedIcon: Icon(CupertinoIcons.book_fill, color: Colors.white,),
            icon: Icon(CupertinoIcons.book),
            label: 'Chapters',
          ),
          NavigationDestination(
            selectedIcon: Icon(CupertinoIcons.info_circle_fill, color: Colors.white,),
            icon: Icon(CupertinoIcons.info_circle),
            label: 'About',
          ),
        ],
      ),
      body: <Widget>[
        /// Home page
        HomeScreen(),

        /// Chapters page
        ChaptersScreen(),

        /// About page
        AboutScreen(),
      ][currentPageIndex],
    );
  }
}
