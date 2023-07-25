// ignore_for_file: file_names

import 'package:flutter/material.dart';

Widget customElevatedButton(
    {required bool isLoading,
    required Function onPressed,
    required String title}) {
  return Padding(
    padding: const EdgeInsets.all(8.0),
    child: SizedBox(
      width: double.infinity,
      height: 45,
      child: ElevatedButton(
          style:
              ButtonStyle(backgroundColor: MaterialStateProperty.all(Colors.pink)),
          onPressed: () {
            onPressed();
          },
          child: !isLoading
              ? Text(
                  title,
                )
              : const CircularProgressIndicator(color: Colors.white),
    ),
  ));
}
