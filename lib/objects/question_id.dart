// To parse this JSON data, do
//
//     final listOfQuestionId = listOfQuestionIdFromJson(jsonString);

import 'dart:convert';

ListOfQuestionId listOfQuestionIdFromJson(String str) =>
    ListOfQuestionId.fromJson(json.decode(str));

String listOfQuestionIdToJson(ListOfQuestionId data) =>
    json.encode(data.toJson());

class ListOfQuestionId {
  int questionId;

  ListOfQuestionId({
    required this.questionId,
  });

  factory ListOfQuestionId.fromJson(Map<String, dynamic> json) =>
      ListOfQuestionId(
        questionId: json["id"],
      );

  Map<String, dynamic> toJson() => {
        "id": questionId,
      };
}
