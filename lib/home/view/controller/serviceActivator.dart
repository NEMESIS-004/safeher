// ignore_for_file: file_names, non_constant_identifier_names, avoid_print, use_build_context_synchronously, no_leading_underscores_for_local_identifiers, unused_field, unused_local_variable, unused_element, prefer_final_fields, prefer_typing_uninitialized_variables, must_be_immutable

import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'package:csv/csv.dart';
import 'package:flutter/services.dart';
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server/gmail.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:string_similarity/string_similarity.dart';

class ServiceActivator extends StatefulWidget {
  const ServiceActivator({
    super.key,
    required this.cameras,
    required this.controller,
    required this.videoController,
  });

  final cameras;
  final controller;
  final videoController;

  @override
  State<ServiceActivator> createState() => _ServiceActivatorState();
}

class _ServiceActivatorState extends State<ServiceActivator> {
  final stt.SpeechToText _speech = stt.SpeechToText();
  AudioPlayer audioPlayer = AudioPlayer();
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
    final csvString = await rootBundle.loadString('assets/dataset1.csv');
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
    audioPlayer.play(AssetSource('audio_file.wav'));
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
                      audioPlayer.stop();
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
      audioPlayer.stop();
      await widget.controller.initialize();
      _startRecording();
    } else {
      print("WRONG DETECTION FOR VOICE");
      threat = 0;
      canShowAppPrompt = true;
    }
  }

// Audio Player Function
  void playAudio() async {
    audioPlayer.play(AssetSource('audio_file.wav'));
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
          (result > 70 && _accelZ > 70 && _accelX > 70) ||
          (result > 70 && _accelX > 70 && _accelY > 70)) {
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

  // FAll Timer for fall detection
  void fallTimer() async {
    audioPlayer.play(AssetSource('audio_file.wav'));
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
                      audioPlayer.stop();
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
      audioPlayer.stop();
      await widget.controller.initialize();
      _startRecording();
    } else {
      print("WRONG DETECTION FOR FALL");
      isfallen = 0;
      canShowAppPrompt = true;
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
      cooldowntimer = Timer(const Duration(minutes: 1), () {
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
      widget.controller.dispose(); // Dispose the camera controller
    }
  }

  Future<void> _sendEmailWithVideo(String filePath) async {
    final smtpServer = gmail('aman18may18@gmail.com', 'yqrnhxcsctaxxshe');

    final message = Message()
      ..from = const Address('aman18may18@gmail.com', 'aman')
      ..recipients.add('priya.priyanka.ps.ps@gmail.com')
      ..subject = 'Video Email';
    final videoFile = File(filePath);
    if (videoFile.existsSync()) {
      message.attachments.add(FileAttachment(videoFile));
    } else {
      print('Video file does not exist: $filePath');
      return;
    }

    try {
      final sendReport = await send(message, smtpServer);
    } catch (error) {
      print('Error sending email: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 5),
      child: InkWell(
        onTap: () {
          setState(() {
            isRunning = !isRunning;
          });

          //print(isRunning);

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
                                  SizedBox(width: 15),
                                  Text("Currently Running...",
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
