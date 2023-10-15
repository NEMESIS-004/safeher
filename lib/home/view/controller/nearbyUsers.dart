// ignore_for_file: file_names

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geoflutterfire2/geoflutterfire2.dart';

class NearbyUsers {
  GeoFirePoint center;
  final geo = GeoFlutterFire();
  NearbyUsers(this.center);

  Stream<List<DocumentSnapshot>> get() {
    var collectionReference =
        FirebaseFirestore.instance.collection('community');
    double radius = 5;
    String field = 'position';

    Stream<List<DocumentSnapshot>> streamOfNearby = geo
        .collection(collectionRef: collectionReference)
        .within(center: center, radius: radius, field: field, strictMode: true);
    return streamOfNearby;
  }
}
