// ignore_for_file: use_build_context_synchronously, unused_field, prefer_final_fields, prefer_typing_uninitialized_variables

import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
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
    await _controller.initialize();
    setState(() {
      val = 1;
    });
  }

  locsetup() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      bool serviceRequested = await Geolocator.openLocationSettings();
      if (!serviceRequested) {
        return;
      }
    }
  }

  @override
  void initState() {
    super.initState();
    camsetup();
    locsetup();
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
