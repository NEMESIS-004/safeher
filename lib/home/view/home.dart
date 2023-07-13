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
    return Scaffold(
      appBar: GlobalAppBar()
          .show("SafeHer", "Your Safety Our Priority", Icons.notifications),
      body: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
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
          padding:
              EdgeInsets.only(left: 16.0, bottom: 10, top: 10, right: 16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Emergency Contacts",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              Text(
                "Add New",
                style: TextStyle(
                  color: Colors.pink,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              )
            ],
          ),
        ),
        Expanded(
            child: ListView(
          padding: EdgeInsets.all(25.0),
          children: [
            Container(
              child: emergencyContactTile(
                  "Aaditya Raj", "8882774087", "aadityaraj085@gmail.com"),
            ),
            SizedBox(
              height: 10,
            ),
            Container(
              child: emergencyContactTile(
                  "Aman Kumar Singh", "9894XXXXXX", "amankumar@gmail.com"),
            ),
            SizedBox(
              height: 10,
            ),
            Container(
              child: emergencyContactTile(
                  "Aryan Raj", "8595XXXXXXX", "aryanraj@gmail.com"),
            ),
            SizedBox(
              height: 10,
            ),
          ],
        ))
      ]),
    );
  }

  Container emergencyContactTile(String name, String phone, String email) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      height: 85,
      decoration: BoxDecoration(
          color: Colors.grey.shade200,
          borderRadius: BorderRadius.circular(15.0)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(
                Icons.person,
                color: Colors.pink[200],
              ),
              const SizedBox(
                width: 12,
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: TextStyle(
                      fontSize: 18,
                      overflow: TextOverflow.ellipsis,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    phone,
                    style: TextStyle(
                      overflow: TextOverflow.ellipsis,
                      fontSize: 16,
                    ),
                  ),
                  SizedBox(
                    width: 10,
                  ),
                  Text(
                    email,
                    style: TextStyle(
                      overflow: TextOverflow.ellipsis,
                      fontSize: 16,
                    ),
                  )
                ],
              ),
            ],
          ),
          IconButton(
              onPressed: () {},
              icon: const Icon(Icons.edit, color: Colors.grey))
        ],
      ),
    );
  }
}
