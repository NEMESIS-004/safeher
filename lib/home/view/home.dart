// ignore_for_file: use_build_context_synchronously, unused_field, prefer_final_fields, prefer_typing_uninitialized_variables, await_only_futures, unused_local_variable, avoid_print

import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:fluttercontactpicker/fluttercontactpicker.dart';
import 'package:geolocator/geolocator.dart';
import 'package:safeher3/home/view/controller/serviceActivator.dart';
import 'package:safeher3/home/view/widgets/globalAppBar.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:video_player/video_player.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});
  static const String routeName = "/homeScreen";
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
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
  EmailContact? _emailContact;
  TextEditingController editname = TextEditingController();
  TextEditingController editnumber = TextEditingController();
  TextEditingController editemail = TextEditingController();
  late SharedPreferences prefs;
  bool contactpckd = false;
  bool emailpckd = false;
  bool isloading = false;

  void camsetup() async {
    cameras = await availableCameras();
    _controller = CameraController(
      cameras[0],
      ResolutionPreset.medium,
    );
    await _controller.initialize();
    setState(() {
      val = 1;
    });
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

  editcontact(int id) async {
    String uid = id.toString();
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          scrollable: true,
          title: const Text("Contact"),
          content: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Form(
              child: Column(
                children: [
                  TextFormField(
                    controller: editname,
                    decoration: const InputDecoration(
                      labelText: "Name",
                      icon: Icon(Icons.account_box),
                    ),
                    // initialValue: name + uid,
                  ),
                  TextFormField(
                    keyboardType: TextInputType.phone,

                    controller: editnumber,
                    decoration: const InputDecoration(
                      labelText: "Number",
                      icon: Icon(Icons.numbers_outlined),
                    ),
                    // initialValue: number + id.toString(),
                  ),
                  TextFormField(
                    controller: editemail,
                    decoration: const InputDecoration(
                      labelText: "email",
                      icon: Icon(Icons.email),
                    ),
                    // initialValue: email + id.toString(),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            ElevatedButton(
              child: const Text("Done"),
              onPressed: () async {
                name = await editname.text;
                number = await editnumber.text;
                email = await editemail.text;

                assigndata(id);
                Navigator.pop(context);
              },
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
        number1 = number;
      });
      prefs.setString('name1', name1);
      prefs.setString('number1', number1);
      prefs.setString('email1', email1);
    }
    if (id == 2) {
      setState(() {
        name2 = name;
        email2 = email;
        number2 = number;
      });
      prefs.setString('name2', name2);
      prefs.setString('number2', number2);
      prefs.setString('email2', email2);
    }
    if (id == 3) {
      setState(() {
        name3 = name;
        email3 = email;
        number3 = number;
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

  @override
  void initState() {
    super.initState();
    camsetup();
    locsetup();
    getid();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: GlobalAppBar()
          .show("SafeHer", "Your Safety Our Priority", Icons.notifications),
      body: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        if (val == 1)
          ServiceActivator(
            cameras: cameras,
            controller: _controller,
            videoController: _videoController,
          ),
        if (val == 0)
          const Center(
            child: CircularProgressIndicator(
              color: Color.fromARGB(255, 207, 17, 80),
            ),
          ),
        const Padding(
          padding:
              EdgeInsets.only(left: 16.0, bottom: 10, top: 10, right: 16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Emergency Contacts",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              Text(
                "Add New",
                style: TextStyle(
                  color: Colors.pink,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              )
            ],
          ),
        ),
        Expanded(
            child: ListView(
          padding: const EdgeInsets.all(22.0),
          children: [
            if (name1 != "" && name1 != 'null') ...[
              Container(
                child: emergencyContactTile(name1, number1, email1, 1),
              ),
            ] else ...[
              MaterialButton(
                onPressed: () async {
                  await getcontact(1);
                  name1 = name;
                  number1 = number;
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
                child: emergencyContactTile(name2, number2, email2, 2),
              ),
            ] else ...[
              MaterialButton(
                onPressed: () async {
                  await getcontact(2);
                  name2 = name;
                  number2 = number;
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
                child: emergencyContactTile(name3, number3, email3, 3),
              ),
            ] else ...[
              MaterialButton(
                onPressed: () async {
                  await getcontact(3);
                  name3 = name;
                  number3 = number;
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
    );
  }

  Container emergencyContactTile(
      String name, String phone, String email, int id) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      height: 85,
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
              Column(
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
                      overflow: TextOverflow.ellipsis,
                      fontSize: 14,
                    ),
                  )
                ],
              ),
            ],
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
}
