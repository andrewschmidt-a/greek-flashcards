import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:csv/csv.dart'; 
import 'package:provider/provider.dart';
import 'dart:convert';
import 'package:http/http.dart';
import 'package:flutter_appauth/flutter_appauth.dart';
import 'package:auth0_flutter_web/auth0_flutter_web.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:study_app/services/lambdaCaller.dart';
//import 'package:page_transition/page_transition.dart';

import 'authObject.dart';
import 'gridScreen.dart';
import 'models/gridItem.dart';
import 'question.dart';
import 'nav-drawer.dart';
import 'flashcard.dart';
import 'quiz_brain.dart';
import 'scorekeeper.dart';
//import 'Constants.dart';

/// -----------------------------------
///           Auth0 Variables
/// -----------------------------------


QuizBrain quizBrain = QuizBrain();
ScoreKeeper scoreKeeper = ScoreKeeper();

void main() async {
  
  runApp(
    ChangeNotifierProvider(
      create: (context) => AuthObject.empty(),
      child: StudyApp()
    )
  );
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
  
  AuthObject auth = AuthObject.empty();
  List<GridItem> gridItems = [];
  late LambdaCaller lambdaCaller;
  // loadAsset(filename) async {
  //   print('Loading');
  //   List<List<dynamic>> data = [];
  //   Response res = await get(
  //     "https://greek.nemcrunchers.dev/.netlify/functions/content",
  //     headers: {'Authorization': 'Bearer '+this.auth.token},
  //   );
  //   print('Converting');
  //   List<List<dynamic>> csvTable = jsonDecode(res.body)[filename];
  //   print('Starting');

  //   data = csvTable;
  //   List<Question> questionBank = [];
  //   for (var i = 0; i < data.length; i++) {
  //     print('Adding ' + data[i][0]);
  //     questionBank.add(Question(data[i][0], data[i][1]));
  //   }
  //   quizBrain.setQuestions(questionBank);
  //   print('Finished');
  // }

  loadGridItems() async {
    gridItems = await lambdaCaller.getGridItemList("");
  }

  @override
  Widget build(BuildContext context) {
    this.auth = Provider.of<AuthObject>(context);

    lambdaCaller = LambdaCaller(context);
    loadGridItems();

    return new Scaffold(
        drawer: NavDrawer(),
        appBar: new AppBar(
            title: new Text("Greek Study Cards")
        ),
        body: GridLayout(this.gridItems),
      );
  }
}
