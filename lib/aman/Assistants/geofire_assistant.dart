import '../models/active_nearby_available_drivers.dart';

class GeoFireAssistant {
  static List<ActiveNearByAvailableDrivers> activeNearByAvailableDriverList = [];

  static void deleteOfflineDriverFromList(String driverId){
    int indexNumber = activeNearByAvailableDriverList.indexWhere((element) => element.driverId == driverId);
    activeNearByAvailableDriverList.removeAt(indexNumber);
  }

  static void updateActiveNearByAvailableDriverLocation(ActiveNearByAvailableDrivers driverWhoMove){
    int indexNumber = activeNearByAvailableDriverList.indexWhere((element) => element.driverId == driverWhoMove.driverId);

    activeNearByAvailableDriverList[indexNumber].locationLatitude = driverWhoMove.locationLatitude;
    activeNearByAvailableDriverList[indexNumber].locationLongitude = driverWhoMove.locationLongitude;
  }

}