import 'package:flutter/cupertino.dart';
import 'question.dart';

class QuizBrain extends ChangeNotifier {
  int _questionNumber = 0;
  List<Question> questionBank = [
    Question('Test', 'This is the sample back card')
  ];

  void eraseQuestionBank() {
    if (questionBank.length > 0) {
      questionBank.removeRange(0, questionBank.length);
      _questionNumber = 0;
      notifyListeners();
    }
  }

  void setQuestions(questions){
    eraseQuestionBank();
    questionBank = questions;
    notifyListeners();
  }

  void nextQuestion() {
    if (_questionNumber < questionBank.length - 1) {
      _questionNumber++;
      print(_questionNumber);
      notifyListeners();
    } else {}
  }

  List<Question> getQuizBank() {
    return questionBank;
  }

  int getQuestionNumber() {
    return _questionNumber;
  }

  int getQuestionBankLength() {
    return questionBank.length;
  }

  String getQuestionText() {
    return questionBank[_questionNumber].questionText;
  }

  String getQuestionAnswer() {
    return questionBank[_questionNumber].questionAnswer;
  }
}
