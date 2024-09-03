import 'package:wahid_uber_app/models/nearbydriver.dart';

class ManageDriverMethods {
  static List<NearByDriver> nearByDriverList = [];

  static void removeDriverFromList(String driverID) {
    int index =
        nearByDriverList.indexWhere((driver) => driver.uidDriver == driverID);

    if (index != -1) {
      nearByDriverList.removeAt(index);
    }
  }

  static void updateOnlineNearbyDriverLocation(
      NearByDriver nearBYdriverInfomation) {
    int index = nearByDriverList.indexWhere(
        (driver) => driver.uidDriver == nearBYdriverInfomation.uidDriver);

    // Ensure index is valid before accessing the list
    if (index != -1 && index < nearByDriverList.length) {
      nearByDriverList[index].latitude = nearBYdriverInfomation.latitude;
      nearByDriverList[index].longitude = nearBYdriverInfomation.longitude;
    } else {
      print('Driver with ID ${nearBYdriverInfomation.uidDriver} not found.');
    }
  }
}
