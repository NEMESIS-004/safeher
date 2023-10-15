import 'dart:async';

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_geofire/flutter_geofire.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geocoder2/geocoder2.dart';
import 'package:geolocator/geolocator.dart';
import 'package:location/location.dart' as loc;
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:safeher3/aman/Assistants/assistant_methods.dart';
import 'package:safeher3/aman/global/global.dart';
import 'package:safeher3/aman/infoHandler/app_info.dart';
import 'package:safeher3/aman/models/active_nearby_available_drivers.dart';
import 'package:safeher3/aman/screens/drawer_screen.dart';
import 'package:safeher3/aman/screens/search_places_screen.dart';
import 'package:safeher3/aman/widgets/progress_dialog.dart';
import 'package:url_launcher/url_launcher.dart';


import '../models/directions.dart';
import 'precise_pickup_location.dart';

Future<void> _makePhoneCall(String url) async{
  if(await canLaunch(url)){
    await launch(url);
  }
  else{
    throw "Could not launch $url";
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({Key? key}) : super(key: key);
  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  LatLng? pickLocation;
  loc.Location location = loc.Location();
  String? _address;
  final Completer<GoogleMapController> _controllerGoogleMap = Completer();
  GoogleMapController? newGoogleMapController;

  static const CameraPosition _kGooglePlex = CameraPosition(
    target: LatLng(37.42796133580664, -122.085749655962),
    zoom: 14.4746,
  );

  GlobalKey<ScaffoldState> _scaffoldState = GlobalKey<ScaffoldState>();

  double searchLocationContainerHeight = 220;
  double waitingResponsefromDriverContainerHeight = 0;
  double assignedDriverInfoContainerHeight = 0;
  double suggestedRidesContainerHeight = 0;
  double searchingForDriverContainerHeight = 0;

  Position? userCurrentPosition;
  var geoLocation = Geolocator();

  LocationPermission? _locationPermission;
  double bottomPaddingOfMap = 0;

  List<LatLng> pLineCoOrdinatesList = [];
  Set<Polyline> polylineSet = {};
  Set<Marker> markerSet = {};
  Set<Circle> circleSet = {};

  String userName = "";
  String userEmail = "";

  bool openNavigationDrawer = true;

  bool activeNearbyDriverKeysLoaded = false;
  BitmapDescriptor? activeNearByIcon; //use in show Driver (displayActiveDriversOnUserMap())

  DatabaseReference? referenceRideRequest;//save ride Request info(saveRideRequestInformation())
  String selectedVehicleType = ""; //use in show Fare

  String driverRideStatus  = "Driver is coming";
  StreamSubscription<DatabaseEvent>? tripRideRequestInfoStreamSubscription;
  String userRideRequestStatus = "";

  List<ActiveNearByAvailableDrivers> onlineNearByAvailableDriversList = [];

  bool requestPositionInfo = true;

  //use GeoLocator to find current Position,
  // and give it to AssistantMethods.searchAddressForGeographicCoOrdinates() to find HumanReadableAddress,
  // and initializeGeoFireListener() for driver current Location

  locateUserPosition() async {
    Position cPosition = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    userCurrentPosition = cPosition;

    LatLng latLngPosition = LatLng(userCurrentPosition!.latitude, userCurrentPosition!.longitude);
    CameraPosition cameraPosition = CameraPosition(target: latLngPosition, zoom: 15);

    newGoogleMapController!.animateCamera(CameraUpdate.newCameraPosition(cameraPosition));

    String humanReadableAddress = await AssistantMethods.searchAddressForGeographicCoOrdinates(userCurrentPosition!, context);

    userName = userModelCurrentInfo!.name!;
    userEmail = userModelCurrentInfo!.email!;

    // initializeGeoFireListener(); // for driver current location (video lecture 11)

    // AssistantMethods.readTripsKeysForOnlineUser(context);
  }


  // Geofire.initialize("activeDrivers") stored in database by Driver app, and listen query of currentPosition of Radius 10Km,
  // if Key matches  with query then Geofire.initialize("activeDrivers") and display active Driver(Car Image) on map with help of displayActiveDriversOnUserMap()
  //if location of key not match with query then GeoFireAssistant.deleteOfflineDriverFromList(map["key"]) and displayActiveDriver
  //if location of key match with query(10 km radius) but location(driver) is moving then GeoFireAssistant.updateActiveNearByAvailableDriverLocation(activeNearByAvailableDrivers) and displayActiveDriver
  //if Geofire.onGeoQueryReady activeNearbyDriverKeysLoaded = true and displayActiveNearbyDriver

  // initializeGeoFireListener(){
  //   Geofire.initialize("activeDrivers");
  //   Geofire.queryAtLocation(userCurrentPosition!.latitude, userCurrentPosition!.longitude, 10)!//finding driver in radius 10 km
  //     .listen((map) {
  //       print(map);
  //
  //       if(map != null){
  //         var callBack = map["callBack"];
  //         switch(callBack){
  //           //whenever any driver active/online
  //           case Geofire.onKeyEntered:  //location of key matches with query
  //             GeoFireAssistant.activeNearByAvailableDriverList.clear();
  //             ActiveNearByAvailableDrivers activeNearByAvailableDrivers = ActiveNearByAvailableDrivers();
  //             activeNearByAvailableDrivers.locationLatitude = map["latitude"];
  //             activeNearByAvailableDrivers.locationLongitude = map["longitude"];
  //             activeNearByAvailableDrivers.driverId = map["key"];
  //             GeoFireAssistant.activeNearByAvailableDriverList.add(activeNearByAvailableDrivers);
  //             if(activeNearbyDriverKeysLoaded == true){
  //               displayActiveDriversOnUserMap();
  //             }
  //             break;
  //
  //           //whenever any driver become non-active/offline
  //           case Geofire.onKeyExited:  //location of key not match with query
  //             GeoFireAssistant.deleteOfflineDriverFromList(map["key"]);
  //             displayActiveDriversOnUserMap();
  //             break;
  //
  //           //whenever driver moves: update driver location
  //           case Geofire.onKeyMoved:  //location of key match with query(10 km radius) but location is moving
  //             ActiveNearByAvailableDrivers activeNearByAvailableDrivers = ActiveNearByAvailableDrivers();
  //             activeNearByAvailableDrivers.locationLatitude = map["latitude"];
  //             activeNearByAvailableDrivers.locationLongitude = map["longitude"];
  //             activeNearByAvailableDrivers.driverId = map["key"];
  //             GeoFireAssistant.updateActiveNearByAvailableDriverLocation(activeNearByAvailableDrivers);
  //             displayActiveDriversOnUserMap();
  //             break;
  //
  //           //display those online active driver on user's Map
  //           case Geofire.onGeoQueryReady:  //All current data has been loaded from the server and all initial events have been fired
  //             activeNearbyDriverKeysLoaded = true;
  //             displayActiveDriversOnUserMap();
  //             break;
  //         }
  //       }
  //
  //       setState(() {
  //
  //       });
  //   });
  // }


  //clear all polyLine and set markerSet for GeoFireAssistant.activeNearByAvailableDriverList with activeNearByIcon as createActiveNearByDriverIconMarker() and call in above Main

  // displayActiveDriversOnUserMap(){
  //   setState(() {
  //     markerSet.clear();
  //     circleSet.clear();
  //     Set<Marker> driversMarkerSet = Set<Marker>();
  //
  //     for(ActiveNearByAvailableDrivers eachDriver in GeoFireAssistant.activeNearByAvailableDriverList){
  //       LatLng eachDriverActivePosition = LatLng(eachDriver.locationLatitude!, eachDriver.locationLongitude!);
  //
  //       Marker marker = Marker(
  //         markerId: MarkerId(eachDriver.driverId!),
  //         position:  eachDriverActivePosition,
  //         icon: activeNearByIcon!,
  //         rotation: 360,
  //       );
  //       driversMarkerSet.add(marker);
  //     }
  //
  //     setState(() {
  //       markerSet = driversMarkerSet;
  //     });
  //   });
  // }


  //make Car in map by BitmapDescriptor.fromAssetImage(imageConfiguration, "images/car.png") and set activeNearByIcon

  // createActiveNearByDriverIconMarker(){
  //   if(activeNearByIcon == null){
  //     ImageConfiguration imageConfiguration = createLocalImageConfiguration(context, size: Size(2, 2));
  //     BitmapDescriptor.fromAssetImage(imageConfiguration, "images/car.png").then((value) {
  //       activeNearByIcon = value;
  //     });
  //   }
  // }


  //set global tripDirectionDetailsInfo with help of AssistantMethods.obtainedOriginToDestinationDirectionDetails(originLatLng, destinationLatLng)
  //make polyLine and set into polylineSet
  //make originMarker and DestinationMarker and set to markerSet
  //make originCircle and DestinationCircle and set to circleSet
  //according to originLatLng and destinationLatLng (direction condition) set LatLngBound and newGoogleMapController!.animateCamera(CameraUpdate.newLatLngBounds(boundsLatLng, 65))

  Future<void> drawPolyLineFromOriginToDestination(bool darkTheme) async{
    var originPosition = Provider.of<AppInfo>(context, listen: false).userPickUpLocation;
    var destinationPosition = Provider.of<AppInfo>(context, listen: false).userDropOffLocation;

    var originLatLng = LatLng(originPosition!.locationLatitude!, originPosition.locationLongitude!);
    var destinationLatLng = LatLng(destinationPosition!.locationLatitude!, destinationPosition.locationLongitude!);


    showDialog(
        context: context,
        builder: (BuildContext context) => ProgressDialog(message: "Please wait...",),
    );

    var directionDetailsInfo = await AssistantMethods.obtainedOriginToDestinationDirectionDetails(originLatLng, destinationLatLng);
    setState(() {
      tripDirectionDetailsInfo = directionDetailsInfo;
    });


    Navigator.pop(context);

    PolylinePoints pPoints = PolylinePoints();
    List<PointLatLng> decodePolyLinePointsResultList = pPoints.decodePolyline(directionDetailsInfo.e_points!);

    pLineCoOrdinatesList.clear();
    if(decodePolyLinePointsResultList.isNotEmpty){
      decodePolyLinePointsResultList.forEach((PointLatLng pointLatLng) {
        pLineCoOrdinatesList.add(LatLng(pointLatLng.latitude, pointLatLng.longitude));
      });
    }

    polylineSet.clear();
    setState(() {
      Polyline polyline = Polyline(
        color: Colors.pink,
        polylineId: const PolylineId("PolylineID"),
        jointType: JointType.round,
        points: pLineCoOrdinatesList,
        startCap: Cap.roundCap,
        endCap: Cap.roundCap,
        geodesic: true,
        width: 5,
      );
      polylineSet.add(polyline);
    });

    LatLngBounds boundsLatLng;
    if(originLatLng.latitude > destinationLatLng.latitude && originLatLng.longitude > destinationLatLng.longitude){
      boundsLatLng = LatLngBounds(southwest: destinationLatLng, northeast: originLatLng);
    }
    else if(originLatLng.longitude > destinationLatLng.longitude){
      boundsLatLng = LatLngBounds(
          southwest: LatLng(originLatLng.latitude, destinationLatLng.longitude),
          northeast: LatLng(destinationLatLng.latitude, originLatLng.longitude)
      );
    }
    else if(originLatLng.latitude > destinationLatLng.latitude){
      boundsLatLng = LatLngBounds(
          southwest: LatLng(destinationLatLng.latitude, originLatLng.longitude),
          northeast: LatLng(originLatLng.latitude, destinationLatLng.longitude)
      );
    }
    else{
      boundsLatLng = LatLngBounds(southwest: originLatLng, northeast: destinationLatLng);
    }

    newGoogleMapController!.animateCamera(CameraUpdate.newLatLngBounds(boundsLatLng, 65));

    Marker originMarker = Marker(
      markerId: const MarkerId("originID"),
      infoWindow: InfoWindow(title: originPosition.locationName, snippet: "Origin"),
      position:  originLatLng,
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
    );

    Marker destinationMarker = Marker(
      markerId: const MarkerId("destinationID"),
      infoWindow: InfoWindow(title: destinationPosition.locationName, snippet: "Destination"),
      position:  destinationLatLng,
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
    );
    setState(() {
      markerSet.add(originMarker);
      markerSet.add(destinationMarker);
    });

    Circle originCircle = Circle(
      circleId: const CircleId("originID"),
      fillColor: Colors.green,
      radius: 12,
      strokeWidth: 3,
      strokeColor: Colors.white,
      center: originLatLng
    );

    Circle destinationCircle = Circle(
        circleId: const CircleId("destinationID"),
        fillColor: Colors.green,
        radius: 12,
        strokeWidth: 3,
        strokeColor: Colors.white,
        center: destinationLatLng
    );
    setState(() {
      circleSet.add(originCircle);
      circleSet.add(destinationCircle);
    });
  }

  // getAddressFromLatLng() async{
  //   try{
  //     GeoData data = await Geocoder2.getDataFromCoordinates(
  //         latitude: pickLocation!.latitude,
  //         longitude: pickLocation!.longitude,
  //         googleMapApiKey: mapKey
  //     );
  //     setState(() {
  //       Directions userPickupAddress = Directions();
  //       userPickupAddress.locationLatitude = pickLocation!.latitude;
  //       userPickupAddress.locationLongitude = pickLocation!.longitude;
  //       userPickupAddress.locationName = data.address;
  //
  //       //change location according to pickup Icon
  //       Provider.of<AppInfo>(context, listen: false).updatePickUpLocationAddress(userPickupAddress);
  //       // _address = data.address;
  //     });
  //   }catch(e){
  //     print(e);
  //   }
  // }


  //make suggestedRidesContainerHeight = 400(for showing fare) and bottomPaddingOfMap = 400 by help of setState
  // void showSuggestedRideContainer(){
  //   setState(() {
  //     suggestedRidesContainerHeight = 400;
  //     bottomPaddingOfMap = 400;
  //   });
  // }


  //make  searchingForDriverContainerHeight = 200

  // showSearchingForDriversContainer(){
  //   setState(() {
  //     searchingForDriverContainerHeight = 200;
  //   });
  // }


  //if LocationPermission.denied then set _locationPermission to Geolocator.requestPermission()

  checkIfLocationPermissionAllowed() async{
    _locationPermission = await Geolocator.requestPermission();
    if(_locationPermission == LocationPermission.denied){
      _locationPermission = await Geolocator.requestPermission();
    }
  }
  

  ///lecture no. 12
  //make "All Ride Request" database to store userInformationMap(with Time) and set to referenceRideRequest
  //listen referenceRideRequest and store in a var StreamSubscription<DatabaseEvent>? tripRideRequestInfoStreamSubscription
  //set the other listen value in driverCarDetails, and listen value of ["status"] is set in userRideRequestStatus
  //if userRideRequestStatus == accepted, then show waiting time to user(in which driver reach to user) with help of updateArrivalTimeToUserPickUpLocation(driverCurrentPositionLatLng)
  //if userRideRequestStatus == "arrived", then set driverRideStatus = "Driver has arrived"
  //userRideRequestStatus == "ontrip", then show time take to reach to destination position with help of updateReachingTimeToUserDropOffLocation(driverCurrentPositionLatLng);
  //userRideRequestStatus == "ended", the showDialog of PayFareAmountDialog(fare) and store response variable
  //and if response == "Cash Paid", then with help of listen["driverId"] rate driver by going into RateDriverScreen
  //and referenceRideRequest!.onDisconnect() and cancel the listen value with help of tripRideRequestInfoStreamSubscription!.cancel(), if 'Cash Paid'
  //put GeoFireAssistant.activeNearByAvailableDriverList or (Geofire.onKeyMoved of "activeDriver" in initializeGeoFire) into var onlineNearByAvailableDriversList
  //call searchNearestOnlineDrivers(selectedVehicleType) which will search Driver based on car type and send notification to that driver

  // saveRideRequestInformation(String selectedVehicleType){
  //
  //   //1. save the ride request information
  //   //make "All Ride Request" database and set userInformationMap
  //   referenceRideRequest = FirebaseDatabase.instance.ref().child("All Ride Requests").push();
  //
  //   var originLocation = Provider.of<AppInfo>(context, listen: false).userPickUpLocation;
  //   var destinationLocation = Provider.of<AppInfo>(context, listen: false).userDropOffLocation;
  //
  //   Map originLocationMap  = {
  //     //"key": value
  //     "latitude": originLocation!.locationLatitude.toString(),
  //     "longitude": originLocation.locationLongitude.toString()
  //   };
  //
  //   Map destinationLocationMap = {
  //     "latitude": destinationLocation!.locationLatitude.toString(),
  //     "longitude": destinationLocation.locationLongitude.toString()
  //   };
  //
  //   Map userInformationMap = {
  //     "origin": originLocationMap,
  //     "destination": destinationLocationMap,
  //     "time": DateTime.now().toString(),
  //     "userName": userModelCurrentInfo!.name,
  //     "userPhone": userModelCurrentInfo!.phone,
  //     "originAddress": originLocation.locationName,
  //     "destinationAddress": destinationLocation.locationName,
  //     "driverId": "waiting"
  //   };
  //
  //   referenceRideRequest!.set(userInformationMap);
  //
  //   tripRideRequestInfoStreamSubscription = referenceRideRequest!.onValue.listen((eventSnap) async{
  //     if(eventSnap.snapshot.value == null){
  //       return;
  //     }
  //     if((eventSnap.snapshot.value as Map)["car_details"] != null){
  //       setState(() {
  //         driverCarDetails = (eventSnap.snapshot.value as Map)["car_details"].toString();
  //       });
  //     }
  //     if((eventSnap.snapshot.value as Map)["driverPhone"] != null){
  //       setState(() {
  //         driverPhone = (eventSnap.snapshot.value as Map)["driverPhone"].toString();
  //       });
  //     }
  //     if((eventSnap.snapshot.value as Map)["driverName"] != null){
  //       setState(() {
  //         driverName = (eventSnap.snapshot.value as Map)["driverName"].toString();
  //       });
  //     }
  //     if((eventSnap.snapshot.value as Map)["ratings"] != null){
  //       setState(() {
  //         driverRatings = (eventSnap.snapshot.value as Map)["ratings"].toString();
  //       });
  //     }
  //     if((eventSnap.snapshot.value as Map)["status"] != null){
  //       setState(() {
  //         userRideRequestStatus = (eventSnap.snapshot.value as Map)["status"].toString();
  //       });
  //     }
  //
  //     if((eventSnap.snapshot.value as Map)["driverLocation"] != null){
  //       double driverCurrentPositionLat =  double.parse((eventSnap.snapshot.value as Map)["driverLocation"]["latitude"].toString());
  //       double driverCurrentPositionLng =  double.parse((eventSnap.snapshot.value as Map)["driverLocation"]["longitude"].toString());
  //
  //       LatLng driverCurrentPositionLatLng = LatLng(driverCurrentPositionLat, driverCurrentPositionLng);
  //
  //       //status == accepted
  //       if(userRideRequestStatus == "accepted"){
  //         updateArrivalTimeToUserPickUpLocation(driverCurrentPositionLatLng);
  //       }
  //       //status == arrived
  //       if(userRideRequestStatus == "arrived"){
  //         setState(() {
  //           driverRideStatus = "Driver has arrived";
  //         });
  //       }
  //       //status = ontrip
  //       if(userRideRequestStatus == "ontrip"){
  //           updateReachingTimeToUserDropOffLocation(driverCurrentPositionLatLng);
  //       }
  //       //status = ended
  //       if(userRideRequestStatus == "ended"){
  //         if((eventSnap.snapshot.value as Map)["fareAmount"] != null){
  //           double fareAmount = double.parse((eventSnap.snapshot.value as Map)["fareAmount"].toString());
  //
  //           var response = await showDialog(
  //               context: context,
  //               builder: (BuildContext context) => PayFareAmountDialog(
  //                 fareAmount: fareAmount
  //               )
  //           );
  //
  //           if(response == "Cash Paid"){
  //             //user can rate the driver now
  //             if((eventSnap.snapshot.value as Map)["driverId"] != null){
  //               String assignedDriverId = (eventSnap.snapshot.value as Map)["driverId"].toString();
  //               Navigator.push(context, MaterialPageRoute(builder: (c) => RateDriverScreen(assignedDriverId: assignedDriverId,)));
  //
  //               referenceRideRequest!.onDisconnect();
  //               tripRideRequestInfoStreamSubscription!.cancel();
  //             }
  //           }
  //         }
  //       }
  //     }
  //
  //     onlineNearByAvailableDriversList = GeoFireAssistant.activeNearByAvailableDriverList;
  //     searchNearestOnlineDrivers(selectedVehicleType);
  //   });
  // }


  // searchNearestOnlineDrivers(String selectedVehicleType) async{
  //   if(onlineNearByAvailableDriversList.length == 0){
  //     // cancel/delete the ride request information
  //     referenceRideRequest!.remove();
  //
  //     setState(() {
  //       polylineSet.clear();
  //       markerSet.clear();
  //       circleSet.clear();
  //       pLineCoOrdinatesList.clear();
  //     });
  //
  //     Fluttertoast.showToast(msg: "No online nearest Driver Available");
  //     Fluttertoast.showToast(msg: "Search Again. \n Restarting App");
  //
  //     Future.delayed(Duration(milliseconds: 4000), (){
  //       referenceRideRequest!.remove();
  //       Navigator.push(context, MaterialPageRoute(builder: (c) => SplashScreen()));
  //     });
  //     return;
  //   }
  //
  //   await retrieveOnlineDriversInformation(onlineNearByAvailableDriversList);
  //   print("Driver List: " + driversList.toString());
  //
  //   for(int i = 0; i < driversList.length; i++){
  //     if(driversList[i]["car_details"]["type"] == selectedVehicleType){
  //       AssistantMethods.sendNotificationToDriverNow(driversList[i]["token"], referenceRideRequest!.key!, context);
  //     }
  //   }
  //   Fluttertoast.showToast(msg: "Notification send Successfully");
  //   showSearchingForDriversContainer();
  //
  //   await FirebaseDatabase.instance.ref().child("All Ride Requests").child(referenceRideRequest!.key!).child("driverId").onValue.listen((eventRideRequestSnapshot) {
  //     print("EventSnapshot: ${eventRideRequestSnapshot.snapshot.value}");
  //     if(eventRideRequestSnapshot.snapshot.value != null){
  //       if(eventRideRequestSnapshot.snapshot.value != "waiting"){
  //         showUIForAssignedDriverInfo();    //**have to check it working
  //       }
  //     }
  //   });
  // }


  //set driverRideStatus "Driver is coming + duration_text" with help of Assistant.obtainedOriginToDestinationDirectionDetails

  // updateArrivalTimeToUserPickUpLocation(driverCurrentPositionLatLng) async{
  //   if(requestPositionInfo == true){
  //     requestPositionInfo = false;
  //     LatLng userPickUpPosition = LatLng(userCurrentPosition!.latitude, userCurrentPosition!.longitude);
  //
  //     var directionDetailsInfo = await AssistantMethods.obtainedOriginToDestinationDirectionDetails(driverCurrentPositionLatLng, userPickUpPosition);
  //
  //     if(directionDetailsInfo == null){
  //       return;
  //     }
  //     setState(() {
  //       driverRideStatus = "Driver is coming: " + directionDetailsInfo.duration_text.toString();
  //     });
  //
  //     requestPositionInfo = true;
  //   }
  // }


  //set driverRideStatus "Going Towards Destination + duration_text" with help of Assistant.obtainedOriginToDestinationDirectionDetails

  // updateReachingTimeToUserDropOffLocation(driverCurrentPositionLatLng) async{
  //   if(requestPositionInfo == true){
  //     requestPositionInfo = false;
  //
  //     var dropOffLocation = Provider.of<AppInfo>(context, listen: false).userDropOffLocation;
  //     LatLng userDestinationPosition = LatLng(dropOffLocation!.locationLatitude!, dropOffLocation.locationLongitude!);
  //
  //     var directionDetailsInfo = await AssistantMethods.obtainedOriginToDestinationDirectionDetails(driverCurrentPositionLatLng, userDestinationPosition);
  //
  //     if(directionDetailsInfo == null){
  //       return;
  //     }
  //     setState(() {
  //       driverRideStatus = "Going Towards Destination: " + directionDetailsInfo.duration_text.toString();
  //     });
  //
  //     requestPositionInfo = true;
  //   }
  // }


  // showUIForAssignedDriverInfo(){
  //   setState(() {
  //     waitingResponsefromDriverContainerHeight = 0;
  //     searchLocationContainerHeight = 0;
  //     assignedDriverInfoContainerHeight = 200;
  //     suggestedRidesContainerHeight = 0;
  //     bottomPaddingOfMap = 200;
  //   });
  // }

  //push driverKeyInfo into global driverList

  // retrieveOnlineDriversInformation(List onLineNearestDriversList) async{
  //   driversList.clear();
  //   DatabaseReference ref = FirebaseDatabase.instance.ref().child("drivers");
  //
  //   for(int i = 0; i < onlineNearByAvailableDriversList.length; i++){
  //     await ref.child(onLineNearestDriversList[i].driverId.toString()).once().then((dataSnapshot){
  //       var driverKeyInfo = dataSnapshot.snapshot.value;
  //
  //       driversList.add(driverKeyInfo);
  //       print("Driver key information = " + driversList.toString());
  //     });
  //   }
  // }

  @override
  void initState() {
    super.initState();
    checkIfLocationPermissionAllowed();
  }

  @override
  Widget build(BuildContext context) {
    bool darkTheme = MediaQuery.of(context).platformBrightness == Brightness.dark;
    // createActiveNearByDriverIconMarker();
    return GestureDetector(
      onTap: (){FocusScope.of(context).unfocus();},
      child: Scaffold(
        key: _scaffoldState,
        drawer: const DrawerScreen(),
        body: Stack(
          children: [
            GoogleMap(
              padding: EdgeInsets.only(top: 30, bottom: bottomPaddingOfMap),
              mapType: MapType.normal,
              myLocationEnabled: true,
              // myLocationButtonEnabled: true,
              zoomGesturesEnabled: true,
              zoomControlsEnabled: true,
              initialCameraPosition: _kGooglePlex,
              polylines: polylineSet,
              markers: markerSet,
              circles: circleSet,
              onMapCreated: (GoogleMapController controller){
                _controllerGoogleMap.complete(controller);
                newGoogleMapController = controller;

                // if(darkTheme == true){
                //   setState(() {
                //     blackThemeGoogleMap(newGoogleMapController);
                //   });
                // }

                setState(() {
                  bottomPaddingOfMap = 200;
                });
                locateUserPosition();
              },
              //userPosition change on Camera Move(Pick.png)
              // onCameraMove: (CameraPosition? position){
              //   if(pickLocation != position!.target){
              //     setState(() {
              //       pickLocation = position.target;
              //     });
              //   }
              // },
              // onCameraIdle: (){
              //   getAddressFromLatLng();
              // },
            ),
            // Align(
            //   alignment: Alignment.center,
            //   child: Padding(
            //     padding: const EdgeInsets.only(bottom: 35.0),
            //     child: Image.asset("images/pick.png", height: 45, width: 45,),
            //   ),
            // ),

            //Custom hamburger button for drawer
            // Positioned(
            //   top: 50,
            //   left: 20,
            //   child: Container(
            //     child: GestureDetector(
            //       onTap: (){
            //         _scaffoldState.currentState!.openDrawer();
            //       },
            //       child: CircleAvatar(
            //         backgroundColor: darkTheme ?  Colors.amber[400] : Colors.white,
            //         child: Icon(
            //           Icons.menu,
            //           color: darkTheme ? Colors.black : Colors.lightBlue,
            //         ),
            //       ),
            //     ),
            //   ),
            // ),

            //Ui for searching location
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(10, 50, 10, 10),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: darkTheme ? Colors.black : Colors.white,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(5),
                            child: Row(
                              children: [
                                Icon(Icons.location_on_outlined, color: darkTheme ? Colors.amber[400] : Colors.blue,),
                                const SizedBox(width: 10,),
                                Flexible(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text("From",
                                        style: TextStyle(
                                          color: darkTheme ? Colors.amber[400] : Colors.blue,
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold
                                        ),
                                      ),
                                      Text(
                                          Provider.of<AppInfo>(context).userPickUpLocation != null
                                              ? Provider.of<AppInfo>(context).userPickUpLocation!.locationName!
                                              : "Not Getting Address",
                                          style: const TextStyle(color: Colors.grey, fontSize: 14),
                                          softWrap: false,
                                          overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 5,),
                          Divider(
                            height: 1,
                            thickness: 2,
                            color: darkTheme ? Colors.amber[400] : Colors.blue,
                          ),
                          const SizedBox(height: 5,),

                          Padding(
                            padding: const EdgeInsets.all(5),
                            child: GestureDetector(
                              onTap: () async{
                                //go to search places screen
                                var responseFromSearchScreen = await Navigator.push(context, MaterialPageRoute(builder: (c) => SearchPlacesScreen()));
                                if(responseFromSearchScreen == "obtainedDropoff"){
                                  setState(() {
                                    openNavigationDrawer = false;
                                  });
                                }
                                print("before");
                                await drawPolyLineFromOriginToDestination(darkTheme);
                                print("after");
                              },
                              child: Row(
                                children: [
                                  Icon(Icons.location_on_outlined, color: darkTheme ? Colors.amber[400] : Colors.blue,),
                                  const SizedBox(width: 10,),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text("To",
                                        style: TextStyle(
                                            color: darkTheme ? Colors.amber[400] : Colors.blue,
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold
                                        ),
                                      ),
                                      Text(
                                        Provider.of<AppInfo>(context).userDropOffLocation != null
                                            ?Provider.of<AppInfo>(context).userDropOffLocation!.locationName!
                                            : "Where to?",
                                        style: const TextStyle(color: Colors.grey, fontSize: 14),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),

                          const SizedBox(height: 5,),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              ElevatedButton(
                                  onPressed: (){
                                    Navigator.push(context, MaterialPageRoute(builder: (c)=>PricePickUpScreen()));
                                  },
                                  child: Text(
                                    "Change Pick Up Address",
                                    style: TextStyle(
                                      color: darkTheme ? Colors.black : Colors.white,
                                    ),
                                  ),
                                  style: ElevatedButton.styleFrom(
                                    primary: darkTheme ? Colors.amber[400] : Colors.blue,
                                    textStyle: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16
                                    )
                                  ),
                              ),

                              // SizedBox(width: 10,),
                              // ElevatedButton(
                              //   onPressed: (){
                              //     if(Provider.of<AppInfo>(context, listen: false).userDropOffLocation != null){
                              //       showSuggestedRideContainer();
                              //     }
                              //     else{
                              //       Fluttertoast.showToast(msg: "Please select destination location");
                              //     }
                              //   },
                              //   child: Text(
                              //     "Show Fare",
                              //     style: TextStyle(
                              //       color: darkTheme ? Colors.black : Colors.white,
                              //     ),
                              //   ),
                              //   style: ElevatedButton.styleFrom(
                              //       primary: darkTheme ? Colors.amber[400] : Colors.blue,
                              //       textStyle: TextStyle(
                              //           fontWeight: FontWeight.bold,
                              //           fontSize: 16
                              //       )
                              //   ),
                              // ),

                            ],
                          )
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            //Ui for suggested Ride
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: Container(
                height: suggestedRidesContainerHeight,
                decoration: BoxDecoration(
                  color: darkTheme ? Colors.black : Colors.white,
                  borderRadius: const BorderRadius.only(topRight: Radius.circular(20), topLeft: Radius.circular(20)),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(2),
                            decoration: BoxDecoration(
                              color: darkTheme ? Colors.amber[400] : Colors.blue,
                              borderRadius: BorderRadius.circular(2),
                            ),
                            child: const Icon(
                              Icons.star,
                              color: Colors.white,
                            ),
                          ),

                          const SizedBox(width: 15,),
                          Flexible(
                            child: Text(
                              Provider.of<AppInfo>(context).userPickUpLocation != null
                                  ? Provider.of<AppInfo>(context).userPickUpLocation!.locationName!
                                  : "Not Getting Address",
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                              softWrap: false,
                              overflow: TextOverflow.ellipsis,
                            ),
                          )
                        ],
                      ),

                      const SizedBox(height: 20,),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(2),
                            decoration: BoxDecoration(
                              color: Colors.grey,
                              borderRadius: BorderRadius.circular(2),
                            ),
                            child: const Icon(
                              Icons.star,
                              color: Colors.white,
                            ),
                          ),

                          const SizedBox(width: 15,),
                          Flexible(
                            child: Text(
                              Provider.of<AppInfo>(context).userDropOffLocation != null
                                  ?Provider.of<AppInfo>(context).userDropOffLocation!.locationName!
                                  : "Where to?",
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18
                              ),
                              softWrap: false,
                              overflow: TextOverflow.ellipsis,
                            ),
                          )
                        ],
                      ),

                      const SizedBox(height: 20,),
                      const Text("SUGGESTED RIDES",
                        style: TextStyle(
                          fontWeight: FontWeight.bold
                        ),
                      ),

                      const SizedBox(height: 20,),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          GestureDetector(
                            onTap: (){
                              setState(() {
                                selectedVehicleType = "Car";
                              });
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                color: selectedVehicleType == "Car" ? (darkTheme ? Colors.amber[400] : Colors.blue) : (darkTheme ? Colors.black54 : Colors.grey[100]),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(25),
                                child: Column(
                                  children: [
                                    Image.asset("images/Car1.png", scale: 2,),

                                    const SizedBox(height: 8,),
                                    Text("Car",
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: selectedVehicleType == "Car" ? (darkTheme ? Colors.black : Colors.white) : (darkTheme ? Colors.white : Colors.black),
                                      ),
                                    ),

                                    const SizedBox(height: 2,),
                                    Text(
                                      tripDirectionDetailsInfo != null
                                          ? "₹ ${((AssistantMethods.calculateFareAmountFromOriginToDestination(tripDirectionDetailsInfo!) * 2) * 107).toStringAsFixed(1)}"
                                        : "null",
                                      style: const TextStyle(color: Colors.red),
                                    )
                                  ],
                                ),
                              ),
                            ),
                          ),

                          GestureDetector(
                            onTap: (){
                              setState(() {
                                selectedVehicleType = "CNG";
                              });
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                color: selectedVehicleType == "CNG" ? (darkTheme ? Colors.amber[400] : Colors.blue) : (darkTheme ? Colors.black54 : Colors.grey[100]),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(25),
                                child: Column(
                                  children: [
                                    Image.asset("images/CNG.png", scale: 1,),

                                    const SizedBox(height: 8,),
                                    Text("CNG",
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: selectedVehicleType == "CNG" ? (darkTheme ? Colors.black : Colors.white) : (darkTheme ? Colors.white : Colors.black),
                                      ),
                                    ),

                                    const SizedBox(height: 2,),
                                    Text(
                                      tripDirectionDetailsInfo != null
                                          ? "₹ ${((AssistantMethods.calculateFareAmountFromOriginToDestination(tripDirectionDetailsInfo!) * 1.5) * 107).toStringAsFixed(1)}"
                                          : "null",
                                      style: const TextStyle(color: Colors.red),
                                    )
                                  ],
                                ),
                              ),
                            ),
                          ),

                          GestureDetector(
                            onTap: (){
                              setState(() {
                                selectedVehicleType = "Bike";
                              });
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                color: selectedVehicleType == "Bike" ? (darkTheme ? Colors.amber[400] : Colors.blue) : (darkTheme ? Colors.black54 : Colors.grey[100]),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(25),
                                child: Column(
                                  children: [
                                    Image.asset("images/Bike.png", scale: 2,),

                                    const SizedBox(height: 8,),
                                    Text("Bike",
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: selectedVehicleType == "Bike" ? (darkTheme ? Colors.black : Colors.white) : (darkTheme ? Colors.white : Colors.black),
                                      ),
                                    ),

                                    const SizedBox(height: 2,),
                                    Text(
                                      tripDirectionDetailsInfo != null
                                          ? "₹ ${((AssistantMethods.calculateFareAmountFromOriginToDestination(tripDirectionDetailsInfo!) * 0.8) * 107).toStringAsFixed(1)}"
                                          : "null",
                                      style: const TextStyle(color: Colors.red),
                                    )
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),

                      // SizedBox(height: 20,),
                      // Expanded(
                      //   child: GestureDetector(
                      //     onTap: (){
                      //       if(selectedVehicleType != ""){
                      //         saveRideRequestInformation(selectedVehicleType);
                      //       }
                      //       else{
                      //         Fluttertoast.showToast(msg: "Please select a vehicle from \n suggested rides");
                      //       }
                      //     },
                      //     child: Container(
                      //       padding: EdgeInsets.all(12),
                      //       decoration: BoxDecoration(
                      //         color: darkTheme ? Colors.amber[400] : Colors.blue,
                      //         borderRadius: BorderRadius.circular(10),
                      //       ),
                      //       child: Center(
                      //         child: Text(
                      //           "Request a Ride",
                      //           style: TextStyle(
                      //             color: darkTheme ? Colors.black : Colors.white,
                      //             fontWeight: FontWeight.bold,
                      //             fontSize: 20
                      //           ),
                      //         ),
                      //       ),
                      //     ),
                      //   ),
                      // )

                    ],
                  ),
                ),
              ),
            ),

            // Requesting a ride
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                height: searchingForDriverContainerHeight,
                decoration: BoxDecoration(
                  color: darkTheme ? Colors.black : Colors.white,
                  borderRadius:  const BorderRadius.only(topLeft: Radius.circular(15), topRight: Radius.circular(15)),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      LinearProgressIndicator(
                        color: darkTheme ? Colors.amber[400] : Colors.blue,
                      ),

                      const SizedBox(height: 10,),
                      const Center(
                        child: Text(
                          "Searching for a driver...",
                          style: TextStyle(
                            color: Colors.grey,
                            fontSize: 22,
                            fontWeight: FontWeight.bold
                          ),
                        ),
                      ),

                      const SizedBox(height: 20,),
                      GestureDetector(
                        onTap: (){
                          referenceRideRequest!.remove(); //remove for rideRequestInfo
                          setState(() {
                            searchingForDriverContainerHeight = 0;
                            suggestedRidesContainerHeight = 0;
                          });
                        },
                        child: Container(
                          height: 50,
                          width: 50,
                          decoration: BoxDecoration(
                            color: darkTheme ? Colors.black : Colors.white,
                            borderRadius: BorderRadius.circular(25),
                            border: Border.all(width: 1, color: Colors.grey),
                          ),
                          child: const Icon(Icons.close, size: 25,),
                        ),
                      ),

                      const SizedBox(height: 15,),
                      Container(
                        width: double.infinity,
                        child: const Text(
                          "Cancel",
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.red, fontSize: 12, fontWeight: FontWeight.bold),
                        ),
                      )

                    ],
                  )
                  ,
                ),
              ),
            ),

            //UI for displaying assigned driver information
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                height: assignedDriverInfoContainerHeight,
                decoration: BoxDecoration(
                  color: darkTheme ? Colors.black : Colors.white,
                  borderRadius: BorderRadius.circular(10)
                ),
                child: Padding(
                  padding: const EdgeInsets.all(10),
                  child: Column(
                    children: [
                      Text(driverRideStatus, style: const TextStyle(fontWeight: FontWeight.bold),),
                      const SizedBox(height: 5,),
                      Divider(thickness: 1, color: darkTheme ? Colors.grey : Colors.grey[300],),
                      const SizedBox(height: 5,),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: darkTheme ? Colors.amber.shade400 : Colors.lightBlue,
                                  borderRadius: BorderRadius.circular(10)
                                ),
                                child: Icon(Icons.person, color: darkTheme ? Colors.black : Colors.white,),
                              ),

                              const SizedBox(width: 10,),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(driverName, style: const TextStyle(fontWeight:  FontWeight.bold),),

                                  Row(
                                    children: [
                                      const Icon(Icons.star, color: Colors.orange,),

                                      const SizedBox(width: 5,),
                                      Text(driverRatings,
                                        style: const TextStyle(color: Colors.grey),
                                      )
                                    ],
                                  )
                                ],
                              )
                            ],
                          ),

                          Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Image.asset("images/Car1.png", scale: 3,),
                              Text(driverCarDetails, style: const TextStyle(fontSize: 12),)
                            ],
                          )
                        ],
                      ),

                      const SizedBox(height: 5,),
                      Divider(thickness: 1, color: darkTheme ? Colors.grey : Colors.grey[300]),
                      ElevatedButton.icon(
                          onPressed: (){
                            _makePhoneCall("tel: ${driverPhone}");
                          },
                          style: ElevatedButton.styleFrom(backgroundColor: darkTheme ? Colors.amber.shade400 : Colors.blue),
                          icon: const Icon(Icons.phone),
                          label: const Text("Call Driver"),
                      )

                    ],
                  ),
                ),
              ),
            )

            // Positioned(
            //   top: 55,
            //   right: 20,
            //   left: 20,
            //   child: Container(
            //     decoration: BoxDecoration(
            //       border: Border.all(color: Colors.black),
            //       color: Colors.white,
            //     ),
            //     padding: EdgeInsets.all(20),
            //     child: Row(
            //       children: [
            //         Expanded(
            //           child: Text(
            //             Provider.of<AppInfo>(context).userPickUpLocation != null
            //                 ? Provider.of<AppInfo>(context).userPickUpLocation!.locationName!
            //                 : "Not Getting Address",
            //             style: TextStyle(color: Colors.black),
            //             overflow: TextOverflow.ellipsis, softWrap: false,
            //           ),
            //         ),
            //       ],
            //     ),
            //   ),
            // ),

          ],
        ),

      ),
    );
  }
}
