import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:safeher3/aman/models/trips_history_model.dart';
// import 'package:user_ride/models/trips_history_model.dart';

class HistoryDesignUIWidget extends StatefulWidget {
  TripsHistoryModel? tripsHistoryModel;
  HistoryDesignUIWidget({super.key, this.tripsHistoryModel});

  @override
  State<HistoryDesignUIWidget> createState() => _HistoryDesignUIWidgetState();
}

class _HistoryDesignUIWidgetState extends State<HistoryDesignUIWidget> {

  String formatDateAndTime(String dateTimeFromDB){
    DateTime dateTime = DateTime.parse(dateTimeFromDB);

    String formattedDateTime = "${DateFormat.MMMd().format(dateTime)}, ${DateFormat.y().format(dateTime)} - ${DateFormat.jm().format(dateTime)}";
    return formattedDateTime;
  }

  @override
  Widget build(BuildContext context) {
    bool darkTheme = MediaQuery.of(context).platformBrightness == Brightness.dark;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(formatDateAndTime(widget.tripsHistoryModel!.time!),
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16
          ),
        ),

        const SizedBox(height: 10,),
        Container(
          decoration: BoxDecoration(
            color: darkTheme ? Colors.black : Colors.white,
            borderRadius: BorderRadius.circular(20)
          ),
          padding: const EdgeInsets.all(15),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.lightBlue,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(Icons.person, color: Colors.white,),
                      ),

                      const SizedBox(width: 15,),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.tripsHistoryModel!.driverName!,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold
                            ),
                          ),

                          const SizedBox(height: 8,),
                          const Row(
                            children: [
                              Icon(Icons.star, color: Colors.orange,),

                              SizedBox(width: 5,),
                              Text("4.5",
                                style: TextStyle(
                                  color: Colors.grey
                                ),
                              )
                            ],
                          )
                        ],
                      )
                    ],
                  ),

                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text("Final Cost",
                        style: TextStyle(
                            color: Colors.grey
                        ),
                      ),

                      const SizedBox(height: 8,),
                      Text(
                        widget.tripsHistoryModel!.fareAmount!,
                        style: const TextStyle(
                            fontWeight: FontWeight.bold
                        ),
                      )
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text("status",
                        style: TextStyle(
                            color: Colors.grey
                        ),
                      ),

                      const SizedBox(height: 8,),
                      Text(
                        widget.tripsHistoryModel!.status!,
                        style: const TextStyle(
                            fontWeight: FontWeight.bold
                        ),
                      )
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 10,),
              Divider(thickness: 3, color: Colors.grey[200],),

              const SizedBox(height: 10,),
              const Row(
                children: [
                  Text(
                    "TRIP",
                    style: TextStyle(
                      fontWeight: FontWeight.bold
                    ),
                  )
                ],
              ),

              const SizedBox(height: 10,),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(2),
                        decoration: BoxDecoration(
                          color: Colors.blue[600],
                          borderRadius: BorderRadius.circular(2)
                        ),
                        child: const Icon(Icons.star, color: Colors.white,),
                      ),
                      const SizedBox(width: 15,),
                      Text(
                        "${(widget.tripsHistoryModel!.originAddress!).substring(0, 15)}...",
                        style: const TextStyle(
                            fontWeight: FontWeight.bold,
                          fontSize: 18
                        ),
                      )
                    ],
                  ),

                  const SizedBox(height: 10,),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(2),
                        decoration: BoxDecoration(
                            color: Colors.black,
                            borderRadius: BorderRadius.circular(2)
                        ),
                        child: const Icon(Icons.star, color: Colors.white,),
                      ),
                      const SizedBox(width: 15,),
                      Text(
                        widget.tripsHistoryModel!.destinationAddress!,
                        style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18
                        ),
                      )
                    ],
                  ),
                ],
              )
            ],
          ),
        )
      ],
    );
  }
}
