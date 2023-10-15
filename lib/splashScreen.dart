// ignore_for_file: unused_local_variable, unnecessary_null_comparison, file_names, avoid_unnecessary_containers

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:safeher3/auth/lang.dart';
import 'package:safeher3/auth/loginPage.dart';
import 'package:safeher3/home/view/mainRender.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:lottie/lottie.dart';
import 'dart:async';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});
  static const String routeName = "/splashScreen";
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  Future checkFirstSeen() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool seen = (prefs.getBool('seen') ?? false);
    //print(_seen);

    if (seen) {
      _handleStartScreen();
      if (!mounted) return;
      Navigator.pushReplacementNamed(context, LoginPage.routeName);
    } else {
      await prefs.setBool('seen', true);
      if (!mounted) return;
      Navigator.push(
          context, MaterialPageRoute(builder: (context) => const MyWidget()));
    }
  }

  Future<void> _handleStartScreen() async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;
    if (FirebaseAuth.instance.currentUser! == null) {
      Navigator.popAndPushNamed(context, LoginPage.routeName);
    } else {
      Navigator.popAndPushNamed(context, MainRender.routeName);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Center(
      child: Container(
        child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Image.asset(
                'assets/logo.png',
                height: MediaQuery.of(context).size.width * 0.6,
              ),
              LottieBuilder.asset(
                'assets/animations/dots.json',
                height: MediaQuery.of(context).size.width * 0.5,
                fit: BoxFit.fill,
              ),
            ]),
      ),
    ));
  }

  @override
  void initState() {
    super.initState();
    Timer(const Duration(seconds: 3), () {
      checkFirstSeen();
    });
  }
}
