import 'dart:convert';

import 'package:http/http.dart' as http;

class DriverManageHttpResponse {
  static Future<dynamic> getRequest(String url) async {
    try {
      http.Response response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        String data = response.body;
        final decodeData = jsonDecode(data);
        return decodeData;
      } else {
        return "Failed";
      }
    } catch (e) {
      print("error occured $e");
    }
  }
}
