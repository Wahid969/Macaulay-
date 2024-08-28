import 'package:wahid_uber_app/models/nearbydriver.dart';

class Firehelpercontroller {
  static List<NearByDriver> nearbyDriverList = [];

  static void removeFromList(String key) {
  int index = nearbyDriverList.indexWhere((element) => element.key == key);
  if (index != -1) {
    nearbyDriverList.removeAt(index);
  }
}

 static void updateNearByLocation(NearByDriver driver) {
  int index = nearbyDriverList.indexWhere((element) => element.key == driver.key);
  if (index != -1) {
    nearbyDriverList[index].longitude = driver.longitude;
    nearbyDriverList[index].latitude = driver.latitude;
  }
}

}
