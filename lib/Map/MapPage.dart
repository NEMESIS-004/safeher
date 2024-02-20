// ignore_for_file: file_names, unused_element, use_build_context_synchronously, avoid_init_to_null, prefer_final_fields, avoid_print, unused_field, non_constant_identifier_names, unused_local_variable, avoid_types_as_parameter_names

import 'dart:async';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapPage extends StatefulWidget {
  const MapPage({super.key});

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  @override
  void initState() {
    super.initState();
    getUserLocation().then(
      (_) => {
        getPolyLinePoints()
            .then((coordinates) => generatePolyLinesPoints(coordinates)),
      },
    );
  }

  late double latitude;
  late double longitude;

  LatLng? cPos = null;
  static LatLng _bGoogle = const LatLng(26.051, 82.051);
  Completer<GoogleMapController> _mapcontroller =
      Completer<GoogleMapController>();

  Map<PolylineId, Polyline> polylines = {};

  // Request For Location
  Future<void> _requestLocationPermission() async {
    final permissionStatus = await Geolocator.checkPermission();
    if (permissionStatus == LocationPermission.denied ||
        permissionStatus == LocationPermission.deniedForever) {
      final permissionRequested = await Geolocator.requestPermission();
      if (permissionRequested != LocationPermission.whileInUse &&
          permissionRequested != LocationPermission.always) {
        return;
      }
    }
  }

  Future<void> getUserLocation() async {
    await _requestLocationPermission();
    try {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      setState(() {
        latitude = position.latitude;
        longitude = position.longitude;
        cPos = LatLng(latitude, longitude);
      });
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text(
            "Failed to get user location. Please enable location services."),
      ));
    }
  }

  Future<List<LatLng>> getPolyLinePoints() async {
    List<LatLng> polylinecoor = [];
    PolylinePoints polylinepoints = PolylinePoints();
    PolylineResult result = await polylinepoints.getRouteBetweenCoordinates(
        "AIzaSyBBJfgRGrYJrkNAdcMEKmdJQNJXEV4_Vo4",
        PointLatLng(cPos!.latitude, cPos!.longitude),
        PointLatLng(_bGoogle.latitude, _bGoogle.longitude),
        travelMode: TravelMode.driving);
    if (result.points.isNotEmpty) {
      for (var point in result.points) {
        polylinecoor.add(LatLng(point.latitude, point.longitude));
      }
    } else {
      print("error");
    }
    return polylinecoor;
  }

  void generatePolyLinesPoints(List<LatLng> polylinecoordinates) async {
    PolylineId id = const PolylineId("poly");
    Polyline polyline = Polyline(
        polylineId: id,
        color: Colors.blue,
        points: polylinecoordinates,
        width: 8);
    setState(() {
      polylines[id] = polyline;
    });
  }

  late double deslat;
  late double destlng;
  getcoordinates(String s) async {
    const apiKey =
        "AIzaSyBBJfgRGrYJrkNAdcMEKmdJQNJXEV4_Vo4"; // Replace with your actual API key
    final query = Uri.encodeComponent(s);
    final url =
        'https://maps.googleapis.com/maps/api/geocode/json?address=$query&key=$apiKey';

    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == 'OK' &&
            data['results'] != null &&
            data['results'].isNotEmpty) {
          final location = data['results'][0]['geometry']['location'];
          deslat = location['lat'];
          destlng = location['lng'];
          setState(() {
            getPolyLinePoints2(latitude, longitude, deslat, destlng);
            _bGoogle = LatLng(deslat, destlng);
          });
        }
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  getPolyLinePoints2(double lt1, double lg1, double lt2, double lg2) async {
    List<LatLng> polylinecoor = [];
    PolylinePoints polylinepoints = PolylinePoints();
    PolylineResult result = await polylinepoints.getRouteBetweenCoordinates(
        "AIzaSyBBJfgRGrYJrkNAdcMEKmdJQNJXEV4_Vo4",
        PointLatLng(lt1, lg1),
        PointLatLng(lt2, lg2),
        travelMode: TravelMode.driving);
    if (result.points.isNotEmpty) {
      for (var point in result.points) {
        polylinecoor.add(LatLng(point.latitude, point.longitude));
      }
    } else {
      print("error");
    }
    generatePolyLinesPoints(polylinecoor);
  }

  void generatePolyLinesPoints2(List<LatLng> polylinecoordinates) async {
    PolylineId id = const PolylineId("poly");
    Polyline polyline = Polyline(
        polylineId: id,
        color: Colors.blue,
        points: polylinecoordinates,
        width: 8);
    setState(() {
      polylines[id] = polyline;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          cPos == null
              ? const Center(
                  child: CircularProgressIndicator(),
                )
              : GoogleMap(
                  initialCameraPosition:
                      CameraPosition(target: cPos!, zoom: 10),
                  markers: {
                    Marker(
                        markerId: const MarkerId("_currentlocation"),
                        icon: BitmapDescriptor.defaultMarker,
                        position: cPos!),
                    Marker(
                        markerId: const MarkerId("_destlocation"),
                        icon: BitmapDescriptor.defaultMarker,
                        position: _bGoogle),
                  },
                  polylines: Set<Polyline>.of(polylines.values),
                ),
          Positioned(
            top: 65,
            right: 20,
            left: 30,
            child: TextFormField(
              onChanged: (value) {
                print(value);
                if (value.length % 3 == 0) getcoordinates(value);
              },
              cursorColor: Colors.black,
              decoration: const InputDecoration(
                  filled: true,
                  fillColor: Colors.white,
                  labelStyle: TextStyle(color: Colors.black),
                  focusColor: Colors.black,
                  labelText: 'Enter Your Destination',
                  focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.horizontal()),
                  enabledBorder:
                      OutlineInputBorder(borderSide: BorderSide(width: 3))),
            ),
          ),
        ],
      ),
    );
  }
}
