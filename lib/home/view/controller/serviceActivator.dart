// ignore_for_file: file_names, non_constant_identifier_names, avoid_print, use_build_context_synchronously, no_leading_underscores_for_local_identifiers, unused_field, unused_local_variable, unused_element, prefer_final_fields, prefer_typing_uninitialized_variables, must_be_immutable, await_only_futures, unused_import

import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'package:background_sms/background_sms.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:csv/csv.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geoflutterfire2/geoflutterfire2.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:lottie/lottie.dart';
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server/gmail.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:safeher3/home/view/controller/nearbyUsers.dart';
import 'package:safeher3/riverpod.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:string_similarity/string_similarity.dart';
import 'package:vibration/vibration.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class ServiceActivator extends ConsumerStatefulWidget {
  const ServiceActivator(
      {super.key,
      required this.cameras,
      required this.controller,
      required this.videoController,
      required this.sms_sender});

  final cameras;
  final controller;
  final sms_sender;
  final videoController;

  @override
  ConsumerState<ServiceActivator> createState() => _ServiceActivatorState();
}

class _ServiceActivatorState extends ConsumerState<ServiceActivator> {
  final stt.SpeechToText _speech = stt.SpeechToText();

  String sta = "done";
  String out = "0";
  int threat = 0;
  late String filePath = "";
  int isfallen = 0;
  bool canShowAppPrompt = true;
  bool isRunning = false;
  late Timer cooldowntimer;
  bool onchange = false;
  late Timer timer;
  late double latitude;
  late double longitude;
  late String userName;
  bool langLoad = false;
  String lang = "";

  // This function ask for Permissions and give status of it
  void _setupSpeechRecognition() async {
    fall_detection();
    bool available = await _speech.initialize(
      onStatus: (status) {
        // print('Speech recognition status: $status');
      },
      onError: (error) {
        // print('Speech recognition error: $error');
        _startListening();
      },
    );
    if (available) {
      print('Speech recognition is available');
      _startListening();
    } else {
      // print('Speech recognition is not available');
    }
  }

// This function is to SEND DATA AND RECIEVE THE PREDICTED OUTPUT
  void data_from_api(String text) async {
    final csvString =
        await rootBundle.loadString('assets/Women_Safety_dataset.csv');
    final csvData = const CsvToListConverter().convert(csvString);
    for (final row in csvData) {
      if (row.isNotEmpty) {
        String string1 = row[0].toString().toLowerCase();
        var similarity = text.similarityTo(string1);
        if (similarity >= 0.6 && canShowAppPrompt == true) {
          print(similarity);
          startTimer();
          startCooldown();
          break;
        }
      }
    }
  }

// THIS FUNCTION LISTEN TO THE MICROPHONE AND GIVE THE TEXT GENERATED
  void _startListening() {
    _speech.listen(
      listenFor: const Duration(seconds: 5),
      onResult: (result) {
        if (result.finalResult) {
          String text = result.recognizedWords;
          print('Recognized text: $text');
          data_from_api(text.toLowerCase());
        }
        if (!_speech.isListening || sta == "done") {
          _startListening();
        }
      },
    );
  }

  // This FUNCTION IS FOR THE APP PROMPT
  void startTimer() async {
    _triggerVibration();
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return AlertDialog(
              title: Localizations.override(
                  context: context,
                  locale: (lang == 'english')
                      ? const Locale('en')
                      : const Locale('hi'),
                  child: Builder(builder: (context) {
                    return Text(AppLocalizations.of(context)!.areYouSafe);
                  })),
              content: Localizations.override(
                  context: context,
                  locale: (lang == 'english')
                      ? const Locale('en')
                      : const Locale('hi'),
                  child: Builder(builder: (context) {
                    return Text(AppLocalizations.of(context)!.pressYes);
                  })),
              actions: <Widget>[
                ElevatedButton(
                    child: Localizations.override(
                      context: context,
                      locale: (lang == 'english')
                          ? const Locale('en')
                          : const Locale('hi'),
                      child: Builder(builder: (context) {
                        return Text(
                          AppLocalizations.of(context)!.yes,
                          style: const TextStyle(color: Colors.black),
                        );
                      }),
                    ),
                    onPressed: () {
                      Navigator.of(context, rootNavigator: true)
                          .pop(); // close the dialog
                      threat = 1;
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
      Vibration.cancel();
      add_threat_data();
      await widget.controller.initialize();
      await fetchLocation();
      await _sendEmailToCommunity();
      await _startRecording();
      if (await _isPermissionGranted()) {
        _sendMessage(
            "+918882774087",
            """Need help My Location is https://www.google.com/maps/place/$latitude+$longitude""",
            1);
        _showLottieDialog(context);
        _VibConfo();
      }
    } else {
      print("WRONG DETECTION FOR VOICE");
      threat = 0;
      canShowAppPrompt = true;
      Vibration.cancel();
    }
  }

  // Adding Threat data
  add_threat_data() async {
    final _userId = await FirebaseAuth.instance.currentUser!.uid;
    final _dbref = FirebaseFirestore.instance.collection('userdata');
    DocumentSnapshot document = await _dbref.doc(_userId).get();
    final map = document.data() as Map;
    debugPrint(map.toString());
    FirebaseFirestore.instance.collection('sos_generation').doc().set({
      "email": map["email"],
      "Name": map["firstName"],
      "phone": map["phone"],
      "position": map["position"],
      "time": DateTime.now(),
    });
  }

// Audio Player Function
  // void playAudio() async {
  //   audioPlayer.play(AssetSource('siren.mp3'));
  // }

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
    _triggerVibration();
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return AlertDialog(
              title: Localizations.override(
                  context: context,
                  locale: (lang == 'english')
                      ? const Locale('en')
                      : const Locale('hi'),
                  child: Builder(builder: (context) {
                    return Text(
                        AppLocalizations.of(context)!.phoneFallAccident);
                  })),
              content: Localizations.override(
                  context: context,
                  locale: (lang == 'english')
                      ? const Locale('en')
                      : const Locale('hi'),
                  child: Builder(builder: (context) {
                    return Text(AppLocalizations.of(context)!.pressYesFall);
                  })),
              actions: <Widget>[
                ElevatedButton(
                    child: Localizations.override(
                      context: context,
                      locale: (lang == 'english')
                          ? const Locale('en')
                          : const Locale('hi'),
                      child: Builder(builder: (context) {
                        return Text(
                          AppLocalizations.of(context)!.yes,
                          style: const TextStyle(color: Colors.black),
                        );
                      }),
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
      Vibration.cancel();
      add_threat_data();
      await widget.controller.initialize();
      await fetchLocation();
      await _sendEmailToCommunity();
      await _startRecording();
      if (await _isPermissionGranted()) {
        _sendMessage(
            "+918638332396",
            """Need help My Location is https://www.google.com/maps/place/$latitude+$longitude""",
            1);
        // audioPlayer.play(AssetSource('siren.mp3'));
        // await Future.delayed(const Duration(seconds: 10));
        // audioPlayer.stop();
        _showLottieDialog(context);
        _VibConfo();
      }
    } else {
      print("WRONG DETECTION FOR FALL");
      isfallen = 0;
      canShowAppPrompt = true;
      Vibration.cancel();
    }
  }

  // Cool Down Code Function For App Prompt
  void startCooldown() {
    setState(() {
      canShowAppPrompt = false;
    });
  }

  Future<void> _startRecording() async {
    if (!widget.controller.value.isInitialized) {
      return;
    }

    final Directory appDirectory = await getApplicationDocumentsDirectory();
    final String videoDirectory = '${appDirectory.path}/Videos';
    await Directory(videoDirectory).create(recursive: true);

    final String currentTime = DateTime.now().millisecondsSinceEpoch.toString();
    filePath = '$videoDirectory/$currentTime.mp4';

    try {
      await widget.controller.startVideoRecording();
      cooldowntimer = Timer(const Duration(seconds: 30), () {
        _stopRecording(filePath);
      });
    } catch (error) {
      print(error);
    }
  }

  Future<void> _stopRecording(String filePath) async {
    if (!widget.controller.value.isRecordingVideo) {
      return;
    }

    try {
      final newpath = await widget.controller.stopVideoRecording();
      await _sendEmailWithVideo(newpath.path);
    } catch (error) {
      print("e,e,fefefe");
    } finally {
      _startRecording(); // Dispose the camera controller
    }
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

  Future<void> _sendEmailWithVideo(String filePath) async {
    final smtpServer = gmail('helppaws24by7@gmail.com', 'tncucbjrxhuxwoll');
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool contactpckd = await prefs.getBool('contactpckd') ?? false;
    bool emailpckd = await prefs.getBool('emailpckd') ?? false;
    late String email1 = "", email2 = "", email3 = "";
    if (emailpckd) {
      email1 = await prefs.getString('email1').toString();
      email2 = await prefs.getString('email2').toString();
      email3 = await prefs.getString('email3').toString();
    }
    List<String> ccList = [];
    if (email1 != "" && email1 != 'null') {
      ccList.add(email1);
    }
    if (email2 != "" && email2 != 'null') {
      ccList.add(email2);
    }
    if (email3 != "" && email3 != 'null') {
      ccList.add(email3);
    }
    final message = Message()
      ..from = const Address('helppaws24by7@gmail.com', 'Team SafeHer')
      ..recipients.add('priya.priyanka.ps.ps@gmail.com')
      ..subject = 'Video Email'
      ..html =
          "<p>Hey! We identified that $userName is in some trouble and needs your help</p><br><b><a href='https://maps.google.com/?q=$latitude,$longitude'>View Her Location on Google Maps</a></b><br><br>A short video we captured of the incident has been attached below<br>Regards<br>Team SafeHer";
    if (ccList.isNotEmpty) {
      message.ccRecipients.addAll(ccList);
    }
    final videoFile = File(filePath);
    if (videoFile.existsSync()) {
      message.attachments.add(FileAttachment(videoFile));
    } else {
      print('Video file does not exist: $filePath');
      return;
    }

    try {
      final sendReport = await send(message, smtpServer);
      // audioPlayer.play(AssetSource('siren.mp3'));
      // await Future.delayed(const Duration(seconds: 10));
      // audioPlayer.stop();
    } catch (error) {
      print('Error sending email: $error');
    }
  }

  _sendEmailToCommunity() async {
    final geo = GeoFlutterFire();
    GeoFirePoint center = geo.point(latitude: latitude, longitude: longitude);
    NearbyUsers nbyu = NearbyUsers(center);
    var _currentEntries = nbyu.get();

    _currentEntries.listen((listOfSnapshots) async {
      for (DocumentSnapshot snapshot in listOfSnapshots) {
        Map map = snapshot.data() as Map;
        String mail = map['email'];
        final smtpServer = gmail('helppaws24by7@gmail.com', 'tncucbjrxhuxwoll');
        final message = Message()
          ..from = const Address('helppaws24by7@gmail.com', 'Team SafeHer')
          ..recipients.add(mail)
          ..subject = 'Need Help'
          ..html =
              "<p>Someone near your locality needs your help</p><br><b><a href='https://maps.google.com/?q=$latitude,$longitude'>View Location on Google Maps</a></b><br><br>Any help from your side is highly appriciated <br>Regards<br>Team SafeHer";
        try {
          final sendReport = await send(message, smtpServer);
          debugPrint('Mail Sent :)');
        } catch (error) {
          print('Error sending email: $error');
        }
      }
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

  void _setupcam() async {
    await widget.controller.initialize();
  }

  @override
  void initState() {
    langLoad = false;
    super.initState();
    getLang();
  }

  @override
  Widget build(BuildContext context) {
    isRunning = ref.watch(ShieldStateProvider);
    return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 5),
        child: Localizations.override(
          context: context,
          child: InkWell(
            onTap: () async {
              ref.read(ShieldStateProvider.notifier).toogleshieldstate();
              //print(isRunning);

              await _getPermission();
              _setupSpeechRecognition();
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
                                  ? Text(
                                      AppLocalizations.of(context)!
                                          .shieldstatuson,
                                      style: const TextStyle(
                                          color: Colors.white, fontSize: 25),
                                    )
                                  : Text(
                                      AppLocalizations.of(context)!
                                          .shieldstatusoff,
                                      style: const TextStyle(
                                          color: Colors.white, fontSize: 25),
                                    ),
                              subtitle: isRunning
                                  ? Text(
                                      AppLocalizations.of(context)!
                                          .shieldsubtitleon,
                                      style: const TextStyle(
                                          color: Colors.white, fontSize: 15),
                                    )
                                  : Text(
                                      AppLocalizations.of(context)!
                                          .shieldsubtitleoff,
                                      style: const TextStyle(
                                          color: Colors.white, fontSize: 15),
                                    ),
                            ),
                            Visibility(
                              visible: isRunning,
                              child: Padding(
                                  padding: const EdgeInsets.all(18.0),
                                  child: Row(
                                    children: [
                                      const SpinKitDoubleBounce(
                                        color: Color.fromARGB(255, 5, 94, 45),
                                        size: 15,
                                      ),
                                      const SizedBox(width: 2),
                                      Text(
                                          AppLocalizations.of(context)!
                                              .currentlyrunning,
                                          style: const TextStyle(
                                              color: Color.fromARGB(
                                                  255, 5, 94, 45))),
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
        ));
  }

  fetchLocation() async {
    var userId = FirebaseAuth.instance.currentUser!.uid;
    var coll = await FirebaseFirestore.instance
        .collection('userdata')
        .doc(userId)
        .get();

    Map mp = coll.data() as Map;
    GeoPoint currGeo = mp['position']['geopoint'] as GeoPoint;
    userName = mp['firstName'];
    latitude = currGeo.latitude;
    longitude = currGeo.longitude;
  }

  void getLang() async {
    SharedPreferences sp = await SharedPreferences.getInstance();
    setState(() {
      if (sp.getString('lang') == 'hindi') {
        lang = "hindi";
        langLoad = false;
      } else {
        lang = "english";
        langLoad = false;
      }
    });
  }
}
