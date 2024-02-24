// ignore_for_file: file_names, unused_element, use_build_context_synchronously, avoid_init_to_null, prefer_final_fields, avoid_print, unused_field, non_constant_identifier_names, unused_local_variable, avoid_types_as_parameter_names, prefer_const_declarations, unused_import

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
    getUserLocation();
  }

  late double latitude;
  late double longitude;
  String text = "greater noida";
  LatLng? cPos = null;
  static LatLng bGoogle = const LatLng(24.051, 82.051);
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



  void generatePolyLinesPoints(List<LatLng> polylinecoordinates) async {
    PolylineId id = const PolylineId("poly");
    Polyline polyline = Polyline(
        polylineId: id,
        color: Colors.pink,
        points: polylinecoordinates,
        width: 4);
    setState(() {
      polylines[id] = polyline;
    });
  }



  getSafePolyList(String ListofLatLang) {
    List<LatLng> polylinecoor = [];
    List<dynamic> coordinates = json.decode(ListofLatLang);
    for (int i = 0; i < coordinates.length; i++) {
      List<dynamic> coordinatePair = coordinates[i];
      double la = coordinatePair[0];
      double lo = coordinatePair[1];
      polylinecoor.add(LatLng(la, lo));
    }
    return polylinecoor;
  }



  getcoordinates(String s) async {
    const apiKey =
        "AIzaSyB_D_sdhMz88ao9c-VvrWpN1J8chG0Gjww"; // Replace with your actual API key
    final query = Uri.encodeComponent(s);
    final url =
        'https://maps.googleapis.com/maps/api/geocode/json?address=$query&key=AIzaSyB_D_sdhMz88ao9c-VvrWpN1J8chG0Gjww&alternatives=true';
    print(
        "##############################################################################");

    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == 'OK' &&
            data['results'] != null &&
            data['results'].isNotEmpty) {
          final location = data['results'][0]['geometry']['location'];
          setState(() {
            bGoogle = LatLng(location["lat"], location["lng"]);
          });

          String ListOfLatLang = await callFastAPI(latitude, longitude, s);

          final polylineCoordinates = await getSafePolyList(ListOfLatLang);

          generatePolyLinesPoints(polylineCoordinates);
          // print(ListOfLatLang);
          print(latitude);
          print(longitude);
          print(bGoogle.latitude);
          print(bGoogle.longitude);
        }
      }
    } catch (e) {
      print(e);
    }
  }



  Future<String> callFastAPI(
      double float1, double float2, String myString) async {
    var apiUrl = Uri.parse('https://safe-route-api.onrender.com')
        .replace(queryParameters: {
      'source_lat': float1.toString(),
      'source_long': float2.toString(),
      'destination': myString,
    });

    try {
      var response = await http.post(apiUrl);
      if (response.statusCode == 200) {
        print('Request successful');
        return response.body;
      } else {
        print('Request failed with status: ${response.statusCode}');
        return "Failed to get data! Status code: ${response.statusCode}";
      }
    } catch (error) {
      return "An error occurred while making the API call: $error";
    }
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
                        icon: BitmapDescriptor.defaultMarkerWithHue(210),
                        position: cPos!),
                    Marker(
                        markerId: const MarkerId("_destlocation"),
                        icon: BitmapDescriptor.defaultMarker,
                        position: bGoogle),
                  },
                  polylines: Set<Polyline>.of(polylines.values),
                ),
          Positioned(
            top: 65,
            right: 20,
            left: 30,
            child: TextFormField(
              onChanged: (newValue) {
                text = newValue;
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
          Positioned(
            top: 140,
            right: 20,
            left: 30,
            child: ElevatedButton(
              onPressed: () {
                setState(() {
                  getcoordinates(text);
                });
              },
              child: const Text("send"),
            ),
          ),
        ],
      ),
    );
  }
}
