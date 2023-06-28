// ignore_for_file: use_build_context_synchronously, unused_field, prefer_final_fields, prefer_typing_uninitialized_variables

import 'dart:async';
import 'dart:io';
import 'package:camera/camera.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:geoflutterfire2/geoflutterfire2.dart';
import 'package:geolocator/geolocator.dart';
import 'package:safeher3/home/view/controller/serviceActivator.dart';
import 'package:safeher3/home/view/widgets/globalAppBar.dart';
import 'package:video_player/video_player.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});
  static const String routeName = "/homeScreen";
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
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
    }).catchError((e) {
      debugPrint(e);
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

  List<CameraDescription> cameras = [];
  late CameraController _controller;
  late VideoPlayerController _videoController =
      VideoPlayerController.file(File(''));
  int val = 0;

  void camsetup() async {
    cameras = await availableCameras();
    _controller = CameraController(
      cameras[0],
      ResolutionPreset.medium,
    );
    val = 1;
  }

  @override
  void initState() {
    super.initState();
    camsetup();
    Timer.periodic(const Duration(seconds: 5), (timer) {
      _updateLocation();
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      left: false,
      right: false,
      bottom: false,
      child: Scaffold(
        body: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const GlobalAppBar(),
          if (val == 1)
            ServiceActivator(
              cameras: cameras,
              controller: _controller,
              videoController: _videoController,
            ),
          if (val == 0)
            const Center(
              child: CircularProgressIndicator(
                color: Color.fromARGB(255, 207, 17, 80),
              ),
            ),
          const Padding(
            padding: EdgeInsets.only(left: 16.0, bottom: 10, top: 10),
            child: Text(
              "Your Emergency Contacts",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
            ),
          ),
        ]),
      ),
    );
  }
}
