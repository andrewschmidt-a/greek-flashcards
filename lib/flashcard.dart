import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flip_card/flip_card.dart';
import 'package:provider/provider.dart';
import 'package:study_app/authObject.dart';
import 'package:study_app/models/vocab.dart';
import 'package:study_app/services/lambdaCaller.dart';


class FlashScreen extends StatefulWidget {
  FlashScreen(this.title, this.path);
  String title; 
  String path; 
  @override
  _FlashScreenState createState() => _FlashScreenState(title, path);
}

class _FlashScreenState extends State<FlashScreen> {
  _FlashScreenState(this.title, this.path);
  List<Vocab> vocabList = [];
  late LambdaCaller lambdaCaller;
  bool loaded = false;
  String title;
  String path;

  int questionNumber = 0;

  markCorrect(){
    if(questionNumber < vocabList.length-1){
      setState(() {
        questionNumber = questionNumber +1;
      });
    }
  }
  markIncorrect(){
    this.vocabList.add(this.vocabList.removeAt(this.questionNumber)); // Add current card to end
    setState(() {
      vocabList = this.vocabList; // set state
    });
  }
  loadFlashCards() async {
    List<Vocab> vocab = await lambdaCaller.getFlashCardList(path); 
    setState(() {
      vocabList = vocab;
      loaded = true;
    });
  }
  String progress() {
    String firstNo = questionNumber.toString();
    String breaker = ' / ';
    String secondNo = this.vocabList.length.toString();
    return "Completed: " + firstNo + breaker + secondNo;
  }
  @override
  Widget build(BuildContext context) {
    lambdaCaller = LambdaCaller(context);
    if(this.loaded == false){
      loadFlashCards();
    }
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black54,
        title: Text(progress()),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Expanded(
            flex: 5,
            child: FlashCardPage(vocabList[questionNumber]),
          ),
          Expanded(
            flex: 1,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  Expanded(
                    child: Ink(
                      decoration: const ShapeDecoration(
                        color: Colors.red,
                        shape: CircleBorder(),
                      ),
                      child: IconButton(
                        icon: Icon(Icons.close),
                        color: Colors.white,
                        onPressed: () {
                              markIncorrect();
                        },
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 150.0,
                    width: 20.0,
                    child: VerticalDivider(color: Colors.teal.shade500),
                  ),
                  Expanded(
                    child: Ink(
                      decoration: const ShapeDecoration(
                        color: Colors.green,
                        shape: CircleBorder(),
                      ),
                      child: IconButton(
                        icon: Icon(Icons.check),
                        color: Colors.white,
                        onPressed: () {
                          markCorrect();
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class FlashCardPage extends StatelessWidget {
  FlashCardPage(this.vocabItem);

  Vocab vocabItem;

  _renderBg() {
    return Container(
      decoration: BoxDecoration(color: Colors.white38),
    );
  }

  _renderContent(context) {
    return Card(
      elevation: 0.0,
      margin: EdgeInsets.only(left: 32.0, right: 32.0, top: 20.0, bottom: 0.0),
      color: Color(0x00000000),
      child: FlipCard(
        direction: FlipDirection.HORIZONTAL,
        speed: 1000,
        onFlipDone: (status) {
          print(status);
        },
        front: Container(
          decoration: BoxDecoration(
            color: Color(0xFF006666),
            borderRadius: BorderRadius.all(Radius.circular(8.0)),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(
                vocabItem.greek,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 25.0,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
        back: Container(
          decoration: BoxDecoration(
            color: Color(0xFF006666),
            borderRadius: BorderRadius.all(Radius.circular(8.0)),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(
                vocabItem.english,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 25.0,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Dismissible(
        key: UniqueKey(),
        child: Stack(
          fit: StackFit.expand,
          children: <Widget>[
            _renderBg(),
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Expanded(
                  flex: 4,
                  child: _renderContent(context),
                ),
                Expanded(
                  flex: 1,
                  child: Container(),
                ),
              ],
            )
          ],
        ),
        onDismissed: (direction) {
          if (direction == DismissDirection.startToEnd) {
            // Right Swipe

            // this.scoreKeeper.checkAnswer(quizBrain.getQuestionNumber(), true);
            


          } else if (direction == DismissDirection.endToStart) {
            //Left Swipe
            // this.scoreKeeper.checkAnswer(quizBrain.getQuestionNumber(), false);
          }
        },
      ),
    );
  }
}
