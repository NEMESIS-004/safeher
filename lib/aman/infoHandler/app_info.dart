import 'package:flutter/cupertino.dart';
import 'package:safeher3/aman/models/directions.dart';
import 'package:safeher3/aman/models/trips_history_model.dart';
// import 'package:user_ride/models/directions.dart';
// import 'package:user_ride/models/trips_history_model.dart';

class AppInfo extends ChangeNotifier{
  Directions? userPickUpLocation, userDropOffLocation;
  int countTotalTrips = 0;
  List<String> historyTripsKeyList = [];
  List<TripsHistoryModel> allTripsHistoryInformationList = [];

 void updatePickUpLocationAddress(Directions userPickUpAddress){
   userPickUpLocation = userPickUpAddress;
   notifyListeners();
 }
  void updateDropOffLocationAddress(Directions dropOffAddress){
    userDropOffLocation = dropOffAddress;
    notifyListeners();
  }

  updateOverAllTripsCounter(int overAllTripsCounter){
   countTotalTrips = overAllTripsCounter;
   notifyListeners();
  }

  updateOverAllTripsKeys(List<String> tripKeysList){
   historyTripsKeyList = tripKeysList;
   notifyListeners();
  }

  updateOverAllTripsHistoryInformation(TripsHistoryModel eachTripHistory){
   allTripsHistoryInformationList.add(eachTripHistory);
   notifyListeners();
  }

}