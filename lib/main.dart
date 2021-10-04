import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:study_app/services/lambdaCaller.dart';

import 'models/authObject.dart';
import 'gridScreen.dart';
import 'models/gridItem.dart';
import 'nav-drawer.dart';
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
      title: 'Greek Flashcards',
      theme: ThemeData.light(),
      initialRoute: 'defaultpage',
      routes: <String, WidgetBuilder>{
        'defaultpage': (BuildContext context) => new DefaultPage()
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
  bool loaded = false;
  late LambdaCaller lambdaCaller;

  loadGridItems() async {
    var items = await lambdaCaller.getGridItemList("");
    print(items);
    setState(() {
      loaded = true;
      gridItems = items;
    });
  }

  @override
  Widget build(BuildContext context) {
    this.auth = Provider.of<AuthObject>(context);

    lambdaCaller = LambdaCaller(context);
    if(this.loaded == false){
      loadGridItems();
    }

    return new Scaffold(
        drawer: NavDrawer(),
        appBar: new AppBar(
            title: new Text("Greek Study Cards")
        ),
        body: GridLayout(this.gridItems),
      );
  }
}
