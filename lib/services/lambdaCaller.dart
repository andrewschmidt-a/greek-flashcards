import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:http/http.dart';
import 'package:provider/provider.dart';
import 'package:study_app/authObject.dart';
import 'package:study_app/models/vocab.dart';

import '../models/gridItem.dart';

class LambdaCaller {
  AuthObject auth = AuthObject.empty();
  LambdaCaller(BuildContext context){
    this.auth = Provider.of<AuthObject>(context);
  }

  Uri getUri(path, queryParams){
    return Uri.https("greek.nemcrunchers.dev", "/.netlify/functions/${path}", queryParams);
  }

  Map<String, String> get headers{
    var headers = new Map<String, String>();
    if(this.auth.isAuthenticated){
      headers['Authorization'] =  'Bearer '+this.auth.token;
    }
    return headers;
  }

  Future<List<dynamic>> getContentList(String path) async {

    Response res = await get(
      getUri("content", {'path': path}),
      headers: this.headers,
    );
    
    if (res.statusCode == 200) {
      // If the server did return a 200 OK response,
      // then parse the JSON.
      return jsonDecode(res.body);
    } else {
      // If the server did not return a 200 OK response,
      // then throw an exception.
      if(res.statusCode == 401 ){
        throw Exception('Oops looks like you don\'t have access. Please log in.');
      }
      throw Exception('Failed to load items');
    }
  }

  Future<List<GridItem>> getGridItemList(String path) async {
      return (await getContentList(path)).map((item) => GridItem.fromJson(item)).toList();
  }
  Future<List<Vocab>> getFlashCardList(String path) async {
      return (await getContentList(path)).map((item) => Vocab.fromJson(item)).toList();
  }
}