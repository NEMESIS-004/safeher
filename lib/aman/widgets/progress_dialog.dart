import 'package:flutter/material.dart';

class ProgressDialog extends StatelessWidget {
 String? message;
 ProgressDialog({Key? key, this.message}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.white,
      child: Container(
        margin: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(6),
        ),
        child: Row(
          children: [
            const SizedBox(width: 6,),

            const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.green),
            ),

            const SizedBox(width: 26,),

            Text(
              message!,
              style: const TextStyle(
                color: Colors.black,
                fontSize: 12,
              ),
            ),

          ],
        ),
      ),
    );
  }
}
