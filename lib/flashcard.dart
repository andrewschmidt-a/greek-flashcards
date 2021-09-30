import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flip_card/flip_card.dart';
import 'quiz_brain.dart';
import 'scorekeeper.dart';


class FlashScreen extends StatefulWidget {
  FlashScreen(this.quizBrain, this.scoreKeeper);
  QuizBrain quizBrain;
  ScoreKeeper scoreKeeper;
  @override
  _FlashScreenState createState() => _FlashScreenState(quizBrain, scoreKeeper);
}

class _FlashScreenState extends State<FlashScreen> {
  _FlashScreenState(this.quizBrain, this.scoreKeeper);
  QuizBrain quizBrain;
  ScoreKeeper scoreKeeper;

  int questionNumber = 0;
  int totalQuestions = 0;
  String questionText = "";
  String questionAnswer = "";
  VoidCallback listener  = (){};

  String progress() {
    String firstNo = questionNumber.toString();
    String breaker = ' / ';
    String secondNo = totalQuestions.toString();
    return "Completed: " + firstNo + breaker + secondNo;
  }
  @override
  void dispose() {
    quizBrain.removeListener(listener);
    quizBrain.eraseQuestionBank();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    listener = () {
      setState((){
        questionNumber = quizBrain.getQuestionNumber();
        totalQuestions = quizBrain.getQuestionBankLength();
        questionText = quizBrain.getQuestionText();
        questionAnswer = quizBrain.getQuestionAnswer();
      });
    };
    quizBrain.addListener(listener);
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
            child: FlashCardPage(quizBrain, scoreKeeper),
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
                          scoreKeeper.checkAnswer(
                              quizBrain.getQuestionNumber(), false);
                              quizBrain.nextQuestion();
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
                          scoreKeeper.checkAnswer(
                              quizBrain.getQuestionNumber(), true);
                              quizBrain.nextQuestion();
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
  FlashCardPage(this.quizBrain, this.scoreKeeper);

  QuizBrain quizBrain;
  ScoreKeeper scoreKeeper;

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
                quizBrain.getQuestionText(),
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
                quizBrain.getQuestionAnswer(),
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

            this.scoreKeeper.checkAnswer(quizBrain.getQuestionNumber(), true);
            


          } else if (direction == DismissDirection.endToStart) {
            //Left Swipe
            this.scoreKeeper.checkAnswer(quizBrain.getQuestionNumber(), false);
          }
        },
      ),
    );
  }
}
