import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flip_card/flip_card.dart';
import 'package:provider/provider.dart';
import 'package:study_app/models/authObject.dart't.dart';
import 'package:study_app/flashcard.dart';
import 'package:study_app/services/lambdaCaller.dart';
import 'package:study_app/matchingGame.dart';

import 'package:study_app/teachingScreen.dart';import 'dart:math';
import 'models/gridItem.dart';


class GridScreen extends StatefulWidget {
  GridScreen(this.title, this.path);
  late String title;
  late String path;

  @override
  _GridScreenState createState() => _GridScreenState(this.title, this.path);
}

class _GridScreenState extends State<GridScreen> {

  _GridScreenState(this.title, this.path);

  late String title;
  late String path;
  AuthObject auth = AuthObject.empty();
  List<GridItem> gridItems = [];
  late LambdaCaller lambdaCaller;
  String error = "";
  bool loaded = false;

  loadGridItems() async {
    try{
      var items = await lambdaCaller.getGridItemList(this.path);
      setState(() {
        loaded = true;
        gridItems = items;
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
      return GridLayout(this.gridItems);
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

class GridLayout extends StatelessWidget {
  GridLayout(this.gridItems);

  List<GridItem> gridItems;

  List<Widget> renderGrid(List<GridItem> gridItems, BuildContext context){
    List<Widget> widgets = [];
    for(var i = 0; i < gridItems.length; i++){
        widgets.add(new GestureDetector(
          onTap: () {
            switch(gridItems[i].type){
              case "grid":{
                Navigator.push(context, MaterialPageRoute(builder: (context) => GridScreen(gridItems[i].title, gridItems[i].path)));
              }
              break;
              case "flashcards":{
                Navigator.push(context, MaterialPageRoute(builder: (context) => FlashScreen(gridItems[i].title, gridItems[i].path)));
              }
              break;
              case "markdown":{
                Navigator.push(context, MaterialPageRoute(builder: (context) => TeachingScreen(gridItems[i].title, gridItems[i].path)));
              }
              break;
              case "vocabMatch":{
                Navigator.push(context, MaterialPageRoute(builder: (context) => MatchingGame(gridItems[i].title, gridItems[i].path)));
              }
              break;
              default:{

              }
              break;
            }
            
          },
          child: new Container(
                padding: const EdgeInsets.all(8),
                child: Text(gridItems[i].title),
                color: Colors.primaries[i % Colors.primaries.length],
              )
        )
      );
    }
    return widgets;
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        return GridView.count(
          primary: false,
          padding: const EdgeInsets.all(20),
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
          crossAxisCount: (constraints.maxWidth ~/ 150).toInt(),
          children: renderGrid(gridItems, context),
        );
      }
    );
  }
}
