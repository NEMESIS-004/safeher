// ignore_for_file: file_names

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:safeher3/home/view/settings.dart';

class GlobalAppBar extends StatelessWidget {
  const GlobalAppBar({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(
        "SafeHer",
        style: TextStyle(
            color: Colors.pink,
            fontSize: MediaQuery.of(context).size.width * 0.07,
            fontWeight: FontWeight.w800),
      ),
      subtitle: Text(
        "Your Safety, Our Priority",
        style: TextStyle(
            color: Colors.pinkAccent,
            fontWeight: FontWeight.w700,
            fontSize: MediaQuery.of(context).size.width * 0.03),
      ),
      trailing: Card(
        elevation: 4,
        shape: const CircleBorder(),
        child: InkWell(
          onTap: () {
            Navigator.pushNamed(context, SettingPage.routeName);
          },
          child: Padding(
            padding: const EdgeInsets.all(4.0),
            child: Icon(FontAwesomeIcons.person, color: Colors.pink[500], size: 20),
          ),
        ),
      ),
    );
  }
}
