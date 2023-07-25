// ignore_for_file: file_names

import 'package:flutter/material.dart';

class GlobalAppBar {
  show(String title, String subTitle, IconData icon) {
    return AppBar(
      toolbarHeight: 95,
      backgroundColor: Colors.pink.shade600,
      title: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          Text(
            subTitle,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 17,
              fontWeight: FontWeight.w400,
            ),
          )
        ],
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.only(top: 20.0, bottom: 20.0, right: 18.0),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15.0),
              color: Colors.black.withOpacity(0.4),
            ),
            child: IconButton(
              icon: Icon(
                icon,
                size: 28,
                color: Colors.white,
              ),
              onPressed: () {},
            ),
          ),
        )
      ],
    );
  }
}
