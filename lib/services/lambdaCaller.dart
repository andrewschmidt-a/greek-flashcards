import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:http/http.dart';
import 'package:provider/provider.dart';
import 'package:study_app/authObject.dart';

import '../models/gridItem.dart';

class LambdaCaller {
  AuthObject auth = AuthObject.empty();
  LambdaCaller(BuildContext context){
    this.auth = Provider.of<AuthObject>(context);
  }

  Map<String, String> get headers{
    var headers = new Map<String, String>();
    if(this.auth.isAuthenticated){
      headers['Authorization'] =  'Bearer '+this.auth.token;
    }
    return headers;
  }

  Future<List<GridItem>> getGridItemList(String path) async {
    var headers = new Map<String, String>();
    if(this.auth.isAuthenticated){
      headers = {'Authorization': 'Bearer '+this.auth.token};
    }
    Response res = await get(
      "https://greek.nemcrunchers.dev/.netlify/functions/content",
      headers: headers,
    );
    
    if (res.statusCode == 200) {
      // If the server did return a 200 OK response,
      // then parse the JSON.
      List<dynamic> body = jsonDecode(res.body);
      return body.map((item) => GridItem.fromJson(item)).toList();
    } else {
      // If the server did not return a 200 OK response,
      // then throw an exception.
      throw Exception('Failed to load items');
    }
  }
}