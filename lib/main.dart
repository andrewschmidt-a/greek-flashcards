import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:csv/csv.dart';
import 'dart:convert';
import 'package:http/http.dart';
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

    return MaterialApp(
      title: 'Greek Flashcardss',
      theme: ThemeData.light(),
      initialRoute: 'defaultpage',
      routes: <String, WidgetBuilder>{
        'defaultpage': (BuildContext context) => new DefaultPage(),
        'flashscreen': (BuildContext context) => new FlashScreen(quizBrain, scoreKeeper)
      },
    );
  }
}


class DefaultPage extends StatefulWidget {
  @override
  _DefaultPageState createState() => _DefaultPageState();
}

class _DefaultPageState extends State<DefaultPage> {
  bool loading = true;
  loadAsset(filename) async {
    print('Loading');
    List<List<dynamic>> data = [];
    Response res = await get("https://greek.nemcrunchers.dev/.netlify/functions/content");;
    print('Converting');
    List<List<dynamic>> csvTable = jsonDecode(res.body)[filename];
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
    var spacecrafts = ["Chapter 1", "Chapter 2"];
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
            loadAsset(spacecrafts[index].replaceAll(" ", ""));
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => FlashScreen(quizBrain, scoreKeeper)),
            );
          },
        );
      },
    );

    return new Scaffold(
      appBar: new AppBar(
          title: new Text("Greek Study Cards")
      ),
      body: myGridView,
    );
  }
}
