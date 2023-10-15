// ignore_for_file: file_names, use_build_context_synchronously, unused_import

import 'package:flutter/material.dart';
import 'package:safeher3/auth/services/loginWithGoogle.dart';
import 'package:safeher3/home/view/home.dart';
import 'package:safeher3/home/view/mainRender.dart';

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
            // await googleservice().signInWithGoogle();
            // Navigator.of(context).pushNamedAndRemoveUntil(
            //     MainRender.routeName, (route) => false);
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
