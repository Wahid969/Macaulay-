import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_geofire/flutter_geofire.dart';
import '../models/nearbydriver.dart';

class GeofireProvider with ChangeNotifier {
  bool _isInitialized = false;
  bool get isInitialized => _isInitialized;

  StreamSubscription? _geoFireSubscription;
  final List<NearByDriver> _nearbyDriverList = [];
  List<NearByDriver> get nearbyDriverList => _nearbyDriverList;

  Future<void> startGeofireListener(double latitude, double longitude) async {
    if (_isInitialized) {
      // If already initialized, no need to reinitialize
      print('Geofire is already initialized');
      return;
    }

    try {
      await Geofire.initialize('driverAvailable');
      print('GeoFire initialized with collection: driverAvailable');

      _geoFireSubscription = Geofire.queryAtLocation(latitude, longitude, 20)
          ?.listen((map) {
        print('Listener triggered');
        if (map != null && map.isNotEmpty) {
          print('Received data: $map');
          var callBack = map['callBack'];
          switch (callBack) {
            case Geofire.onKeyEntered:
              print('Key entered');
              var nearbyDriver = NearByDriver()
                ..key = map['key']
                ..latitude = map['latitude']
                ..longitude = map['longitude'];
              _nearbyDriverList.add(nearbyDriver);
              notifyListeners();
              break;

            case Geofire.onKeyExited:
              print('Key exited');
              _nearbyDriverList.removeWhere((driver) => driver.key == map['key']);
              notifyListeners();
              break;

            case Geofire.onKeyMoved:
              print('Key moved');
              var updatedDriver = NearByDriver()
                ..key = map['key']
                ..latitude = map['latitude']
                ..longitude = map['longitude'];
              int index = _nearbyDriverList.indexWhere((driver) => driver.key == map['key']);
              if (index != -1) {
                _nearbyDriverList[index] = updatedDriver;
                notifyListeners();
              }
              break;

            case Geofire.onGeoQueryReady:
              print('Geo query ready');
              _isInitialized = true;
              notifyListeners();
              break;

            default:
              print('Unknown callback: $callBack');
              break;
          }
        } else {
          print('No data received or map is empty');
        }
      });
    } catch (e) {
      print('Error initializing Geofire: $e');
    }
  }

  @override
  void dispose() {
    _geoFireSubscription?.cancel();
    super.dispose();
  }
}
