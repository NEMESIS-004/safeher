import 'dart:async';

import 'package:flutter/material.dart';
import 'package:safeher3/aman/Assistants/assistant_methods.dart';
import 'package:safeher3/aman/global/global.dart';
import 'package:safeher3/aman/screens/login_screen.dart';
import 'package:safeher3/aman/screens/main_screen.dart';


class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {

  startTimer(){
    Timer(const Duration(seconds: 3), () async{
      if(firebaseAuth.currentUser != null){
        firebaseAuth.currentUser != null ? AssistantMethods.readCurrentOnlineUserInfo() : null;
        Navigator.push(context, MaterialPageRoute(builder: (c) => const MainScreen()));
      }
      else{
        Navigator.push(context, MaterialPageRoute(builder: (c) => const LoginScreen()));
      }
    });
  }

  @override
  void initState() {
    super.initState();
    startTimer();
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text(
            "Trippo",
          style: TextStyle(
            fontSize: 40,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
