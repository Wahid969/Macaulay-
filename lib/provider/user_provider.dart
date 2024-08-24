import 'package:flutter/material.dart';
import 'package:wahid_uber_app/models/user.dart';

class UserProvider extends ChangeNotifier {
  User _user = User(
    id: '',
    fullName: '',
    email: '',
    password: '',
    phone: '',
  
    token: '',
  );

  User get user => _user;

  void setUser(String user) {
    _user = User.fromJson(user);
    notifyListeners();
  }

  void clearUser() {
    _user = User(
      id: '',
      fullName: '',
      email: '',
      password: '',
      phone: '',
    
      token: '',
    );
    notifyListeners();
  }
}