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
        height: 60,
        backgroundColor: Colors.white,
        onDestinationSelected: (int index) {
          setState(() {
            currentPageIndex = index;
          });
        },
        indicatorColor: Color(0xFF101110),
        labelBehavior: NavigationDestinationLabelBehavior.alwaysHide,
        selectedIndex: currentPageIndex,
        destinations: const <Widget>[
          NavigationDestination(
            selectedIcon: Icon(
              CupertinoIcons.house_fill,
              color: Colors.white,
              size: 20,
            ),
            icon: Icon(
              CupertinoIcons.house,
              size: 20,
            ),
            label: 'Home',
          ),
          NavigationDestination(
            selectedIcon: Icon(
              CupertinoIcons.book_fill,
              color: Colors.white,
              size: 20,
            ),
            icon: Icon(
              CupertinoIcons.book,
              size: 20,
            ),
            label: 'Chapters',
          ),
          NavigationDestination(
            selectedIcon: Icon(
              CupertinoIcons.info_circle_fill,
              color: Colors.white,
              size: 20,
            ),
            icon: Icon(
              CupertinoIcons.info_circle,
              size: 20,
            ),
            label: 'About',
          ),
        ],
      ),
      body: <Widget>[
        /// Home page
        HomeScreen(onReadNowPressed: () {
          setState(() {
            currentPageIndex = 1;
          });
        }),

        /// Chapters page
        ChaptersScreen(),

        /// About page
        AboutScreen(),
      ][currentPageIndex],
    );
  }
}
