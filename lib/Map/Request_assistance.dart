import 'dart:convert';

import 'package:http/http.dart' as http;

class RequestAssistant {

  static Future<dynamic> recieveRequest(String url) async {
    http.Response httpResponse = await http.get(Uri.parse(url));

    try{
      if(httpResponse.statusCode == 200){ //successful
        String responseData  = httpResponse.body; //json
        var decodeResponseData = jsonDecode(responseData);

        return decodeResponseData;
      }
      else{
        return "failedResponse";
      }
    }catch(exp){
      return "failedResponse";
    }
  }
}

class PredictedPlaces {
  String? place_id;
  String? main_text;
  String? secondary_text;

  PredictedPlaces({this.place_id, this.main_text, this.secondary_text});

  PredictedPlaces.fromJson(Map<String, dynamic> jsonData) {
    place_id = jsonData["place_id"];
    main_text = jsonData["structured_formatting"]["main_text"];
    secondary_text = jsonData["structured_formatting"]["secondary_text"];
  }
}

getcoordinates(String s) async {
  const apiKey =
      "AIzaSyBBJfgRGrYJrkNAdcMEKmdJQNJXEV4_Vo4"; // Replace with your actual API key
  final query = Uri.encodeComponent(s);
  final url =
      'https://maps.googleapis.com/maps/api/geocode/json?address=$query&key=$apiKey';

  try {
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['status'] == 'OK' &&
          data['results'] != null &&
          data['results'].isNotEmpty) {
        final location = data['results'][0]['geometry']['location'];
        final double latitude = location['lat'];
        final double longitude = location['lng'];
        return {'latitude': latitude, 'longitude': longitude};
      }
    }
  } catch (e) {
    print('Error: $e');
  }
}
