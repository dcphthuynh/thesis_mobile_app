// To parse this JSON data, do
//
//     final experimentContent = experimentContentFromJson(jsonString);

import 'dart:convert';
import 'dart:typed_data';

ExperimentContent experimentContentFromJson(String str) =>
    ExperimentContent.fromJson(json.decode(str));

String experimentContentToJson(ExperimentContent data) =>
    json.encode(data.toJson());

class ExperimentContent {
  int id;
  int orderNumber;
  String title;
  String type;
  String? answerType;
  String? textButton;
  String? helpText;
  int? ratingId;
  int? timer;
  int alertSound;
  Uint8List? image;

  ExperimentContent(
      {required this.id,
      required this.orderNumber,
      required this.title,
      required this.type,
      this.answerType,
      this.textButton,
      this.helpText,
      this.ratingId,
      this.timer,
      required this.alertSound,
      this.image});

  factory ExperimentContent.fromJson(Map<String, dynamic> json) =>
      ExperimentContent(
          id: json["id"],
          orderNumber: json["order_number"],
          title: json["title"],
          type: json["type"],
          answerType: json["answer_type"],
          textButton: json["text_button"],
          helpText: json["help_text"],
          ratingId: json["rating_id"],
          timer: json["timer"],
          alertSound: json["alert_sound"],
          image: json["image"]);

  Map<String, dynamic> toJson() => {
        "id": id,
        "title": title,
        "type": type,
        "answer_type": answerType,
        "text_button": textButton,
        "help_text": helpText
      };
}
