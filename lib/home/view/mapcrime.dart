// ignore_for_file: duplicate_import, unused_import, library_private_types_in_public_api, no_leading_underscores_for_local_identifiers, await_only_futures, unused_local_variable, avoid_print, prefer_const_constructors

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geoflutterfire2/geoflutterfire2.dart';
import 'package:geolocator/geolocator.dart';
import 'package:safeher3/home/view/controller/nearbyUsers.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:syncfusion_flutter_charts/sparkcharts.dart';

import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class ChartPage extends StatefulWidget {
  // ignore: prefer_const_constructors_in_immutables
  ChartPage({Key? key}) : super(key: key);

  @override
  ChartPageState createState() => ChartPageState();
}

class ChartPageState extends State<ChartPage> {
  List<_ChartData> data = [];
  late TooltipBehavior _tooltip;
  late Stream<List<DocumentSnapshot>> streamOfNearby;

  setData() async {
    final geo = GeoFlutterFire();

    var collectionReference =
        FirebaseFirestore.instance.collection('for_chart');
    final _userId = await FirebaseAuth.instance.currentUser!.uid;
    final _dbref = await FirebaseFirestore.instance.collection('userdata');
    final _gbref = await FirebaseFirestore.instance.collection('for_chart');
    DocumentSnapshot document = await _dbref.doc(_userId).get();
    final map = document.data() as Map;

    debugPrint(map.toString());
    GeoPoint geo1 = map["position"]["geopoint"] as GeoPoint;
    GeoFirePoint center =
        geo.point(latitude: geo1.latitude, longitude: geo1.longitude);

    double radius = 5;
    String field = 'position';

    streamOfNearby = await geo
        .collection(collectionRef: collectionReference)
        .within(center: center, radius: radius, field: field, strictMode: true);
    // NearbyUsers nbyu = streamOfNearby as NearbyUsers;
    // var _currententries = nbyu.get();
    print('po000000000000000000000000000000000');
    streamOfNearby.listen((listOfSnapshots) async {
      for (DocumentSnapshot snapshot in listOfSnapshots) {
        print("dvd[[[[[[[[[[[[[[[[[[[[[[[[[[[[[]]]]]]]]]]]]]]]]]]]]]]]]]]]]]");
        Map mapp = await snapshot.data() as Map;
        print(mapp);
        setState(() {
          data.add(_ChartData(
              mapp['locality'], double.parse(mapp['count'].toString())));
        });
      }
    });
  }

  @override
  void initState() {
    print('feeeeeeeeeffffffffffffff');
    setData();
    // data = [
    //   _ChartData('Karnataka', 12),
    //   _ChartData('Delhi', 15),
    //   _ChartData('Uttar Pradesh', 30),
    //   _ChartData('Assam', 13),
    //   _ChartData('Mumbai', 14)
    // ];
    setState(() {
      _tooltip = TooltipBehavior(enable: true);
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Syncfusion Flutter chart'),
        ),
        body: SfCartesianChart(
            primaryXAxis: CategoryAxis(),
            primaryYAxis: NumericAxis(minimum: 0, maximum: 40, interval: 10),
            tooltipBehavior: _tooltip,
            series: <ChartSeries<_ChartData, String>>[
              BarSeries<_ChartData, String>(
                  dataSource: data,
                  yValueMapper: (_ChartData data, _) => data.y,
                  xValueMapper: (_ChartData data, _) => data.x,
                  name: 'Crime Indicator',
                  color: Color.fromARGB(255, 228, 84, 84))
            ]));
  }
}

class _ChartData {
  _ChartData(this.x, this.y);

  final String x;
  final double y;
}
