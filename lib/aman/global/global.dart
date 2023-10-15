import 'package:firebase_auth/firebase_auth.dart';
import 'package:safeher3/aman/models/direction_details_info.dart';
// import 'package:user_ride/models/direction_details_info.dart';

import '../models/user_model.dart';

final FirebaseAuth firebaseAuth = FirebaseAuth.instance;
User? currentUser;

UserModel? userModelCurrentInfo;

String cloudMessagingServerToken =
    "key=AAAASFXqpIc:APA91bFsGrMUkEmHiq6Cg__dBJA0x1mOsV4RqPS0waFFkJPLcdW6sYqwkPC4FYjiCnq6qqnYh0w2zsKGV1hS31Si2Kw5gYzu2iAylojaJm4pYnPQO_nZOmZDnJ2xSGjaLKkHvHoOrF7T";
List driversList = [];
DirectionDetailsInfo? tripDirectionDetailsInfo;
String userDropOffAddress = "";
String driverCarDetails = "";
String driverName = "";
String driverPhone = "";
String driverRatings = "";

double countRatingStar = 0.0;
String titleStarsRating = "";
