// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:core';

import 'package:google_maps_flutter/google_maps_flutter.dart';

class TripDetails {
  String? destinationAdddress;
  String? pickupAddress;
  LatLng? pickup;
  LatLng? destination;
  String? rideID;
  String? paymentMethod;
  String? riderName;
  String? phone;
  TripDetails({
    this.destinationAdddress,
    this.pickupAddress,
    this.pickup,
    this.destination,
    this.rideID,
    this.paymentMethod,
    this.riderName,
    this.phone,
  });
}
