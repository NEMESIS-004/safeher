import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:safeher3/aman/infoHandler/app_info.dart';
import 'package:safeher3/aman/widgets/history_design_ui.dart';
// import 'package:user_ride/infoHandler/app_info.dart';
// import 'package:user_ride/widgets/history_design_ui.dart';

class TripsHistoryScreen extends StatefulWidget {
  const TripsHistoryScreen({Key? key}) : super(key: key);

  @override
  State<TripsHistoryScreen> createState() => _TripsHistoryScreenState();
}

class _TripsHistoryScreenState extends State<TripsHistoryScreen> {
  @override
  Widget build(BuildContext context) {
    bool darkTheme = MediaQuery.of(context).platformBrightness == Brightness.dark;
    return Scaffold(
      backgroundColor: darkTheme ? Colors.black : Colors.grey[100],
      appBar: AppBar(
        backgroundColor: darkTheme ? Colors.black : Colors.white,
        title: Text(
          "Trips History",
          style: TextStyle(
            color: darkTheme ? Colors.amber.shade400 : Colors.black
          ),
        ),
        leading: IconButton(
          icon: Icon(Icons.close, color: darkTheme ? Colors.amber.shade400 : Colors.black,),
          onPressed: (){
            Navigator.pop(context);
          }
        ),
        centerTitle: true,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: ListView.separated(
            itemBuilder: (context, i){
              return Card(
                color: darkTheme ? Colors.black : Colors.grey[100],
                shadowColor: Colors.transparent,
                child: HistoryDesignUIWidget(
                  tripsHistoryModel: Provider.of<AppInfo>(context, listen: false).allTripsHistoryInformationList[i],
                ),
              );
            },
            separatorBuilder: (context, i) => const SizedBox(height: 30,),
            itemCount: Provider.of<AppInfo>(context, listen: false).allTripsHistoryInformationList.length,
            physics: const ClampingScrollPhysics(),
            shrinkWrap: true,
        ),
      ),
    );
  }
}
