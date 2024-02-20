// ignore_for_file: file_names, await_only_futures

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:safeher3/home/view/widgets/globalAppBar.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});
  static const String routeName = "/profileScreen";

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  bool isLoading = true;
  late Map map;
  String _userId = '';
  late CollectionReference _dbref;
  bool langLoad = false;
  String lang = "";
  getUserData() async {
    _userId = await FirebaseAuth.instance.currentUser!.uid;
    _dbref = FirebaseFirestore.instance.collection('userdata');
    DocumentSnapshot document = await _dbref.doc(_userId).get();
    map = document.data() as Map;
    debugPrint(map.toString());

    setState(() {
      isLoading = false;
    });
  }

  @override
  void initState() {
    langLoad = true;
    super.initState();
    getLang();
    getUserData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: GlobalAppBar().show("Profile", "", Icons.language_outlined),
      body: (langLoad)
          ? const CircularProgressIndicator()
          : Localizations.override(
              context: context,
              locale:
                  (lang == 'english') ? const Locale('en') : const Locale('hi'),
              child: Builder(builder: (context) {
                return SingleChildScrollView(
                  child: (isLoading)
                      ? Container(
                          alignment: Alignment.center,
                          child: const CircularProgressIndicator())
                      : Stack(
                          children: [
                            Container(
                              alignment: Alignment.center,
                              margin: const EdgeInsets.fromLTRB(25, 10, 25, 10),
                              padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
                              child: Column(
                                children: [
                                  Container(
                                      decoration: BoxDecoration(
                                        borderRadius:
                                            BorderRadius.circular(100),
                                        border: Border.all(
                                            width: 5, color: Colors.white),
                                        color: Colors.white,
                                        boxShadow: const [
                                          BoxShadow(
                                            color: Colors.black12,
                                            blurRadius: 20,
                                            offset: Offset(5, 5),
                                          ),
                                        ],
                                      ),
                                      child: CircleAvatar(
                                          radius: 44,
                                          backgroundImage:
                                              NetworkImage(map['profilepic']))),
                                  const SizedBox(
                                    height: 20,
                                  ),
                                  Text(
                                    '${map['firstName']} ${map['lastName']}',
                                    style: const TextStyle(
                                        fontSize: 22,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  const SizedBox(
                                    height: 20,
                                  ),
                                  Text(
                                    'ID: ${map['firstName']}123',
                                    style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  const SizedBox(
                                    height: 10,
                                  ),
                                  Container(
                                    padding: const EdgeInsets.all(10),
                                    child: Column(
                                      children: <Widget>[
                                        Container(
                                          padding: const EdgeInsets.only(
                                              left: 8.0, bottom: 4.0),
                                          alignment: Alignment.topLeft,
                                          child: Text(
                                            AppLocalizations.of(context)!
                                                .userinfo,
                                            style: const TextStyle(
                                              color: Colors.black87,
                                              fontWeight: FontWeight.w500,
                                              fontSize: 16,
                                            ),
                                            textAlign: TextAlign.left,
                                          ),
                                        ),
                                        Card(
                                          child: Container(
                                            alignment: Alignment.topLeft,
                                            padding: const EdgeInsets.all(15),
                                            child: Localizations.override(
                                              context: context,
                                              child: Column(
                                                children: <Widget>[
                                                  Column(
                                                    children: <Widget>[
                                                      ...ListTile.divideTiles(
                                                        color: Colors.grey,
                                                        tiles: [
                                                          ListTile(
                                                            contentPadding:
                                                                const EdgeInsets
                                                                    .symmetric(
                                                                    horizontal:
                                                                        12,
                                                                    vertical:
                                                                        4),
                                                            leading: const Icon(
                                                                Icons
                                                                    .my_location),
                                                            title: Text(
                                                                AppLocalizations.of(
                                                                        context)!
                                                                    .location),
                                                            subtitle:
                                                                const Text(
                                                                    "NIL"),
                                                          ),
                                                          ListTile(
                                                            leading: const Icon(
                                                                Icons.email),
                                                            title: Text(
                                                                AppLocalizations.of(
                                                                        context)!
                                                                    .email),
                                                            subtitle: Text(
                                                                "${map['email']}"),
                                                          ),
                                                          ListTile(
                                                            leading: const Icon(
                                                                Icons.phone),
                                                            title: Text(
                                                                AppLocalizations.of(
                                                                        context)!
                                                                    .phone),
                                                            subtitle: Text(
                                                                "${map['phone']}"),
                                                          ),
                                                        ],
                                                      ),
                                                    ],
                                                  )
                                                ],
                                              ),
                                            ),
                                          ),
                                        )
                                      ],
                                    ),
                                  )
                                ],
                              ),
                            )
                          ],
                        ),
                );
              }),
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
