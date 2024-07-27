// To parse this JSON data, do
//
//     final editQuetstion = editQuetstionFromJson(jsonString);

import 'dart:convert';

EditQuetstion editQuetstionFromJson(String str) =>
    EditQuetstion.fromJson(json.decode(str));

String editQuetstionToJson(EditQuetstion data) => json.encode(data.toJson());

class EditQuetstion {
  String title;
  String type;
  String? answerType;

  EditQuetstion({
    required this.title,
    required this.type,
    this.answerType,
  });

  factory EditQuetstion.fromJson(Map<String, dynamic> json) => EditQuetstion(
        title: json["title"],
        type: json["type"],
        answerType: json["answer_type"],
      );

  Map<String, dynamic> toJson() => {
        "title": title,
        "type": type,
        "answer_type": answerType,
      };
}
