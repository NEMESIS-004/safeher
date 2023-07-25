// ignore_for_file: file_names, camel_case_types

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:geoflutterfire2/geoflutterfire2.dart';
import 'package:google_sign_in/google_sign_in.dart';

class googleservice {
  signUpWithGoogle(String fname, String lname, String phone) async {
    final GoogleSignInAccount? guser = await GoogleSignIn().signIn();
    final GoogleSignInAuthentication gauth = await guser!.authentication;

    final credential = GoogleAuthProvider.credential(
      accessToken: gauth.idToken,
      idToken: gauth.idToken,
    );
    final geo = GeoFlutterFire();
    GeoFirePoint userLocation = geo.point(
        latitude:0.0,
        longitude: 0.0);
    return await FirebaseAuth.instance
        .signInWithCredential(credential)
        .then((value) {
      FirebaseFirestore.instance.collection('userdata').doc(value.user!.uid).set({
        "email": guser.email,
        "firstName": fname,
        "lastName": lname,
        "phone": phone,
        "profilepic": guser.photoUrl,
        "position" : userLocation.data,
      });
    });
  }
}
