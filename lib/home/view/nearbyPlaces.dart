// ignore_for_file: file_names, avoid_print

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:safeher3/home/view/data/nearbyPlacesData.dart';
import 'package:url_launcher/url_launcher.dart';

class NearbyPlaces extends StatefulWidget {
  const NearbyPlaces({super.key});

  @override
  State<NearbyPlaces> createState() => _NearbyPlacesState();
}

class _NearbyPlacesState extends State<NearbyPlaces> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
          body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: SingleChildScrollView(
          child: GridView.builder(
              itemCount: placeList.length,
              physics: const NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  childAspectRatio: 16 / 7,
                  crossAxisCount: 1,
                  mainAxisSpacing: 20),
              itemBuilder: (context, index) {
                return Container(
                  decoration: BoxDecoration(
                    image: DecorationImage(
                        image: AssetImage(placeList[index].back),
                        fit: BoxFit.fill),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Text(
                              placeList[index].name,
                              style: const TextStyle(
                                  color: Colors.black,
                                  fontSize: 20,
                                  fontWeight: FontWeight.w500),
                            ),
                            Text(
                              placeList[index].sub,
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w500),
                            ),
                            MaterialButton(
                              onPressed: () async {
                                try {
                                  await launchUrl(
                                      Uri.parse(placeList[index].api));
                                } catch (e) {
                                  print(e);
                                  Fluttertoast.showToast(
                                      msg: "Something went wrong!");
                                }
                              },
                              textColor: Colors.white,
                              elevation: 3,
                              height: 30,
                              minWidth: 70,
                              color: const Color.fromRGBO(133, 40, 63, 1),
                              child: const Text("View"),
                            )
                          ],
                        ),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Image.asset(
                              placeList[index].imageUrl,
                              height: 110,
                            )
                          ],
                        )
                      ],
                    ),
                  ),
                );
              }),
        ),
      )),
    );
  }
}
