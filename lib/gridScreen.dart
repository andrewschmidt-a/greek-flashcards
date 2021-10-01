import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flip_card/flip_card.dart';
import 'dart:math';
import 'models/gridItem.dart';


class GridScreen extends StatefulWidget {
  GridScreen(this.title);
  late String title;

  @override
  _GridScreenState createState() => _GridScreenState(this.title);
}

class _GridScreenState extends State<GridScreen> {

  _GridScreenState(this.title);

  late String title;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black54,
        title: Text(title),
      ),
      body: GridLayout([])
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
          // When the child is tapped, show a snackbar.
          onTap: () {
            Navigator.push(context, MaterialPageRoute(builder: (context) => GridScreen(gridItems[i].title)));
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
          crossAxisCount: (constraints.maxWidth ~/ 250).toInt(),
          children: renderGrid(gridItems, context),
        );
      }
    );
  }
}
