// To parse this JSON data, do
//
//     final result = resultFromJson(jsonString);

import 'dart:convert';

Result resultFromJson(String str) => Result.fromJson(json.decode(str));

String resultToJson(Result data) => json.encode(data.toJson());

class Result {
  int resultId;
  int experimentId;
  String answerType;
  String answerContent;
  String participantId;
  int questionId;
  int orderNumber;
  String questionTitle;
  String questionType;

  Result(
      {required this.resultId,
      required this.experimentId,
      required this.answerType,
      required this.answerContent,
      required this.participantId,
      required this.questionId,
      required this.orderNumber,
      required this.questionTitle,
      required this.questionType});

  factory Result.fromJson(Map<String, dynamic> json) => Result(
        resultId: json["result_id"],
        experimentId: json["experiment_id"],
        answerType: json["answer_type"],
        answerContent: json["answer_content"],
        participantId: json["participant_id"],
        questionId: json["id"],
        orderNumber: json["order_number"],
        questionTitle: json["title"],
        questionType: json["type"],
      );

  Map<String, dynamic> toJson() => {
        "result_id": resultId,
        "experiment_id": experimentId,
        "answer_type": answerType,
        "answer_content": answerContent,
        "participant_id": participantId,
        "id": questionId,
        "order_number": orderNumber,
        "title": questionTitle,
      };
}
