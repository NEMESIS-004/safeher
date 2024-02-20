// ignore_for_file: camel_case_types, non_constant_identifier_names, avoid_types_as_parameter_names, avoid_print

import 'package:flutter/material.dart';
import 'package:safeher3/Map/Request_assistance.dart';

class dest extends StatefulWidget {
  const dest({super.key});

  @override
  State<dest> createState() => _destState();
}

class _destState extends State<dest> {
  List<PredictedPlaces> placesPredictedList = [];

  void GetArea(String value) async {
    String urlAutoCompleteSearch =
        "https://maps.googleapis.com/maps/api/place/autocomplete/json?input=$value&key=AIzaSyBBJfgRGrYJrkNAdcMEKmdJQNJXEV4_Vo4&components=country:IN";
    var responseAutoCompleteSearch =
        await RequestAssistant.recieveRequest(urlAutoCompleteSearch);
    if (responseAutoCompleteSearch == "failedResponse") {
      return;
    }
    if (responseAutoCompleteSearch["status"] == "OK") {
      var placePredictions = responseAutoCompleteSearch["predictions"];
      var placePredictionList = (placePredictions as List)
          .map((jsonData) => PredictedPlaces.fromJson(jsonData))
          .toList();
      setState(() {
        placesPredictedList = placePredictionList;
      });
      print(placePredictionList);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 60.0, right: 20, left: 20),
            child: TextFormField(
              onChanged: (value) {
                GetArea(value);
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
          Expanded(
            child: ListView.builder(
                itemCount: placesPredictedList.length,
                itemBuilder: (BuildContext, index) {
                  // print(placesPredictedList[index].main_text);
                  return ListTile(
                    title: Text('${placesPredictedList[index].secondary_text}'),
                  );
                }),
          )
        ],
      ),
    );
  }
}
