// ignore_for_file: unused_element, file_names, duplicate_ignore
// ignore_for_file: file_names, non_constant_identifier_names, avoid_print, use_build_context_synchronously, no_leading_underscores_for_local_identifiers, unused_field, unused_local_variable, unused_element, prefer_final_fields, prefer_typing_uninitialized_variables, must_be_immutable, await_only_futures

import 'dart:async';
import 'dart:math';
import 'package:audioplayers/audioplayers.dart';
import 'package:background_sms/background_sms.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lottie/lottie.dart';
import 'package:noise_meter/noise_meter.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:safeher3/riverpod.dart';
import 'package:sensors_plus/sensors_plus.dart';

import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vibration/vibration.dart';

class OfflineActivator extends ConsumerStatefulWidget {
  const OfflineActivator(
      {super.key, required this.sms_sender, required this.noise_meter});

  final sms_sender;
  final noise_meter;

  @override
  ConsumerState<OfflineActivator> createState() => _OfflineActivatorState();
}

class _OfflineActivatorState extends ConsumerState<OfflineActivator> {
  // AudioPlayer audioPlayer = AudioPlayer();
  int threat = 0;
  int isfallen = 0;
  bool canShowAppPrompt = true;
  bool isRunning = false;
  AudioPlayer audioPlayer = AudioPlayer();
  late Timer cooldowntimer;
  bool canshow = true;

  void playAudio() async {
    audioPlayer.play(AssetSource('siren.mp3'));
  }

  void _showLottieDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          child: Container(
            width: 200,
            height: 200,
            padding: const EdgeInsets.all(16.0),
            child: Lottie.asset(
              'assets/check.json',
              width: 150,
              height: 150,
              onLoaded: (p0) {
                popdata(context);
              },
            ),
          ),
        );
      },
    );
  }

  popdata(BuildContext context) async {
    await Future.delayed(const Duration(seconds: 2));
    Navigator.pop(context);
  }

  void _VibConfo() async {
    final hasVibrator = await Vibration.hasVibrator();

    if (hasVibrator ?? false) {
      Vibration.vibrate(duration: 2000);
    }
  }

  // This FUNCTION IS FOR THE APP PROMPT
  void startTimer() async {
    // audioPlayer.play(AssetSource('safety.mp3'));
    if (canShowAppPrompt && canshow) {
      setState(() {
        canshow = false;
      });
      _triggerVibration();
      showDialog(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext context) {
            return AlertDialog(
                title: const Text("ARE YOU SAFE?"),
                content: const Text('Press Yes If You Are Safe'),
                actions: <Widget>[
                  ElevatedButton(
                      child: const Text(
                        'Yes',
                        style: TextStyle(color: Colors.black),
                      ),
                      onPressed: () {
                        Navigator.of(context, rootNavigator: true)
                            .pop(); // close the dialog
                        threat = 1;
                        // audioPlayer.stop();
                        Vibration.cancel();
                        setState(() {
                          canShowAppPrompt = true;
                        });
                      })
                ]);
          });
      await Future.delayed(const Duration(seconds: 10));

      if (threat == 0) {
        print("VOICE THREAT");
        Navigator.of(context, rootNavigator: true).pop();
        stop();
        Vibration.cancel();
        if (await _isPermissionGranted()) {
          _sendMessage("+918882774087", """Need help""", 1);
        }
        _showLottieDialog(context);
        _VibConfo();
        // audioPlayer.play(AssetSource('siren.mp3'));
        // await Future.delayed(const Duration(seconds: 10));
        // audioPlayer.stop();
      } else {
        print("WRONG DETECTION FOR VOICE");
        threat = 0;
        canShowAppPrompt = true;
        Vibration.cancel();
        setState(() {
          canshow = true;
        });
      }
    }
  }

  // This Function Is For FALL DETECTION
  void fall_detection() {
    accelerometerEvents.listen((AccelerometerEvent event) {
      num _accelX = event.x.abs();
      num _accelY = event.y.abs();
      num _accelZ = event.z.abs();
      num x = pow(_accelX, 2);
      num y = pow(_accelY, 2);
      num z = pow(_accelZ, 2);
      num sum = x + y + z;
      num result = sqrt(sum);
      // print("accz = $_accelZ");
      // print("accx = $_accelX");
      // print("accy = $_accelY");
      if ((result < 1) ||
          (result > 70 && _accelZ > 60 && _accelX > 60) ||
          (result > 70 && _accelX > 60 && _accelY > 60)) {
        // print("res = $result");
        // print("accz = $_accelZ");
        // print("accx = $_accelX");
        // print("accy = $_accelY");
        if (canShowAppPrompt) {
          fallTimer();
          startCooldown();
        }
      }
    });
  }

// vibrate triggger
  void _triggerVibration() async {
    final hasVibrator = await Vibration.hasVibrator();

    if (hasVibrator ?? false) {
      Vibration.vibrate(duration: 10000);
    }
  }

  // FAll Timer for fall detection
  void fallTimer() async {
    // audioPlayer.play(AssetSource('safety.mp3'));
    if (canShowAppPrompt && canshow) {
      setState(() {
        canshow = false;
      });
      _triggerVibration();
      showDialog(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext context) {
            return AlertDialog(
                title: const Text('Did Your Phone Fell Accidently?'),
                content: const Text('Press Yes If Its An fall detection'),
                actions: <Widget>[
                  ElevatedButton(
                      child: const Text(
                        'Yes',
                        style: TextStyle(color: Colors.black),
                      ),
                      onPressed: () {
                        Navigator.of(context, rootNavigator: true)
                            .pop(); // close the dialog
                        isfallen = 1;
                        Vibration.cancel();
                        setState(() {
                          canShowAppPrompt = true;
                        });
                      })
                ]);
          });
      await Future.delayed(const Duration(seconds: 10));
      if (isfallen == 0) {
        print("FALL THREAT");
        Navigator.of(context, rootNavigator: true).pop();
        stop();
        Vibration.cancel();
        if (await _isPermissionGranted()) {
          _sendMessage("+918638332396", """Need help""", 1);
          _showLottieDialog(context);
          _VibConfo();
          // audioPlayer.play(AssetSource('siren.mp3'));
          // await Future.delayed(const Duration(seconds: 10));
          // audioPlayer.stop();
        } else {
          _getPermission();
        }
      } else {
        print("WRONG DETECTION FOR FALL");
        isfallen = 0;
        canShowAppPrompt = true;
        Vibration.cancel();
        setState(() {
          canshow = true;
        });
      }
    }
  }

  // Cool Down Code Function For App Prompt
  void startCooldown() {
    setState(() {
      canShowAppPrompt = false;
    });
  }

  //Sms Sender code
  _getPermission() {
    return Permission.sms.request();
  }

  Future<bool> _isPermissionGranted() {
    return Permission.sms.status.isGranted;
  }

  Future<bool?> get _supportCustomSim {
    return BackgroundSms.isSupportCustomSim;
  }

  _sendMessage(String phoneNumber, String message, int simSlot) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool contactpckd = await prefs.getBool('contactpckd') ?? false;
    bool emailpckd = await prefs.getBool('emailpckd') ?? false;
    late String num1 = "", num2 = "", num3 = "";
    if (contactpckd) {
      num1 = await prefs.getString('number1').toString().trim();
      num2 = await prefs.getString('number2').toString().trim();
      num3 = await prefs.getString('number3').toString().trim();
    }
    if (num1 != "" && num1 != 'null') {
      var result = await BackgroundSms.sendMessage(
          phoneNumber: "+91+$num1", message: message, simSlot: 1);
      if (result == SmsStatus.sent) {
        print("Sent");
      } else {
        print("Failed");
      }
    }
    if (num2 != "" && num2 != 'null') {
      if (await _isPermissionGranted()) {
        var result1 = await BackgroundSms.sendMessage(
            phoneNumber: "+91+$num2", message: message, simSlot: 1);
        if (result1 == SmsStatus.sent) {
          print("Sent");
        } else {
          print("Failed");
        }
      }
    }
    if (num3 != "" && num3 != 'null') {
      if (await _isPermissionGranted()) {
        var result3 = await BackgroundSms.sendMessage(
            phoneNumber: "+91+$num3", message: message, simSlot: 1);
        if (result3 == SmsStatus.sent) {
          print("Sent");
        } else {
          print("Failed");
        }
      }
    }
  }

  // Offline device function call
  bool _isRecording = false;
  NoiseReading? _latestReading;
  StreamSubscription<NoiseReading>? _noiseSubscription;
  // Functions
  void onData(NoiseReading noiseReading) {
    fall_detection();
    setState(() {
      _latestReading = noiseReading;
      if (!_isRecording) _isRecording = true;
    });
    if (_latestReading!.maxDecibel >= 87) {
      print(_latestReading!.maxDecibel);
      if (canshow) {
        startTimer();
      }
    }
  }

  void onError(Object error) {
    print(error);
    _isRecording = false;
  }

  void start() {
    try {
      _noiseSubscription = widget.noise_meter?.noise.listen(onData);
    } catch (err) {
      print("Not Initilized");
    }
  }

  void stop() {
    try {
      _noiseSubscription?.cancel();
      setState(() {
        _isRecording = false;
      });
    } catch (err) {
      print(err);
    }
  }

  @override
  Widget build(BuildContext context) {
    isRunning = ref.watch(ShieldStateProvider);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 5),
      child: InkWell(
        onTap: () async {
          ref.read(ShieldStateProvider.notifier).toogleshieldstate();
          //print(isRunning);
          await _getPermission();
          start();
          //Call your finctions here to start the service.
        },
        child: Padding(
          padding: const EdgeInsets.all(5.0),
          child: Card(
            elevation: 5,
            color: isRunning
                ? const Color.fromARGB(101, 0, 212, 109)
                : const Color.fromRGBO(192, 3, 3, 0.397),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            child: Container(
              height: 180,
              width: MediaQuery.of(context).size.width * 0.9,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        ListTile(
                          title: isRunning
                              ? const Text(
                                  "Shield On",
                                  style: TextStyle(
                                      color: Colors.white, fontSize: 25),
                                )
                              : const Text(
                                  "Shield Off",
                                  style: TextStyle(
                                      color: Colors.white, fontSize: 25),
                                ),
                          subtitle: isRunning
                              ? const Text(
                                  "Services are up and running",
                                  style: TextStyle(
                                      color: Colors.white, fontSize: 15),
                                )
                              : const Text(
                                  "Tap to activate services.",
                                  style: TextStyle(
                                      color: Colors.white, fontSize: 15),
                                ),
                        ),
                        Visibility(
                          visible: isRunning,
                          child: const Padding(
                              padding: EdgeInsets.all(18.0),
                              child: Row(
                                children: [
                                  SpinKitDoubleBounce(
                                    color: Color.fromARGB(255, 5, 94, 45),
                                    size: 15,
                                  ),
                                  SizedBox(width: 2),
                                  Text("Currently Running",
                                      style: TextStyle(
                                          color:
                                              Color.fromARGB(255, 5, 94, 45))),
                                ],
                              )),
                        ),
                      ],
                    ),
                  ),
                  ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: Icon(
                        Icons.shield_outlined,
                        color: isRunning
                            ? const Color.fromARGB(164, 0, 75, 39)
                            : const Color.fromRGBO(90, 0, 0, 0.671),
                        size: 150,
                      ))
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
