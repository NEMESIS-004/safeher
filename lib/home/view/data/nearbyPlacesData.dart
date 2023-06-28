// ignore_for_file: file_names

import 'package:flutter/material.dart';

class Place {
  final String name;
  final String sub;
  final String imageUrl;
  final String back;
  final String api;
  final Color color;

  Place({
    required this.name,
    required this.sub,
    required this.imageUrl,
    required this.back,
    required this.api,
    required this.color,
  });
}
const Color lb = Color.fromRGBO(235, 246, 255, 1);
const Color db = Color.fromRGBO(54, 159, 255, 1);
const Color lg = Color.fromRGBO(138, 197, 62, 1);
const Color lo = Color.fromRGBO(255, 153, 58, 1);
const Color ly = Color.fromRGBO(255, 209, 67, 1);
final List<Place> placeList = [
  Place(
      name: "Police Stations",
      sub: "List of police stations near you",
      imageUrl: "assets/police.png",
      back: "assets/box4.png",
      api: "https://www.google.com/maps/search/?api=1&query=Police Stations near me",
      color: ly),
  Place(
      name: "Hospitals",
      sub: "List of Hospitals near you",
      imageUrl: "assets/hospital.png",
      back: "assets/box2.png",
      api: "https://www.google.com/maps/search/?api=1&query=Hospitals near me",
      color: lo),
  Place(
      name: "Pharmacies",
      sub: "List of Pharmacies near you",
      imageUrl: "assets/pharmacy.png",
      back: "assets/box3.png",
      api: "https://www.google.com/maps/search/?api=1&query=Pharmacies near me",
      color: lg),
  Place(
      name: "Bus Stops",
      sub: "List of Bus Stops near you",
      imageUrl: "assets/bus.png",
      back: "assets/box1.png",
      api: "https://www.google.com/maps/search/?api=1&query=Bus Stops near me",
      color: db),
];
