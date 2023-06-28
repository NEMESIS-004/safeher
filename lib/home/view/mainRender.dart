// ignore_for_file: file_names

import 'package:fluid_bottom_nav_bar/fluid_bottom_nav_bar.dart';
import 'package:flutter/material.dart';
import 'package:safeher3/home/view/home.dart';
import 'package:safeher3/home/view/nearbyPlaces.dart';
import 'package:safeher3/home/view/profilePage.dart';

class MainRender extends StatefulWidget {
  const MainRender({super.key});
  static const String routeName = "/mainRender";
  @override
  State<MainRender> createState() => _MainRenderState();
}

class _MainRenderState extends State<MainRender> {
  Widget? _child = const HomePage();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      body: _child,
      bottomNavigationBar: FluidNavBar(
        icons: [
          FluidNavBarIcon(
              icon: Icons.home_rounded,
              backgroundColor: Colors.pink,
              extras: {"label": "home"}),
          FluidNavBarIcon(
              icon: Icons.navigation_rounded,
              backgroundColor: Colors.pink,
              extras: {"label": "Nearby Places"}),
          FluidNavBarIcon(
              icon: Icons.settings,
              backgroundColor: Colors.pink,
              extras: {"label": "settings"}),
        ],
        onChange: _handleNavigationChange,
        style: const FluidNavBarStyle(
            barBackgroundColor: Color(0xFFEAC0DC),
            iconSelectedForegroundColor: Colors.white,
            iconUnselectedForegroundColor: Colors.white60),
        scaleFactor: 1.5,
        defaultIndex: 0,
        itemBuilder: (icon, item) => Semantics(
          label: icon.extras!["label"],
          child: item,
        ),
      ),
    );
  }

  void _handleNavigationChange(int index) {
    setState(() {
      switch (index) {
        case 0:
          _child = const HomePage();
          break;
        case 1:
          _child = const NearbyPlaces();
          break;
        case 2:
          _child = const ProfilePage();
          break;
      }
      _child = AnimatedSwitcher(
        switchInCurve: Curves.easeOut,
        switchOutCurve: Curves.easeIn,
        duration: const Duration(milliseconds: 500),
        child: _child,
      );
    });
  }
}
