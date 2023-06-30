// ignore_for_file: file_names

import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fluid_bottom_nav_bar/fluid_bottom_nav_bar.dart';
import 'package:flutter/material.dart';
import 'package:geoflutterfire2/geoflutterfire2.dart';
import 'package:geolocator/geolocator.dart';
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
  Position? _currentPosition;
  String userId = FirebaseAuth.instance.currentUser!.uid;

  final geo = GeoFlutterFire();
  Future<bool> _handleLocationPermission() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text(
              'Location services are disabled. Please enable the services')));
      return false;
    }
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Location permissions are denied')));
        return false;
      }
    }
    if (permission == LocationPermission.deniedForever) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text(
              'Location permissions are permanently denied, we cannot request permissions.')));
      return false;
    }
    return true;
  }

  // Function to get current location of driver using geolocator
  Future<void> _getCurrentPosition() async {
    final hasPermission = await _handleLocationPermission();

    if (!hasPermission) return;
    await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high)
        .then((Position position) {
      setState(() => _currentPosition = position);
    });
  }

  void _updateLocation() async {
    await _getCurrentPosition();
    GeoFirePoint userLocation = geo.point(
        latitude: _currentPosition!.latitude,
        longitude: _currentPosition!.longitude);
    FirebaseFirestore.instance
        .collection('userdata')
        .doc(userId)
        .update({'position': userLocation.data});
  }

@override
  void initState() {
    super.initState();
    Timer.periodic(const Duration(seconds: 5), (timer) {
      _updateLocation();
    });
    
  }

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
