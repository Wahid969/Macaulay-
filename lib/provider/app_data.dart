import 'package:flutter/foundation.dart';
import 'package:wahid_uber_app/models/address.dart';

class AppData extends ChangeNotifier {
  Address? addressModel;

  Address? destinationAddress;

  void updatePickUpAddress(Address pickUpAddress) {
    addressModel = pickUpAddress;
    notifyListeners();
  }

  void updateDestinationAddress(Address destination) {
    destinationAddress = destination;
    notifyListeners();
  }
}
