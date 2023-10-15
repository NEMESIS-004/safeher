import 'package:flutter/material.dart';
import 'package:safeher3/aman/global/global.dart';
import 'package:safeher3/aman/screens/profile_screen.dart';
import 'package:safeher3/aman/screens/trips_history_screen.dart';
import 'package:safeher3/aman/splashScreen/splash_screen.dart';


class DrawerScreen extends StatelessWidget {
  const DrawerScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 220,
      child: Drawer(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(30, 50, 0, 20),
          child: Column(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.all(30),
                    decoration: const BoxDecoration(
                      color: Colors.lightBlue,
                      shape: BoxShape.circle
                    ),
                    child: const Icon(
                      Icons.person,
                      size: 40,
                      color: Colors.white,
                    ),
                  ),

                  const SizedBox(height: 20,),
                  Text(
                    userModelCurrentInfo!.name!, //null error check the vedio 8
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 20
                    ),
                  ),

                  const SizedBox(height: 10,),
                  GestureDetector(
                    onTap: (){
                      Navigator.push(context, MaterialPageRoute(builder: (c) => const ProfileScreen()));
                    },
                    child: const Text(
                      "Edit Profile",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                        color: Colors.blue,
                      ),
                    ),
                  ),

                  const SizedBox(height: 30,),
                  GestureDetector(
                    onTap: (){
                      Navigator.push(context, MaterialPageRoute(builder: (c)=> const TripsHistoryScreen()));
                    },
                      child: const Text("Your Trips", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),)
                  ),

                  const SizedBox(height: 15,),
                  const Text("Payements", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),),

                  const SizedBox(height: 15,),
                  const Text("Notification", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),),

                  const SizedBox(height: 15,),
                  const Text("Promos", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),),

                  const SizedBox(height: 15,),
                  const Text("Help", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),),

                  const SizedBox(height: 15,),
                  const Text("Free Trips", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),),
                ],
              ),

              const SizedBox(height: 30,),
              GestureDetector(
                onTap: (){
                  firebaseAuth.signOut();
                  Navigator.push(context, MaterialPageRoute(builder: (c) => const SplashScreen()));
                },
                child: const Text("Log Out",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.red
                  ),
                ),
              )

            ],
          ),
        ),
      ),
    );
  }
}
