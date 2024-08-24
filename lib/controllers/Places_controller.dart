import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:wahid_uber_app/global_variables.dart';
import 'package:wahid_uber_app/models/address.dart';
import 'package:wahid_uber_app/models/direction.dart';
import 'package:wahid_uber_app/provider/app_data.dart';
import 'package:wahid_uber_app/services/manage_http_response.dart';

class PlacesController {
  static Future<String> findCordinateAddress(Position position, context) async {
    try {
      String placeAddress = "";
      String url =
          "https://maps.googleapis.com/maps/api/geocode/json?latlng=${position.latitude},${position.longitude}&key=$mapKey";

      final response = await ManageHttpResponse.getRequest(url);

      if (response != "Failed") {
        placeAddress = response['results'][0]['formatted_address'];
        Address address = Address(
            placeName: placeAddress,
            latitude: position.latitude,
            longitude: position.longitude,
            placeId: '',
            placeFormatedAddress: '');

        Provider.of<AppData>(context, listen: false)
            .updatePickUpAddress(address);
      }

      return placeAddress;
    } catch (e) {
      throw Exception("error address $e");
    }
  }

  static Future<Direction?> getDirectionDetails(
      LatLng startPosition, LatLng endPosition) async {
    // Construct the API URL
    String url =
        "https://maps.googleapis.com/maps/api/directions/json?origin=${startPosition.latitude},${startPosition.longitude}&destination=${endPosition.latitude},${endPosition.longitude}&mode=driving&key=$mapKey";

    // Make the HTTP request
    var response = await ManageHttpResponse.getRequest(url);

    // Debugging: Print the entire response
    print('API Response: $response');

    // Check if the request failed
    if (response == 'Failed') {
      print('API request failed.');
      return null;
    }

    // Check if 'routes' exists and is not empty
    if (response['routes'] == null || response['routes'].isEmpty) {
      print('No routes found in the response.');
      return null;
    }

    var route = response['routes'][0];

    // Check if 'legs' exists and is not empty
    if (route['legs'] == null || route['legs'].isEmpty) {
      print('No legs found in the route.');
      return null;
    }

    var leg = route['legs'][0];

    // Check if 'duration' and 'distance' exist
    if (leg['duration'] == null || leg['distance'] == null) {
      print('Duration or distance not found in the leg.');
      return null;
    }

    // Check if 'overview_polyline' exists
    if (route['overview_polyline'] == null) {
      print('Polyline data not found in the route.');
      return null;
    }

    // Create and populate the Direction object
    Direction direction = Direction();
    direction.durationText = leg['duration']['text'];
    direction.durationValue = leg['duration']['value'];
    direction.distanceText = leg['distance']['text'];
    direction.distanceValue = leg['distance']['value'];
    direction.encodedPoint = route["overview_polyline"]["points"];

    return direction;
  }

static int estimatedFares(Direction details) {
  int distanceKm = (details.distanceValue! / 1000).truncate();

  int fare;
  if (distanceKm >= 1 && distanceKm < 2) {
    fare = 5; // LYD
  } else if (distanceKm >= 2 && distanceKm < 10) {
    fare = 10; // LYD
  } else if (distanceKm >= 10 && distanceKm < 15) {
    fare = 20; // LYD
  } else if (distanceKm >= 15 && distanceKm < 20) {
    fare = 25; // LYD
  } else if (distanceKm >= 20 && distanceKm < 25) {
    fare = 30; // LYD
  } else if (distanceKm >= 25 && distanceKm < 30) {
    fare = 35; // LYD
  } else if (distanceKm >= 30 && distanceKm < 35) {
    fare = 40; // LYD
  } else if (distanceKm >= 35 && distanceKm < 40) {
    fare = 45; // LYD
  } else if (distanceKm >= 40 && distanceKm < 45) {
    fare = 50; // LYD
  } else if (distanceKm >= 45 && distanceKm < 55) {
    fare = 55; // LYD
  } else if (distanceKm >= 55 && distanceKm <= 60) {
    fare = 60; // LYD
  } else {
    fare = 0; // Default fare or handle other cases if needed
  }

  return fare;
}



}
