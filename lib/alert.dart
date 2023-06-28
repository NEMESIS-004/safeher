// ignore_for_file: camel_case_types

import 'package:flutter/material.dart';

class alertpage extends StatefulWidget {
  const alertpage({super.key});

  @override
  State<alertpage> createState() => _alertpageState();
}

class _alertpageState extends State<alertpage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
          child: Center(
        child: MaterialButton(
          onPressed: () async {},
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
          color: Colors.amber,
          child: const SizedBox(
            child: Row(
              children: [
                Text("Send alert mail"),
              ],
            ),
          ),
        ),
      )),
    );
  }
}
