// To parse this JSON data, do
//
//     final answer = answerFromJson(jsonString);

import 'dart:convert';

Answer answerFromJson(String str) => Answer.fromJson(json.decode(str));

String answerToJson(Answer data) => json.encode(data.toJson());

class Answer {
  String experimentName;

  String questionAnswerType;
  String answer;
  int questionId;

  Answer(
      {required this.experimentName,
      required this.questionAnswerType,
      required this.answer,
      required this.questionId});

  factory Answer.fromJson(Map<String, dynamic> json) => Answer(
        experimentName: json["experiment_name"],
        questionAnswerType: json["question_answer_type"],
        answer: json["answer"],
        questionId: json["question_id"],
      );

  Map<String, dynamic> toJson() => {
        "experiment_name": experimentName,
        "question_answer_type": questionAnswerType,
        "answer": answer,
      };
}
