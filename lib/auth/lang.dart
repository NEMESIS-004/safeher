// ignore_for_file: dead_code

import 'package:flutter/material.dart';
import 'package:safeher3/auth/onboardingPage.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MyWidget extends StatefulWidget {
  const MyWidget({super.key});

  @override
  State<MyWidget> createState() => _MyWidgetState();
}

class _MyWidgetState extends State<MyWidget> {
  @override
  Widget build(BuildContext context) {
    bool lang = false;
    return SimpleDialog(
      title: lang ? const Text('भाषा चुने') : const Text('Select Language'),
      children: [
        SimpleDialogOption(
          onPressed: () async {
            SharedPreferences prefs = await SharedPreferences.getInstance();
            setState(() {
              lang = true;
              prefs.setString('lang', 'hindi');
            });
            // ignore: use_build_context_synchronously
            Navigator.pushReplacementNamed(context, OnboardingPage.routeName);
          },
          child: const Text('हिंदी',
              style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.w400,
                  fontSize: 16)),
        ),
        SimpleDialogOption(
          onPressed: () async {
            SharedPreferences prefs = await SharedPreferences.getInstance();
            setState(() {
              lang = false;
              prefs.setString('lang', 'english');
            });
            // ignore: use_build_context_synchronously
            Navigator.pushReplacementNamed(context, OnboardingPage.routeName);
          },
          child: const Text('English',
              style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.w400,
                  fontSize: 16)),
        ),
      ],
    );
  }
}
