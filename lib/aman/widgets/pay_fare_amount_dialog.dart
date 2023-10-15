import 'dart:ffi';

import 'package:flutter/material.dart';
import 'package:safeher3/aman/splashScreen/splash_screen.dart';
// import 'package:user_ride/splashScreen/splash_screen.dart';

class PayFareAmountDialog extends StatefulWidget {
  double? fareAmount;
  PayFareAmountDialog({super.key, this.fareAmount});

  @override
  State<PayFareAmountDialog> createState() => _PayFareAmountDialogState();
}

class _PayFareAmountDialogState extends State<PayFareAmountDialog> {
  @override
  Widget build(BuildContext context) {
    bool darkTheme = MediaQuery.of(context).platformBrightness == Brightness.dark;
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      backgroundColor: Colors.transparent,
      child: Container(
        margin: const EdgeInsets.all(10),
        width: double.infinity,
        decoration: BoxDecoration(
          color: darkTheme ? Colors.black : Colors.blue,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 20,),
            Text(
              "Fare Amount".toUpperCase(),
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: darkTheme ? Colors.amber[400] : Colors.white,
                fontSize: 16
              ),
            ),

            const SizedBox(height: 20,),
            Divider(
              thickness: 2,
              color: darkTheme ? Colors.amber[400] : Colors.white,
            ),

            const SizedBox(height: 10,),
            Text(
              "₹ " + widget.fareAmount.toString(),
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.deepPurple,
                fontSize: 50
              )
            ),

            const SizedBox(height: 10,),
            Padding(
              padding: const EdgeInsets.all(10),
              child: Text(
                "This is the total trip fare amount. Please pay it to driver",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: darkTheme ? Colors.amber[400] : Colors.white,
                ),
              ),
            ),

            const SizedBox(height: 10,),
            Padding(
              padding: const EdgeInsets.all(20),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: darkTheme ? Colors.amber[400] : Colors.white,
                ),
                onPressed: (){
                  Future.delayed(const Duration(milliseconds: 10000),(){
                    Navigator.pop(context, "CashPaid");
                    Navigator.push(context, MaterialPageRoute(builder: (c) =>const SplashScreen()));

                  });
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Pay Cash",
                      style: TextStyle(
                        fontSize: 20,
                        color: darkTheme ? Colors.black : Colors.blue,
                        fontWeight: FontWeight.bold
                      ),
                    ),

                    Text(
                      "₹ " + widget.fareAmount.toString(),
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                        color: Colors.red,
                      ),
                    )
                  ],
                ),
              ),
            )

          ],
        ),
      ),
    );
  }
}
