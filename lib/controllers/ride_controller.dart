import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:wahid_uber_app/global_variables.dart';
import 'package:wahid_uber_app/models/ride.dart';
import 'package:wahid_uber_app/services/handle_http_response.dart';

class RideController {
  final String baseUrl = uri; // Replace with your API base URL

  // Function to create a ride
  Future<void> createRide({
    required BuildContext context,
    required String riderName,
    required String riderPhone,
    required String pickupAddress,
    required String destinationAddress,
    required double pickupLatitude,
    required double pickupLongitude,
    required double destinationLatitude,
    required double destinationLongitude,
    required String driverId,
  }) async {
    // Create an instance of the Ride model
    Ride ride = Ride(
      id: '', // Leave empty or generate a temporary ID, if necessary
      riderName: riderName,
      riderPhone: riderPhone,
      pickupAddress: pickupAddress,
      destinationAddress: destinationAddress,
      pickupLatitude: pickupLatitude,
      pickupLongitude: pickupLongitude,
      destinationLatitude: destinationLatitude,
      destinationLongitude: destinationLongitude,
      driverId: driverId,
      paymentMethod: 'card', // Default value
      createdAt: DateTime.now(), // Current date and time
    );

    // Convert the Ride object to JSON
    Map<String, dynamic> rideJson = ride.toJson();

    try {
      // Make the POST request to create the ride
      http.Response response = await http.post(
        Uri.parse('$baseUrl/rides'), // Update with the correct endpoint
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(rideJson),
      );

      // Handle the HTTP response
      handleHttoResponse(
        response: response,
        context: context,
        onSuccess: () {
          showSnackBar(context, "Ride created successfully!");
        },
      );
    } catch (e) {
      showSnackBar(context, "An error occurred: $e");
    }
  }
}
