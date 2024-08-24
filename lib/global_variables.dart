import 'package:firebase_auth/firebase_auth.dart';
import 'package:wahid_uber_app/models/user.dart'
    as userModel; 
const String mapKey = "AIzaSyBbgLtZvsRAB5DcnPOoirbEi6n4hTsThZ4";
String uri = "http://192.168.90.217:3000";

User? currentUser;
userModel.User? userInfo;
UserCredential ?currentDriverUser; 
