// ignore_for_file: file_names

import 'package:concentric_transition/concentric_transition.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:safeher3/auth/signupPage.dart';
import 'package:safeher3/auth/widgets/onboardingCard.dart';


class OnboardingPage extends StatelessWidget {
  OnboardingPage({Key? key}) : super(key: key);
  static const routeName = 'onboarding';
  final data = [
    OnBoardingData(
      title: "Title1",
      subtitle:
          "Some text with bla bla aaditya aman pragati aryan yash saurabh",
      image: LottieBuilder.asset("assets/animations/womenHi.json"),
      backgroundColor: const Color.fromRGBO(0, 10, 56, 1),
      titleColor: Colors.pink,
      subtitleColor: Colors.white,
      background: LottieBuilder.asset("assets/animations/bg-1.json"),
    ),
    OnBoardingData(
      title: "Title2",
      subtitle: "Some text with bla bla aaditya aman pragati aryan yash saurabh Some text with bla bla aaditya aman pragati aryan yash saurabh",
      image: LottieBuilder.asset("assets/animations/womenWalking.json"),
      backgroundColor: Colors.white,
      titleColor: Colors.purple,
      subtitleColor: const Color.fromRGBO(0, 10, 56, 1),
      background: LottieBuilder.asset("assets/animations/bg-2.json"),
    ),
    OnBoardingData(
      title: "Title3",
      subtitle: "Some text with bla bla aaditya aman pragati aryan yash saurabhSome text with bla bla aaditya aman pragati aryan yash saurabh",
      image: LottieBuilder.asset("assets/animations/womenMessage.json"),
      backgroundColor: const Color.fromRGBO(71, 59, 117, 1),
      titleColor: Colors.yellow,
      subtitleColor: Colors.white,
      background: LottieBuilder.asset("assets/animations/bg-3.json"),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ConcentricPageView(

        duration: const Duration(seconds: 4),
        colors: data.map((e) => e.backgroundColor).toList(),
        itemCount: data.length,
        itemBuilder: (int index) {
          return OnBoardingCard(data: data[index]);
        },
        onFinish: () {
          Navigator.pushReplacementNamed(
            context, SignUpPage.routeName
          );
        },
      ),
    );
  }
}