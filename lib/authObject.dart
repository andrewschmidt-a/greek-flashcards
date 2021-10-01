import 'package:flutter/cupertino.dart';

class AuthObject with ChangeNotifier {
  bool   isAuthenticated = false;
  String picture = "";
  String name = "";
  String token = "";

  AuthObject.empty(){
  }
  AuthObject(String picture, String name, String token){
      this.isAuthenticated = true;
      this.picture = picture;
      this.name = name;
      this.token = token;
  }
  updateAuthObject(String picture, String name, String token){
      this.isAuthenticated = true;
      this.picture = picture;
      this.name = name;
      this.token = token;
  }
  clearAuthObject(){
    this.isAuthenticated = false;
    this.picture = "";
    this.name = "";
    this.token = "";
  }
}
