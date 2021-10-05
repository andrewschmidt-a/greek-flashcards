import 'package:flutter/material.dart';
import 'package:marquee/marquee.dart';
import 'package:study_app/services/lambdaCaller.dart';
import 'dart:async';

import 'models/vocab.dart';

class TypingGame extends StatefulWidget {
  TypingGame(this.title, this.path);
  late String title;
  late String path;
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return _TypingGameState(this.title, this.path);
  }
}
class TypingChar{
  late String character;
  late bool red;
  late bool finished;

  TypingChar(character){
    this.character = character;
    this.red = false;
    this.finished = false;
  }
}


class _TypingGameState extends State<TypingGame> {

  _TypingGameState(this.title, this.path);

  late String title;
  late String path;
  late List<Vocab> vocabList;
  late LambdaCaller lambdaCaller;
  bool loaded = false;
  get accuracy{
    return (((this.lorem.length-this.lorem.where((element) => element.red).length) / this.lorem.length * 10000).floor()/100).toString() + '%';
  }
  List<TypingChar> lorem = [];
  var shownWidget;
  String text = "";

  int step = 0;
  int lastTypeAt = new DateTime.now().millisecondsSinceEpoch;

  void updateLastTypeAt() {
    this.lastTypeAt = new DateTime.now().millisecondsSinceEpoch;
  }
  void onType(String value) {
    updateLastTypeAt();
    int indexFirst = this.lorem.indexWhere((element) => element.finished == false);
    setState(() {
      if(value.endsWith(lorem[indexFirst].character)) {
        this.lorem[indexFirst].finished=true;
        if( this.lorem.where((element) => element.finished == false).length == 0){
          this.step++;
        }
      } else {
        this.lorem[indexFirst].red=true;
      }
     });    
  }

  void resetGame() {
    setState(() {
      step = 0; 
    });
    
  }
  void onStartClick() {
    setState(() {
     updateLastTypeAt();
      step++;
    });
    var timer = Timer.periodic(new Duration(seconds: 1), (timer){
      int now = new DateTime.now().millisecondsSinceEpoch;

      setState(() {
        // Game Over
        if(step != 1){
          timer.cancel();
        }
      });
    });
  }
  loadVocab() async {
    List<Vocab> vocab = await lambdaCaller.getFlashCardList(path); 
    vocab.shuffle();
    setState(() {
      vocabList = vocab;
      loaded = true;
      this.vocabList.map((v) => v.greek).toList().forEach((element) {
        lorem.addAll(element.runes.map((rune) => TypingChar(new String.fromCharCode(rune))));
        lorem.add(TypingChar(" "));
      });
      lorem.removeLast();
    });
  }
  

  @override
  Widget build(BuildContext context) {
    lambdaCaller = LambdaCaller(context);
    if(this.loaded == false){
      loadVocab();
    }
    var txt = TextEditingController(text: text);

    if(step == 0)
      shownWidget = <Widget>[
        Text('Are you ready to type in greek??'), 
        Container(
          padding: const EdgeInsets.only(top: 10),
          child: RaisedButton(
            child: Text('Yes'),
            onPressed: onStartClick,
          ),
        ),
      ];
    else if (step == 1)
     shownWidget = <Widget>[
       Text('$accuracy $step'),
            Container(
              margin: EdgeInsets.only(left: 0),
              height: 72,
              child:  RichText(
                text: TextSpan(
                  style: TextStyle(fontSize: 48),
                  children: lorem.where((element) => !element.finished).map((t) => TextSpan(text: t.character, style: TextStyle(color: (t.red)?Colors.red:Colors.black))).toList(),
                ),
              ), 
          ),
          Padding(
            padding: const EdgeInsets.only(left:16, right: 16, top: 32),
            child: TextField(
              controller: txt,
              onChanged: onType,
              autofocus: true,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Type here',
              ),
            ),
          )
         ];
      else
        shownWidget = <Widget>[
          Text('Well done you got $accuracy correct.'), 
          RaisedButton(
            child: 
            Text('Restart'),
            onPressed: resetGame,
            )
        ];


    return Scaffold(
      appBar: AppBar(
        title: Center(child: Text(this.title)),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: shownWidget,
        ),
      ),
    );
  }

}