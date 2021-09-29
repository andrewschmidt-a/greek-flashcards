import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:csv/csv.dart';
import 'package:flutter/services.dart' show rootBundle;
//import 'package:page_transition/page_transition.dart';

import 'question.dart';
import 'flashcard.dart';
import 'quiz_brain.dart';
import 'scorekeeper.dart';
//import 'Constants.dart';

QuizBrain quizBrain = QuizBrain();
ScoreKeeper scoreKeeper = ScoreKeeper();


void main() {
  runApp(StudyApp());
}

class StudyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
//    void choiceAction(String choice) {
//      if (choice == Constants.Import) {
//        print('Import');
//        loadAsset();
//        Navigator.push(
//          context,
//          PageTransition(
//            type: PageTransitionType.fade,
//            child: FlashScreen(),
//          ),
//        );
//      } else if (choice == Constants.Restart) {
//        {
//          Navigator.pushReplacement(
//            context,
//            PageRouteBuilder(
//              pageBuilder: (_, __, ___) => FlashCardPage(),
//              transitionDuration: Duration.zero,
//            ),
//          );
//        }
//      }
//    }

    return MaterialApp(
      title: 'Greek Flashcardss',
      theme: ThemeData.light(),
      initialRoute: 'defaultpage',
      routes: <String, WidgetBuilder>{
        'defaultpage': (BuildContext context) => new DefaultPage(),
        'flashscreen': (BuildContext context) => new FlashScreen()
      },

//          actions: <Widget>[
//            PopupMenuButton<String>(
//              onSelected: choiceAction,
//              itemBuilder: (BuildContext context) {
//                return Constants.choices.map((String choice) {
//                  return PopupMenuItem<String>(
//                    value: choice,
//                    child: Text(choice),
//                  );
//                }).toList();
//              },
//            )
//          ],
    );
  }
}

class FlashScreen extends StatefulWidget {
  @override
  _FlashScreenState createState() => _FlashScreenState();
}

class _FlashScreenState extends State<FlashScreen> {

  int questionNumber = quizBrain.getQuestionNumber();
  int totalQuestions = quizBrain.getQuestionBankLength();
  String questionText = quizBrain.getQuestionText();
  String questionAnswer = quizBrain.getQuestionAnswer();

  String progress() {
    String firstNo = questionNumber.toString();
    String breaker = ' / ';
    String secondNo = totalQuestions.toString();
    return "Completed: " + firstNo + breaker + secondNo;
  }

  @override
  Widget build(BuildContext context) {
    quizBrain.addListener(() {
      setState((){
        questionNumber = quizBrain.getQuestionNumber();
        totalQuestions = quizBrain.getQuestionBankLength();
        questionText = quizBrain.getQuestionText();
        questionAnswer = quizBrain.getQuestionAnswer();
      });
    });
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

class DefaultPage extends StatefulWidget {
  @override
  _DefaultPageState createState() => _DefaultPageState();
}

class _DefaultPageState extends State<DefaultPage> {
  bool loading = true;
  loadAsset() async {
    print('Loading');
    List<List<dynamic>> data = [];
    final String myData = await rootBundle.loadString("assets/sample_questions.csv");
    print('Converting');
    List<List<dynamic>> csvTable = CsvToListConverter().convert(myData);
    print('Starting');

    data = csvTable;
    List<Question> questionBank = [];
    for (var i = 0; i < data.length; i++) {
      print('Adding ' + data[i][0]);
      questionBank.add(Question(data[i][0], data[i][1]));
    }
    quizBrain.setQuestions(questionBank);
    print('Finished');
  }

  @override
  Widget build(BuildContext context) {
    var spacecrafts = ["James Web","Enterprise","Hubble","Kepler","Juno","Casini","Columbia","Challenger","Huygens","Galileo","Apollo","Spitzer","WMAP","Swift","Atlantis"];
    var myGridView = new GridView.builder(
      itemCount: spacecrafts.length,
      gridDelegate: new SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3),
      itemBuilder: (BuildContext context, int index) {
        return new GestureDetector(
          child: new Card(
            elevation: 5.0,
            child: new Container(
              alignment: Alignment.centerLeft,
              margin: new EdgeInsets.only(top: 10.0, bottom: 10.0,left: 10.0),
              child: new Text(spacecrafts[index]),
            ),
          ),
          onTap: () {
          },
        );
      },
    );

    return new Scaffold(
      appBar: new AppBar(
          title: new Text("Flutter GridView")
      ),
      body: myGridView,
    );
  }
}
