import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:googleapis_auth/auth_io.dart' as auth;
import "package:googleapis/servicecontrol/v1.dart" as serviceControl;
import 'package:provider/provider.dart';
import 'package:wahid_uber_app/global_variables.dart';
import 'package:wahid_uber_app/provider/app_data.dart';

class PushNotificationController {
  static Future<String> getAccessToken() async {
    final serviceAccountJson = {
      "type": "service_account",
      "project_id": "uber-app-439a2",
      "private_key_id": "a5e351fa3a1467a269c636cca2073b021e0a176a",
      "private_key":
          "-----BEGIN PRIVATE KEY-----\nMIIEvgIBADANBgkqhkiG9w0BAQEFAASCBKgwggSkAgEAAoIBAQCh5qbH2/QEsCzc\nDyVIAbwxuxR0F5uAb48DEr109PTsqKRis5nTdVuDZwwWtykwgjaLrNVYUPk6jcTY\nt4EuRCkbG2R/cluX7VDZLZpj+ynFGj/lGpxGMsVtupIyVtvjKO9z3+vPnmMrqvJw\npYvEJCI6Y2Fwdan3+QmindjiisfBdZvd68h22RoWfS5XSPnELzXEMR6ogsqsvKLT\nPCu7UKTEZHRCH8Uu0lOOHVPp9plh1G2q2fFMXXQObTFBbuYE4HVAUsKoE69ri1S3\nZOeqPEGy5tx5wv/Z32DNFzazvx8nxuK5U0BxbEpdRrTB1TDPW4jvDUVIqVkOIZEN\ntZrn86VrAgMBAAECggEAAiWRzpKfELTZU22r++FyAmLNqaBqgnB4P/0un+9jlAPE\ncj6ZapFizkI+icqR9D+1w3JePdaNB3a7xnfgcaGbve1GDt6QUlpmOQr+whahfiiT\n8lDBA7lGnubba2l1bvSrAClW8iDShdC1eELpsIceIRISR7B3uX8G3q4jIxXeAjWs\nncOvCsIebpm1t42fq19+VTp1Pe8qHX+aDW0SAWAiJ3CBSWLyR8lbDL/lpLjyyByP\n888YgQqMeuvoE7r05Jns+ES6D3OvxoNcd2jKBrM7nv4DeOSqWjZUOhh7LKSjI94x\nohnGKSksvjKt7jb24L+f3YVOLyCEPjL21vIsrI2zuQKBgQDRLn+FAYWlWmmgujXG\n3c8ZI5e5nxlnl5eGgHqhk3r6grbgptUHN098T2/+Pzlh/w57ixwGwyGpFhjaJy5l\nGbnOFvSpyHM9FpB3Ya4m4WIIYsToVDYTdM2knbJ0Jy/N0aJ1N9WF0v1XcXgCCLvn\nj8VvYbttEOpx36Pl9PW8XndP1QKBgQDGIxvlpeLdsSJ73E/Rr4iOt1gmwy3db/Zn\nJCyk1QN3H5sZFqg5xiB+1hzeeDCMNeTb65XCbmkBoCH3LDZNyjXNsiW7uuCZv5Tx\nI9pFNOQlNufIR666pRboixj4bDXTZahB0ctskkGcM5A09rMJHK0xE5pmrDKRigw9\nPZG6+LsAPwKBgDZwg396Be4iuZq624QF9f/042fLoDD1otm+Viv21eqcWjvdL1PR\ncT5I7jyc97IpTvuYGJMp9Xir54ve5pQpPdIE52fIYzViyfZH1asIvRqxmc1dHTWz\nEFHnOKpCCI7oH/+hqFBLuOMpBLKC02RQZnG2XbDk1h8MtPsD5XBApYyBAoGBAKOf\nkMUoJd6gDnMs7/mgtOvuuuxf2Ht6n4hzli6U/qScRDAGxuvXEzTLStHpfWX8h7+Z\noHYNScge3o3JRBsfdykkCgcq/5nYXX559iGa2SFmYyjBEalu9ikZ3YghjJ3D4Jxi\nTVSev3HoHxmt9RH8TYYuwx4w7B3GW+8i7jrydzNvAoGBAMgve6N+eZG//zcoDEmB\nm0+ONPXQh1VeqPRWEkGe8Jd/Hxra7JEJV2XrZGK8IDP8JUWmMX6xmizKZSwlfRrQ\nRIvCFUK4tznd6UE54fHC69Pq5gFb8hCmp1XD9QU9WSQH1CyhZI13Vn1LztdKMHw/\ntPjptIXO7+J0oP4WtFweVW5A\n-----END PRIVATE KEY-----\n",
      "client_email":
          "uber-app-macaulay-famous@uber-app-439a2.iam.gserviceaccount.com",
      "client_id": "102805160284729372824",
      "auth_uri": "https://accounts.google.com/o/oauth2/auth",
      "token_uri": "https://oauth2.googleapis.com/token",
      "auth_provider_x509_cert_url":
          "https://www.googleapis.com/oauth2/v1/certs",
      "client_x509_cert_url":
          "https://www.googleapis.com/robot/v1/metadata/x509/uber-app-macaulay-famous%40uber-app-439a2.iam.gserviceaccount.com",
      "universe_domain": "googleapis.com"
    };

    List<String> scopes = [
      "https://www.googleapis.com/auth/userinfo.email",
      "https://www.googleapis.com/auth/firebase.database",
      "https://www.googleapis.com/auth/firebase.messaging",
    ];

    http.Client client = await auth.clientViaServiceAccount(
      auth.ServiceAccountCredentials.fromJson(serviceAccountJson),
      scopes,
    );

    ///get the access token
    auth.AccessCredentials credentials =
        await auth.obtainAccessCredentialsViaServiceAccount(
      auth.ServiceAccountCredentials.fromJson(serviceAccountJson),
      scopes,
      client,
    );

    client.close();

    return credentials.accessToken.data;
  }

  static sendNotificationToSelectedDriver(
      String token, BuildContext context, String tripID) async {
    final String pickupLocation = Provider.of<AppData>(context, listen: false)
        .addressModel!
        .placeName
        .toString();
    final String destinationLocation =
        Provider.of<AppData>(context, listen: false)
            .destinationAddress!
            .placeName
            .toString();
    final String serverKey = await getAccessToken();
    String fcmApiEndPoint =
        "https://fcm.googleapis.com/v1/projects/uber-app-439a2/messages:send";

    final Map<String, dynamic> message = {
      'message': {
        'token': token,
        'notification': {
          'title': 'New Trip Request From ${userInfo!.fullName}',
          'body':
              'Pickup Location: $pickupLocation \nDestination Location $destinationLocation',
        },
        'data': {
          "tripID": tripID,
        }
      }
    };
    final http.Response response = await http.post(
      Uri.parse(
        fcmApiEndPoint,
      ),
      headers: <String, String>{
        'Content-Type': 'application/json',
        'Authorization': "Bearer $serverKey",
      },
      body: jsonEncode(message),
    );

    if (response.statusCode == 200) {
      print('Notification sent successfully');
    } else {
      print('failed to send notification${response.statusCode}');
    }
  }
}
