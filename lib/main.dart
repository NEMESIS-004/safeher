// ignore_for_file: unused_element

import 'package:background_sms/background_sms.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:safeher3/auth/loginPage.dart';
import 'package:safeher3/auth/onboardingPage.dart';
import 'package:safeher3/auth/signupPage.dart';
import 'package:safeher3/home/view/home.dart';
import 'package:safeher3/home/view/mainRender.dart';
import 'package:safeher3/home/view/profilePage.dart';
import 'package:safeher3/home/view/settings.dart';
import 'package:safeher3/splashScreen.dart';
import 'firebase_options.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  // This widget is the root of your application.

  _getPermission() {
    return Permission.sms.request();
  }

  Future<bool> _isPermissionGranted() {
    return Permission.sms.status.isGranted;
  }

  Future<bool?> get _supportCustomSim {
    return BackgroundSms.isSupportCustomSim;
  }

  @override
  void initState() {
    super.initState();
    _getPermission();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "SafeHer",
      theme: ThemeData(
        fontFamily: 'Mulish',
        primaryColor: Colors.pinkAccent,
        primarySwatch: Colors.pink,
      ),
      supportedLocales: const [Locale('en'), Locale('hi')],
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      home: const SplashScreen(),
      debugShowCheckedModeBanner: false,
      routes: {
        HomePage.routeName: (ctx) => const HomePage(),
        LoginPage.routeName: (ctx) => const LoginPage(),
        SignUpPage.routeName: (ctx) => const SignUpPage(),
        OnboardingPage.routeName: (ctx) => const OnboardingPage(),
        ProfilePage.routeName: (ctx) => const ProfilePage(),
        SettingPage.routeName: (ctx) => const SettingPage(),
        MainRender.routeName: (ctx) => const MainRender(),
      },
    );
  }
}
