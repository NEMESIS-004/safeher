// ignore_for_file: await_only_futures, prefer_const_constructors, sized_box_for_whitespace, curly_braces_in_flow_control_structures, unused_local_variable, avoid_print, unused_field, prefer_final_fields, use_build_context_synchronously, unused_import, implementation_imports, unused_element, no_leading_underscores_for_local_identifiers, non_constant_identifier_names

import 'dart:async';
import 'dart:io';
import 'package:audioplayers/audioplayers.dart';
import 'package:background_sms/background_sms.dart';
import 'package:camera/camera.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluttercontactpicker/fluttercontactpicker.dart';
import 'package:geoflutterfire2/geoflutterfire2.dart';
import 'package:geolocator/geolocator.dart';
import 'package:lottie/lottie.dart';
import 'package:mailer/mailer.dart';
import 'package:mailer/src/entities/address.dart' as mailers;
import 'package:mailer/smtp_server/gmail.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:noise_meter/noise_meter.dart';
import 'package:safeher3/home/view/controller/Offline_Alert.dart';
import 'package:safeher3/home/view/controller/serviceActivator.dart';
import 'package:safeher3/home/view/widgets/globalAppBar.dart';
import 'package:safeher3/riverpod.dart';
import 'package:vibration/vibration.dart';
import 'package:video_player/video_player.dart';

import 'controller/nearbyUsers.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});
  static const String routeName = "/homeScreen";
  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  List<CameraDescription> cameras = [];
  late CameraController _controller;
  late VideoPlayerController _videoController =
      VideoPlayerController.file(File(''));
  int val = 0;
  PhoneContact? _phoneContact;
  String number1 = "";
  String name1 = "";
  String email1 = "";
  String number2 = "";
  String name2 = "";
  String email2 = "";
  String number3 = "";
  String name3 = "";
  String email3 = "";
  String number = "";
  String name = "";
  String email = "";
  String lang = "";
  // bool _validate = false;
  final _formKey = GlobalKey<FormState>();
  EmailContact? _emailContact;
  TextEditingController editname = TextEditingController();
  TextEditingController editnumber = TextEditingController();
  TextEditingController editemail = TextEditingController();
  late SharedPreferences prefs;
  bool contactpckd = false;
  bool emailpckd = false;
  bool isloading = false;
  bool connectionstate = false;

  camsetup() async {
    cameras = await availableCameras();
    _controller = CameraController(
      cameras[0],
      ResolutionPreset.medium,
    );
    await _controller.initialize();
    setState(() {
      val = 1;
    });
    print("camera done");
  }

  locsetup() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      bool serviceRequested = await Geolocator.openLocationSettings();
      if (!serviceRequested) {
        return;
      }
    }
  }

  late double latitude;
  late double longitude;
  late String userName;

  Future<void> _sendEmailWithVideo(String filePath) async {
    print(
        "------------------------------------------------------------------------");
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
      ..from = const mailers.Address('helppaws24by7@gmail.com', 'Team SafeHer')
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
    } catch (error) {
      print('Error sending email: $error');
    }
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
          ..from =
              const mailers.Address('helppaws24by7@gmail.com', 'Team SafeHer')
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

  getcontact(int id) async {
    prefs = await SharedPreferences.getInstance();
    bool granted = await FlutterContactPicker.hasPermission();

    if (!granted) {
      granted = await FlutterContactPicker.requestPermission();
      // showDialog(
      //     context: context,
      //     builder: (context) => AlertDialog(
      //         title: const Text('Granted: '), content: Text('$granted')));
    }

    if (granted) {
      final PhoneContact contact =
          await FlutterContactPicker.pickPhoneContact();
      print(contact);
      setState(() {
        _phoneContact = contact;
        contactpckd = true;
        prefs.setBool('contactpckd', true);
        editname.text = _phoneContact!.fullName.toString();
        editnumber.text = _phoneContact!.phoneNumber!.number!.toString();
        editcontact(id);
        prefs.setBool('emailpckd', true);
      });
    }
  }

  String? validateName(String? value) {
    if (value!.isNotEmpty)
      return 'Name must be more than 2 charater';
    else
      return null;
  }

  String? validateMobile(String? value) {
    if (value!.length != 10)
      return 'Mobile Number must be of 10 digit';
    else
      return null;
  }

  String? validateEmail(String? value) {
    String pattern =
        r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';
    RegExp regex = RegExp(pattern);
    if (!regex.hasMatch(value!))
      return 'Enter Valid Email';
    else
      return null;
  }

  editcontact(int id) async {
    String uid = id.toString();
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          scrollable: true,
          title: Text(AppLocalizations.of(context)!.contact),
          content: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  TextFormField(
                    controller: editname,
                    validator: (name) {
                      if (name == null || name.isEmpty) {
                        return 'Please enter some text';
                      }
                      return null;
                    },
                    decoration: const InputDecoration(
                      labelText: "Name",
                      icon: Icon(Icons.account_box),
                    ),
                    // validator: validateName,
                    // initialValue: name + uid,
                  ),
                  TextFormField(
                    keyboardType: TextInputType.phone,
                    // validator: validateMobile,
                    controller: editnumber,

                    validator: (number) {
                      String num = number.toString().trim();
                      if (number!.length != 10)
                        return 'Mobile Number must be of 10 digit';
                      else
                        return null;
                    },
                    decoration: const InputDecoration(
                      labelText: "Number",
                      icon: Icon(Icons.numbers_outlined),
                    ),
                    // initialValue: number + id.toString(),
                  ),
                  TextFormField(
                    controller: editemail,
                    // validator: validateEmail,
                    validator: (email) {
                      String pattern =
                          r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';
                      RegExp regex = RegExp(pattern);
                      if (!regex.hasMatch(email!))
                        return 'Enter Valid Email';
                      else
                        return null;
                    },
                    decoration: const InputDecoration(
                      labelText: "email",
                      icon: Icon(Icons.email),
                      // errorText: _validate ? 'Value Cannot Be Empty' : null,
                    ),
                    // initialValue: email + id.toString(),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            Localizations.override(
              context: context,
              locale: (lang == 'english') ? Locale('en') : Locale('hi'),
              child: Builder(builder: (context) {
                return ElevatedButton(
                  child: Text(AppLocalizations.of(context)!.done),
                  onPressed: () async {
                    // name.text.isEmpty ? _validate = true : _validate = false;
                    if (_formKey.currentState!.validate()) {
                      name = await editname.text;
                      number = await editnumber.text.trim();
                      email = await editemail.text;

                      assigndata(id);
                      Navigator.pop(context);
                    }
                  },
                );
              }),
            ),
          ],
        );
      },
    );
  }

  assigndata(int id) {
    if (id == 1) {
      setState(() {
        name1 = name;
        email1 = email;
        number1 = number.trim();
      });
      prefs.setString('name1', name1);
      prefs.setString('number1', number1);
      prefs.setString('email1', email1);
    }
    if (id == 2) {
      setState(() {
        name2 = name;
        email2 = email;
        number2 = number.trim();
      });
      prefs.setString('name2', name2);
      prefs.setString('number2', number2);
      prefs.setString('email2', email2);
    }
    if (id == 3) {
      setState(() {
        name3 = name;
        email3 = email;
        number3 = number.trim();
      });
      prefs.setString('name3', name3);
      prefs.setString('number3', number3);
      prefs.setString('email3', email3);
    }
  }

  getid() async {
    prefs = await SharedPreferences.getInstance();
    contactpckd = await prefs.getBool('contactpckd') ?? false;
    emailpckd = await prefs.getBool('emailpckd') ?? false;

    if (emailpckd) {
      email1 = await prefs.getString('email1').toString();
      email2 = await prefs.getString('email2').toString();
      email3 = await prefs.getString('email3').toString();
    }

    if (contactpckd) {
      name1 = await prefs.getString('name1').toString();
      name2 = await prefs.getString('name2').toString();
      name3 = await prefs.getString('name3').toString();
      number1 = await prefs.getString('number1').toString();
      number2 = await prefs.getString('number2').toString();
      number3 = await prefs.getString('number3').toString();
    }
    isloading = true;
  }

  NoiseMeter? _noiseMeter;
  NoiseReading? _latestReading;
  StreamSubscription<NoiseReading>? _noiseSubscription;
  bool langLoad = false;
  @override
  void initState() {
    langLoad = true;
    super.initState();
    getLang();
    camsetup();
    locsetup();
    getid();
    _noiseMeter = NoiseMeter();
    ref.read(ConStateProvider.notifier).toogleconnectionstate();
  }

  // taptap functions
  Future<void> _stopRecording(String filePath) async {
    if (!_controller.value.isRecordingVideo) {
      print("-----------------------------------------------rbjenrf");
      return;
    }

    try {
      final newpath = await _controller.stopVideoRecording();
      await _sendEmailWithVideo(newpath.path);
    } catch (error) {
      print("e,e,fefefe");
    } finally {
      _startRecording(); // Dispose the camera controller
    }
  }

  late String filePath = "";
  late Timer cooldowntimer;

  Future<void> _startRecording() async {
    if (!_controller.value.isInitialized) {
      print("^^^^^^^^^^^^^^^^^^^^^^^^");
      return;
    }
    print("&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&");
    final Directory appDirectory = await getApplicationDocumentsDirectory();
    final String videoDirectory = '${appDirectory.path}/Videos';
    await Directory(videoDirectory).create(recursive: true);

    final String currentTime = DateTime.now().millisecondsSinceEpoch.toString();
    filePath = '$videoDirectory/$currentTime.mp4';

    try {
      await _controller.startVideoRecording();
      cooldowntimer = Timer(const Duration(seconds: 30), () {
        _stopRecording(filePath);
      });
    } catch (error) {
      print("^^^^^^^^^^^^^^^^^^^^^^^^^^^^6..");
    }
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

  void _showLottieDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          child: Container(
            width: 200,
            height: 200,
            padding: EdgeInsets.all(16.0),
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
    await Future.delayed(Duration(seconds: 2));
    Navigator.pop(context);
  }

  void _triggerVibration() async {
    final hasVibrator = await Vibration.hasVibrator();

    if (hasVibrator ?? false) {
      Vibration.vibrate(duration: 2000);
    }
  }

  AudioPlayer audioPlayer = AudioPlayer();
  void playAudio() async {
    audioPlayer.play(AssetSource('siren.mp3'));
  }

  // Adding_Data
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

  int lastTap = DateTime.now().millisecondsSinceEpoch;
  int consecutiveTaps = 0;
  @override
  Widget build(BuildContext context) {
    connectionstate = ref.watch(ConStateProvider);
    return Scaffold(
      appBar: GlobalAppBar()
          .show("SafeHer", "Your Safety Our Priority", Icons.language),
      body: SafeArea(
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () async {
            int now = DateTime.now().millisecondsSinceEpoch;
            if (now - lastTap < 1000) {
              consecutiveTaps++;
              if (consecutiveTaps == 2) {
                await camsetup();
                await fetchLocation();
                await _sendEmailToCommunity();
                if (await _isPermissionGranted() && connectionstate) {
                  _sendMessage(
                      "+918638332396",
                      """Need help My Location is https://www.google.com/maps/place/$latitude+$longitude""",
                      1);
                  add_threat_data();
                } else {
                  _sendMessage("+918638332396", """Need help""", 1);
                }
                await _startRecording();
                print('soscalled');
                _showLottieDialog(context);
                _triggerVibration();
              }
            } else {
              consecutiveTaps = 0;
            }
            lastTap = now;
          },
          child: (langLoad)
              ? CircularProgressIndicator()
              : Localizations.override(
                  context: context,
                  locale: (lang == 'english') ? Locale('en') : Locale('hi'),
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (val == 1 && connectionstate == true)
                          ServiceActivator(
                            cameras: cameras,
                            controller: _controller,
                            videoController: _videoController,
                            sms_sender: false,
                          ),
                        if (connectionstate == false)
                          OfflineActivator(
                            sms_sender: false,
                            noise_meter: _noiseMeter,
                          ),
                        if (val == 0)
                          const Center(
                            child: CircularProgressIndicator(
                              color: Color.fromARGB(255, 207, 17, 80),
                            ),
                          ),
                        Padding(
                          padding: EdgeInsets.only(
                              left: 16.0, bottom: 10, top: 10, right: 16.0),
                          child: Localizations.override(
                            context: context,
                            locale: (lang == 'english')
                                ? Locale('en')
                                : Locale('hi'),
                            child: Builder(builder: (context) {
                              return Padding(
                                padding: EdgeInsets.only(
                                    left: 16.0,
                                    bottom: 10,
                                    top: 10,
                                    right: 16.0),
                                child: Localizations.override(
                                  context: context,
                                  locale: (lang == 'english')
                                      ? Locale('en')
                                      : Locale('hi'),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        AppLocalizations.of(context)!
                                            .emergencycontacts,
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16),
                                      ),
                                      // Text(
                                      //   "Add New",
                                      //   style: TextStyle(
                                      //     color: Colors.pink,
                                      //     fontWeight: FontWeight.bold,
                                      //     fontSize: 16,
                                      //   ),
                                      // )
                                    ],
                                  ),
                                ),
                              );
                            }),
                          ),
                        ),
                        Expanded(
                            child: ListView(
                          padding: const EdgeInsets.all(22.0),
                          children: [
                            if (name1 != "" && name1 != 'null') ...[
                              Container(
                                child: emergencyContactTile(
                                    name1, number1, email1, 1),
                              ),
                            ] else ...[
                              MaterialButton(
                                onPressed: () async {
                                  await getcontact(1);
                                  name1 = name;
                                  number1 = number.trim();
                                  email1 = email;
                                  prefs.setString('name1', name1);
                                  prefs.setString('number1', number1);
                                  prefs.setString('email1', email1);
                                },
                                color: Colors.pinkAccent,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20)),
                                child: const Icon(
                                  Icons.add_circle_outline,
                                  color: Colors.white,
                                ),
                              )
                            ],
                            const SizedBox(
                              height: 10,
                            ),
                            if (name2 != "" && name2 != 'null') ...[
                              Container(
                                child: emergencyContactTile(
                                    name2, number2, email2, 2),
                              ),
                            ] else ...[
                              MaterialButton(
                                onPressed: () async {
                                  await getcontact(2);
                                  name2 = name;
                                  number2 = number.trim();
                                  email2 = email;
                                  prefs.setString('name2', name2);
                                  prefs.setString('number2', number2);
                                  prefs.setString('email2', email2);
                                },
                                color: Colors.pinkAccent,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20)),
                                child: const Icon(
                                  Icons.add_circle_outline,
                                  color: Colors.white,
                                ),
                              )
                            ],
                            const SizedBox(
                              height: 10,
                            ),
                            if (name3 != "" && name3 != 'null') ...[
                              Container(
                                child: emergencyContactTile(
                                    name3, number3, email3, 3),
                              ),
                            ] else ...[
                              MaterialButton(
                                onPressed: () async {
                                  await getcontact(3);
                                  name3 = name;
                                  number3 = number.trim();
                                  email3 = email;
                                  prefs.setString('name3', name3);
                                  prefs.setString('number3', number3);
                                  prefs.setString('email3', email3);
                                },
                                color: Colors.pinkAccent,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20)),
                                child: const Icon(
                                  Icons.add_circle_outline,
                                  color: Colors.white,
                                ),
                              )
                            ],
                            const SizedBox(
                              height: 10,
                            ),
                          ],
                        ))
                      ]),
                ),
        ),
      ),
    );
  }

  Container emergencyContactTile(
      String name, String phone, String email, int id) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: BoxDecoration(
          color: Colors.grey.shade200,
          borderRadius: BorderRadius.circular(15.0)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              const Icon(
                Icons.person,
                color: Color.fromARGB(255, 244, 39, 107),
              ),
              const SizedBox(
                width: 12,
              ),
              Container(
                width: 140,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: const TextStyle(
                        fontSize: 14,
                        overflow: TextOverflow.ellipsis,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(
                      height: 5,
                    ),
                    Text(
                      phone,
                      style: const TextStyle(
                        overflow: TextOverflow.ellipsis,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(
                      height: 5,
                    ),
                    Text(
                      email,
                      style: const TextStyle(
                        fontSize: 10,
                      ),
                    )
                  ],
                ),
              ),
            ],
          ),
          IconButton(
              onPressed: () async {
                debugPrint("Delete");
                setState(() {
                  if (id == 1) name1 = "";
                  if (id == 2) name2 = "";
                  if (id == 3) name3 = "";
                });
              },
              icon: const Icon(
                Icons.delete,
                color: Colors.grey,
                size: 20,
              )),
          VerticalDivider(
            color: Colors.grey,
            thickness: 1,
            width: 1,
            indent: 14,
            endIndent: 14,
          ),
          IconButton(
              // splashColor: Colors.green,
              // iconSize: 20,
              onPressed: () async {
                debugPrint("Edit");
                prefs = await SharedPreferences.getInstance();
                if (id == 1) {
                  editname.text = await prefs.getString('name1').toString();
                  editnumber.text = await prefs.getString('number1').toString();
                  editemail.text = await prefs.getString('email1').toString();
                }
                if (id == 2) {
                  editname.text = await prefs.getString('name2').toString();
                  editnumber.text = await prefs.getString('number2').toString();
                  editemail.text = await prefs.getString('email2').toString();
                }
                if (id == 3) {
                  editname.text = await prefs.getString('name3').toString();
                  editnumber.text = await prefs.getString('number3').toString();
                  editemail.text = await prefs.getString('email3').toString();
                }
                await editcontact(id);
              },
              icon: const Icon(
                Icons.edit,
                color: Colors.grey,
                size: 20,
              ))
        ],
      ),
    );
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
