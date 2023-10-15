import 'dart:convert';

import 'package:firebase_database/firebase_database.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'package:safeher3/aman/Assistants/request_assistant.dart';
import 'package:safeher3/aman/global/global.dart';
import 'package:safeher3/aman/global/map_key.dart';
import 'package:safeher3/aman/models/directions.dart';
import 'package:safeher3/aman/models/trips_history_model.dart';
import 'package:safeher3/aman/models/user_model.dart';

import '../infoHandler/app_info.dart';
import '../models/direction_details_info.dart';

class AssistantMethods {
  static void readCurrentOnlineUserInfo() async {
    currentUser = firebaseAuth.currentUser;
    DatabaseReference userRef =
        FirebaseDatabase.instance.ref().child("users").child(currentUser!.uid);

    userRef.once().then((snap) {
      if (snap.snapshot.value != null) {
        userModelCurrentInfo = UserModel.fromSnapshot(snap.snapshot);
      }
    });
  }

  static Future<String> searchAddressForGeographicCoOrdinates(
      Position position, context) async {
    String apiUrl =
        "https://maps.googleapis.com/maps/api/geocode/json?latlng=${position.latitude},${position.longitude}&key=$mapKey";
    String humanReadableAddress = "";

    var requestResponse = await RequestAssistant.recieveRequest(apiUrl);
    if (requestResponse != "failedResponse") {
      humanReadableAddress = requestResponse["results"][0]
          ["formatted_address"]; //fromatted_addresss

      Directions userPickupAddress = Directions();
      userPickupAddress.locationLatitude = position.latitude;
      userPickupAddress.locationLongitude = position.longitude;
      userPickupAddress.locationName = humanReadableAddress;

      Provider.of<AppInfo>(context, listen: false)
          .updatePickUpLocationAddress(userPickupAddress);
    }
    return humanReadableAddress;
  }

  static Future<DirectionDetailsInfo>
      obtainedOriginToDestinationDirectionDetails(
          LatLng originPosition, LatLng destinationPosition) async {
    String urlOriginToDestinationDirectionDetails =
        "https://maps.googleapis.com/maps/api/directions/json?origin=${originPosition.latitude},${originPosition.longitude}&destination=${destinationPosition.latitude},${destinationPosition.longitude}&key=$mapKey";
    var responseDirectionApi = await RequestAssistant.recieveRequest(
        urlOriginToDestinationDirectionDetails);

    // if(responseDirectionApi == "failedResponse"){
    //   return null;
    // }

    print("direction info, ${responseDirectionApi}");

    // print("multiple routes ${responseDirectionApi}");
    DirectionDetailsInfo directionDetailsInfo = DirectionDetailsInfo();
    directionDetailsInfo.e_points =
        responseDirectionApi["routes"][0]["overview_polyline"]["points"];

    directionDetailsInfo.distance_text =
        responseDirectionApi["routes"][0]["legs"][0]["distance"]["text"];
    directionDetailsInfo.distance_value =
        responseDirectionApi["routes"][0]["legs"][0]["distance"]["value"];

    directionDetailsInfo.duration_text =
        responseDirectionApi["routes"][0]["legs"][0]["duration"]["text"];
    directionDetailsInfo.duration_value =
        responseDirectionApi["routes"][0]["legs"][0]["duration"]["value"];
    return directionDetailsInfo;
  }

  static double calculateFareAmountFromOriginToDestination(
      DirectionDetailsInfo directionDetailsInfo) {
    double timeTraveledFareAmountPerMinute =
        (directionDetailsInfo.duration_value! / 60) * 0.1;
    double distanceTraveledFareAmountPerMinute =
        (directionDetailsInfo.distance_value! / 1000) * 0.1;

    //USD
    double totalFareAmount =
        timeTraveledFareAmountPerMinute + distanceTraveledFareAmountPerMinute;

    return double.parse(totalFareAmount.toStringAsFixed(1));
  }

  //here deviceRegistrationToken=driversList[i]["token"]  and userRideRequestId=referenceRideRequest!.key!
  static sendNotificationToDriverNow(
      String deviceRegistrationToken, String userRideRequestId, context) async {
    String destinationAddress = userDropOffAddress;

    Map<String, String> headerNotification = {
      'Content-Type': 'application/json',
      'Authorization': cloudMessagingServerToken,
    };

    Map bodyNotification = {
      "body":
          "DestinationAddress: \n$destinationAddress.", //notification shown in driver app
      "title": "New Trip Request",
    };

    Map dataMap = {
      "click_action":
          "FLUTTER NOTIFICATION CLICK", //use in <intent-filter> in manifestFile of DriverApp
      "id": "1",
      "status": "done",
      "rideRequestId":
          userRideRequestId, //use as remoteMessage.data["rideRequestId"] in DriverApp
    };

    Map officialNotificationFormat = {
      "notification": bodyNotification,
      "data": dataMap,
      "priority": "high",
      "to": deviceRegistrationToken
    };

    var responseNotification = http.post(
      Uri.parse("https://fcm.googleapis.com/fcm/send"),
      headers: headerNotification,
      body: jsonEncode(officialNotificationFormat),
    );
  }

  //retrieve the trips key for online user
  //trip key = ride request key
  static void readTripsKeysForOnlineUser(context) {
    FirebaseDatabase.instance
        .ref()
        .child("All Ride Requests")
        .orderByChild("userName")
        .equalTo(userModelCurrentInfo!.name)
        .once()
        .then((snap) {
      if (snap.snapshot.value != null) {
        Map keysTripsId = snap.snapshot.value as Map;

        //count total number of trips and share it with Provider
        int overAllTripsCounter = keysTripsId.length;
        Provider.of<AppInfo>(context, listen: false)
            .updateOverAllTripsCounter(overAllTripsCounter);

        //Share trips key with provider
        List<String> tripsKeysList = [];
        keysTripsId.forEach((key, value) {
          tripsKeysList.add(key);
        });
        Provider.of<AppInfo>(context, listen: false)
            .updateOverAllTripsKeys(tripsKeysList);

        //get trips keys data - read trips complete information
        readTripsHistoryInformation(context);
      }
    });
  }

  static void readTripsHistoryInformation(context) {
    var tripsAllKeys =
        Provider.of<AppInfo>(context, listen: false).historyTripsKeyList;

    for (String eachKey in tripsAllKeys) {
      FirebaseDatabase.instance
          .ref()
          .child("All Ride Requests")
          .child(eachKey)
          .once()
          .then((snap) {
        var eachTripHistory = TripsHistoryModel.fromSnapshot(snap.snapshot);

        if ((snap.snapshot.value as Map)["status"] == "ended") {
          //update or add each history to overAllTrips History data list
          Provider.of<AppInfo>(context, listen: false)
              .updateOverAllTripsHistoryInformation(eachTripHistory);
        }
      });
    }
  }
}
