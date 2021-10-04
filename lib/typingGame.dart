import 'package:flutter/material.dart';
import 'package:marquee/marquee.dart';
import 'dart:async';

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


class _TypingGameState extends State<TypingGame> {

  _TypingGameState(this.title, this.path);

  late String title;
  late String path;
  int typedCharLength = 0;
  String lorem = '                                  Lorem ipsum dolor sit amet, consectetur adipiscing elit. Etiam hendrerit ullamcorper pulvinar. Nullam dolor eros, ultrices sed sapien ac, vestibulum tristique neque. Quisque commodo sollicitudin arcu. Vestibulum tempor, tortor ut tempor facilisis, justo augue feugiat sapien, sit amet mattis magna magna ut dui. Aliquam eu felis id felis vehicula porttitor vitae at sem. Vivamus interdum neque nisi, sed placerat ex egestas vel. Curabitur aliquet tincidunt vehicula. Morbi interdum placerat tortor, sed ullamcorper quam varius in.'
    .toLowerCase()
    .replaceAll(',','')
    .replaceAll('.','');
    var shownWidget;

  int step = 0;
  int lastTypeAt = new DateTime.now().millisecondsSinceEpoch;

  void updateLastTypeAt() {
    this.lastTypeAt = new DateTime.now().millisecondsSinceEpoch;
  }
  void onType(String value) {
    updateLastTypeAt();
    String trimedValue = lorem.trimLeft();
    setState(() {
      if(trimedValue.indexOf(value) != 0) {
        step =2;
      } else {
        typedCharLength = value.length;
      }
     });    
  }

  void resetGame() {
    setState(() {
      typedCharLength = 0;
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
        if (step == 1 && now - lastTypeAt > 4000) {
          timer.cancel();
          step++;
        }
        if(step != 1){
          timer.cancel();
        }
      });
    });
  }
  

  @override
  Widget build(BuildContext context) {
    if(step == 0)
      shownWidget = <Widget>[
        Text('Oyuna hosgeldin, coronadan kaçmaya hazır mısın'), 
        Container(
          padding: const EdgeInsets.only(top: 10),
          child: RaisedButton(
            child: Text('Basla'),
            onPressed: onStartClick,
          ),
        ),
      ];
    else if (step == 1)
     shownWidget = <Widget>[
       Text('$typedCharLength'),
            Container(
              margin: EdgeInsets.only(left: 0),
              height: 40,
              child:  Marquee(
                text: lorem,
                style: TextStyle(fontSize: 24, letterSpacing: 2),
                scrollAxis: Axis.horizontal,
                crossAxisAlignment: CrossAxisAlignment.start,
                blankSpace: 20.0,
                velocity: 125,
                startPadding: 0,
                accelerationDuration: Duration(seconds: 20),
                accelerationCurve: Curves.ease,
                decelerationDuration: Duration(milliseconds: 500),
                decelerationCurve: Curves.easeOut,
              ), 
          ),
          Padding(
            padding: const EdgeInsets.only(left:16, right: 16, top: 32),
            child: TextField(
              onChanged: onType,
              autofocus: true,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Yaz Bakalım',
              ),
            ),
          )
         ];
      else
        shownWidget = <Widget>[
          Text('Coronadan kacamadım, skorun: $typedCharLength'), 
          RaisedButton(
            child: 
            Text('Yeniden dene!'),
            onPressed: resetGame,
            )
        ];


    return Scaffold(
      appBar: AppBar(
        title: Center(child: Text('Klavye Delikansı')),
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