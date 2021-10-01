import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flip_card/flip_card.dart';
import 'package:provider/provider.dart';
import 'package:study_app/authObject.dart';
import 'package:study_app/flashcard.dart';
import 'package:study_app/services/lambdaCaller.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'dart:math';
import 'models/gridItem.dart';


class TeachingScreen extends StatefulWidget {
  TeachingScreen(this.title, this.path);
  late String title;
  late String path;

  @override
  _TeachingScreenState createState() => _TeachingScreenState(this.title, this.path);
}

class _TeachingScreenState extends State<TeachingScreen> {

  _TeachingScreenState(this.title, this.path);

  late String title;
  late String path;
  AuthObject auth = AuthObject.empty();
  String markdownData = "";
  late LambdaCaller lambdaCaller;
  String error = "";
  bool loaded = false;

  loadGridItems() async {
    try{
      var data = await lambdaCaller.getMarkdownData(this.path);
      setState(() {
        loaded = true;
        markdownData = data;
      });
    }catch(e){
      
      setState(() {
        loaded = true;
        error = "$e";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    this.auth = Provider.of<AuthObject>(context);

    lambdaCaller = LambdaCaller(context);
    if(this.loaded == false){
      loadGridItems();
    }

    renderBody(){
      if(this.error != ""){
        return Text(this.error);
      }
      return Markdown(
        data: this.markdownData,
      );
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black54,
        title: Text(title),
      ),
      body: renderBody()
    );
  }
}
