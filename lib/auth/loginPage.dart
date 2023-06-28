// ignore_for_file: file_names, use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:safeher3/alert.dart';
import 'package:safeher3/auth/services/loginWithGoogle.dart';



class LoginPage extends StatefulWidget {
  const LoginPage({super.key});
  static const String routeName = "/loginScreen";
  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
          child: Center(
        child: MaterialButton(
          onPressed: () async {
            await googleservice().signInWithGoogle();
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const alertpage()),
            );
          },
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
          color: Colors.amber,
          child: const SizedBox(
            child: Row(
              children: [
                Text("Google"),
              ],
            ),
          ),
        ),
      )),
    );
  }
}
