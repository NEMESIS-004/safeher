import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:safeher3/auth/loginPage.dart';
import 'package:safeher3/auth/onboardingPage.dart';
import 'package:safeher3/auth/signupPage.dart';
import 'package:safeher3/home/view/home.dart';
import 'package:safeher3/home/view/mainRender.dart';
import 'package:safeher3/home/view/profilePage.dart';
import 'package:safeher3/home/view/settings.dart';
import 'package:safeher3/splashScreen.dart';

import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "SafeHer",
      theme: ThemeData(
        fontFamily: 'Mulish',
        primaryColor: Colors.pinkAccent,
        primarySwatch: Colors.pink,
      ),
      home: const SplashScreen(),
      debugShowCheckedModeBanner: false,
      routes: {
        HomePage.routeName: (ctx) => const HomePage(),
        LoginPage.routeName: (ctx) => const LoginPage(),
        SignUpPage.routeName: (ctx) => const SignUpPage(),
        OnboardingPage.routeName: (ctx) => OnboardingPage(),
        ProfilePage.routeName: (ctx) => const ProfilePage(),
        SettingPage.routeName: (ctx) => const SettingPage(),
        MainRender.routeName: (ctx) => const MainRender(),
      },
    );
  }
}
