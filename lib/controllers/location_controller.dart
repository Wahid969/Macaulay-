import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:wahid_uber_app/controllers/Places_controller.dart';

class LocationController {
  GoogleMapController? _googleMapController;
  Position? userCurrentPosition;

  // // Location accuracy
  // final LocationSettings locationSettings = const LocationSettings(
  //   accuracy: LocationAccuracy.bestForNavigation,
  //   distanceFilter: 100,
  // );

  // Method to set the GoogleMapController
  void setGoogleMapController(GoogleMapController controller) {
    _googleMapController = controller;
  }

  // Method to get user current location
  Future<void> getCurrentUserLocation(context ) async {
    if (_googleMapController == null) {
      throw Exception('GoogleMapController is not initialized.');
    }

    Position userPosition =
        await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.bestForNavigation);
    userCurrentPosition = userPosition;

    LatLng latLng =
        LatLng(userCurrentPosition!.latitude, userPosition.longitude);

    CameraPosition cameraPosition = CameraPosition(target: latLng, zoom: 15);

    _googleMapController!
        .animateCamera(CameraUpdate.newCameraPosition(cameraPosition));

    String address = await PlacesController.findCordinateAddress(userPosition, context);

    print('my address is $address');

    // print(cameraPosition.);
  }
}
