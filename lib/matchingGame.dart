import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flip_card/flip_card.dart';
import 'package:provider/provider.dart';
import 'package:study_app/models/authObject.dart';
import 'package:study_app/flashcard.dart';
import 'package:study_app/models/vocab.dart';
import 'package:study_app/services/lambdaCaller.dart';
import 'package:uuid/uuid.dart';
import 'dart:math';
import 'models/gridItem.dart';
class VocabMatchingCard {
  late String value; 
  late Uuid key;
  late Uuid id;
  late bool visible;

  VocabMatchingCard(value, key){
    this.value = value;
    this.key = key;
    this.visible = true;
    this.id = Uuid();
  }
}

class MatchingGame extends StatefulWidget {
  MatchingGame(this.title, this.path);
  late String title;
  late String path;

  @override
  _MatchingGameState createState() => _MatchingGameState(this.title, this.path);
}

class _MatchingGameState extends State<MatchingGame> {

  _MatchingGameState(this.title, this.path);

  late String title;
  late String path;
  AuthObject auth = AuthObject.empty();
  List<VocabMatchingCard> vocabList = [];
  late LambdaCaller lambdaCaller;
  String error = "";
  int selected = -1;
  bool loaded = false;

  loadGridItems() async {
    try{
      List<VocabMatchingCard> data = [];
      (await lambdaCaller.getFlashCardList(this.path)).forEach((el){
        Uuid uuid = Uuid();
        data.add(VocabMatchingCard(el.greek, uuid));
        data.add(VocabMatchingCard(el.english, uuid));
      });
      data.shuffle();

      setState(() {
        loaded = true;
        vocabList = data;
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
    List<Widget> renderGrid(List<VocabMatchingCard> vocabList, BuildContext context){
      List<Widget> widgets = [];

      for(var i = 0; i < vocabList.length; i++){
        widgets.add(new GestureDetector(
          onTap: () {
            if(selected == i){
              setState(() {
                selected = -1;
              });
            }else if(selected == -1){
              setState(() {
                selected = i;
              });
            }else{
              if(vocabList[selected].key == vocabList[i].key){
                vocabList[selected].visible = false;
                vocabList[i].visible = false;
              }
              setState(() {
                this.selected = -1;
                this.vocabList = vocabList;
              });
            }
          },
          child: Visibility(
            child: new Container(
                padding: const EdgeInsets.all(8),
                child: Text(vocabList[i].value),
                color: (this.selected == i)? Colors.yellow: Colors.teal
              ),
            visible: vocabList[i].visible
          )
        ));
      }
      return widgets;
    }

    renderBody(){
      if(this.error != ""){
        return Text(this.error);
      }
      return LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          return GridView.count(
            primary: false,
            padding: const EdgeInsets.all(20),
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            crossAxisCount: (constraints.maxWidth ~/ 100).toInt(),
            children: renderGrid(this.vocabList, context),
          );
        }
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
