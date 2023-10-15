import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:safeher3/aman/Assistants/request_assistant.dart';
import 'package:safeher3/aman/global/map_key.dart';
import 'package:safeher3/aman/infoHandler/app_info.dart';
import 'package:safeher3/aman/models/directions.dart';
import 'package:safeher3/aman/models/predicted_places.dart';
import 'package:safeher3/aman/widgets/progress_dialog.dart';


import '../global/global.dart';

class PlacePredictionTileDesign extends StatefulWidget {
  final PredictedPlaces? predictedPlaces;

  const PlacePredictionTileDesign({super.key, this.predictedPlaces});

  @override
  State<PlacePredictionTileDesign> createState() => _PlacePredictionTileDesignState();
}

class _PlacePredictionTileDesignState extends State<PlacePredictionTileDesign> {

  getPlaceDirectionDetails(String? placeId, context) async{
    showDialog(context: context,
        builder: (BuildContext context) => ProgressDialog(message: "Setting up Drop-off. Please wait...",),
    );
    String placeDirectionDetailsUrl = "https://maps.googleapis.com/maps/api/place/details/json?place_id=$placeId&key=$mapKey";

    var responseApi = await RequestAssistant.recieveRequest(placeDirectionDetailsUrl);
    Navigator.pop(context);

    if(responseApi == "failedResponse"){
      return;
    }
    if(responseApi["status"] == "OK"){
      Directions directions = Directions();
      directions.locationName = responseApi["result"]["name"];
      directions.locationId = placeId;
      directions.locationLatitude = responseApi["result"]["geometry"]["location"]["lat"];
      directions.locationLongitude = responseApi["result"]["geometry"]["location"]["lng"];


      Provider.of<AppInfo>(context, listen: false).updateDropOffLocationAddress(directions);

      setState(() {
        userDropOffAddress = directions.locationName!;
      });
      Navigator.pop(context, "obtainedDropoff");
    }

  }

  @override
  Widget build(BuildContext context) {
    bool darkTheme = MediaQuery.of(context).platformBrightness == Brightness.dark;
    return ElevatedButton(
        onPressed: (){
          getPlaceDirectionDetails(widget.predictedPlaces!.place_id, context);
        },
        style: ElevatedButton.styleFrom(
          primary: darkTheme ? Colors.black : Colors.white,
        ),
        child: Padding(
          padding: EdgeInsets.all(8.0),
          child: Row(
            children: [
              Icon(
                Icons.add_location,
                color: darkTheme ? Colors.amber[400] : Colors.blue,
              ),

              SizedBox(width: 10,),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.predictedPlaces!.main_text!,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 16,
                        color: darkTheme ? Colors.amber[400] : Colors.blue,
                      ),
                    ),

                    Text(
                      widget.predictedPlaces!.secondary_text!,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 16,
                        color: darkTheme ? Colors.amber[400] : Colors.blue,
                      ),
                    ),

                  ],
                ),
              ),

            ],
          ),
        ),
    );
  }
}
