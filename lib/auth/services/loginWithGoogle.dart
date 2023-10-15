// ignore_for_file: file_names, camel_case_types

import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class googleservicelog {
  signInWithGoogle() async {
    final GoogleSignInAccount? guser = await GoogleSignIn().signIn();
    final GoogleSignInAuthentication gauth = await guser!.authentication;

    final credential = GoogleAuthProvider.credential(
      accessToken: gauth.idToken,
      idToken: gauth.idToken,
    );
    return await FirebaseAuth.instance.signInWithCredential(credential);
  }
}
