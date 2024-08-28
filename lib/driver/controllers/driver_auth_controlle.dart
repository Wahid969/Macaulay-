import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:wahid_uber_app/driver/views/auth/vehicle_details_screen.dart';
import 'package:wahid_uber_app/driver/views/screens/driver_main_screen.dart';
import 'package:wahid_uber_app/global_variables.dart';

class DriverAuthController {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseDatabase _firebaseDatabase = FirebaseDatabase.instance;

  Future<void> signUpUsers({
    required BuildContext context,
    required String fullName,
    required String email,
    required String password,
  }) async {
    try {
      UserCredential credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      DatabaseReference userRef =
          _firebaseDatabase.ref().child('drivers/${credential.user!.uid}');

      Map<String, dynamic> userMap = {
        'fullName': fullName,
        'email': email,
        'password': password,
      };

      await userRef.set(userMap);

      currentDriverUser = credential;

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const VehicleDetailsScreen()),
        (route) => false,
      );
    } catch (e) {
      print("Sign-up error: $e");
    }
  }

  void updateProfile(
      {required String carColor,
      required String carModel,
      required String vehicleNumber,required BuildContext context}) async {
    String id = currentDriverUser!.user!.uid;

    DatabaseReference driverRef =
        FirebaseDatabase.instance.ref().child('drivers/$id/vehicle_info');

    Map map = {
      'carColor': carColor,
      'carModel': carModel,
      'vehicleNumber': vehicleNumber,
    };
    await driverRef.set(map);
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) =>  DriverMainScreen()),
        (route) => false,
      );
  }

  Future<void> signInUsers({
    required BuildContext context,
    required String email,
    required String password,
  }) async {
    try {
      await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Optionally, navigate to a different screen or update the UI
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) =>  DriverMainScreen()),
        (route) => false,
      );
    } catch (e) {
      print("Sign-in error: $e");
    }
  }
}
