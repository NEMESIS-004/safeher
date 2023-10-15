// ignore_for_file: file_names, avoid_print, unused_local_variable

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:safeher3/home/view/data/nearbyPlacesData.dart';
import 'package:safeher3/home/view/widgets/globalAppBar.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class NearbyPlaces extends StatefulWidget {
  const NearbyPlaces({super.key});

  @override
  State<NearbyPlaces> createState() => _NearbyPlacesState();
}

class _NearbyPlacesState extends State<NearbyPlaces> {
  String lang = "";
  bool langLoad = false;
  @override
  void initState() {
    langLoad = true;
    super.initState();
    getLang();
  }

  @override
  Widget build(BuildContext context) {
    var height = MediaQuery.of(context).size.height;
    var width = MediaQuery.of(context).size.width;
    return Scaffold(
        appBar: GlobalAppBar()
            .show("Navigate", "Find Places Near You", Icons.notifications),
        body: (langLoad)
            ? const CircularProgressIndicator()
            : Localizations.override(
                context: context,
                locale: (lang == 'english') ? const Locale('en') : const Locale('hi'),
                child: Builder(builder: (context) {
                  return Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: SingleChildScrollView(
                      child: GridView.builder(
                          itemCount: placeList.length,
                          physics: const NeverScrollableScrollPhysics(),
                          shrinkWrap: true,
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
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
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Localizations.override(
                                      context: context,
                                      child: Localizations.override(
                                        context: context,
                                        locale: (lang == 'english')
                                            ? const Locale('en')
                                            : const Locale('hi'),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceEvenly,
                                          children: [
                                            Text(
                                              (index == 0)
                                                  ? (AppLocalizations.of(
                                                          context)!
                                                      .policestations)
                                                  : ((index == 1)
                                                      ? AppLocalizations.of(
                                                              context)!
                                                          .hospitals
                                                      : ((index == 2)
                                                          ? AppLocalizations.of(
                                                                  context)!
                                                              .pharmacies
                                                          : AppLocalizations.of(
                                                                  context)!
                                                              .busstop)),
                                              style: const TextStyle(
                                                  color: Colors.black,
                                                  fontSize: 20,
                                                  fontWeight: FontWeight.w500),
                                            ),
                                            Text(
                                              (index == 0)
                                                  ? (AppLocalizations.of(
                                                          context)!
                                                      .policestationsubtitle)
                                                  : ((index == 1)
                                                      ? AppLocalizations.of(
                                                              context)!
                                                          .hospitalsubtitle
                                                      : ((index == 2)
                                                          ? AppLocalizations.of(
                                                                  context)!
                                                              .pharmaciessubtitle
                                                          : AppLocalizations.of(
                                                                  context)!
                                                              .busstopsubstitle)),
                                              style: const TextStyle(
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.w500),
                                            ),
                                            MaterialButton(
                                              onPressed: () async {
                                                try {
                                                  await launchUrl(Uri.parse(
                                                      placeList[index].api));
                                                } catch (e) {
                                                  print(e);
                                                  Fluttertoast.showToast(
                                                      msg:
                                                          "Something went wrong!");
                                                }
                                              },
                                              textColor: Colors.white,
                                              elevation: 3,
                                              height: 30,
                                              minWidth: 70,
                                              color: const Color.fromRGBO(
                                                  133, 40, 63, 1),
                                              child: Text(
                                                  AppLocalizations.of(context)!
                                                      .viewbtn),
                                            )
                                          ],
                                        ),
                                      ),
                                    ),
                                    Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Image.asset(
                                          placeList[index].imageUrl,
                                          height: height * 0.1 + 5,
                                        )
                                      ],
                                    )
                                  ],
                                ),
                              ),
                            );
                          }),
                    ),
                  );
                }),
              ));
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
