import 'package:flutter/cupertino.dart';

import 'quiz_brain.dart';
import 'score.dart';

class ScoreKeeper extends ChangeNotifier {
  List<Score> scoreKeeper = [];

  void checkAnswer(int questionNumber, bool userPickedAnswer) {
    scoreKeeper.add(Score(questionNumber, userPickedAnswer));
    notifyListeners();
  }
}
