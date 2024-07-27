// To parse this JSON data, do
//
//     final verticalSlider = verticalSliderFromJson(jsonString);

import 'dart:convert';

SliderData sliderDataFromJson(String str) =>
    SliderData.fromJson(json.decode(str));

String sliderDataToJson(SliderData data) => json.encode(data.toJson());

class SliderData {
  int id;
  int questionId;
  int orderNumber;
  int tickNumber;
  int atValue;
  String tickContent;

  SliderData({
    required this.id,
    required this.questionId,
    required this.orderNumber,
    required this.tickNumber,
    required this.atValue,
    required this.tickContent,
  });

  factory SliderData.fromJson(Map<String, dynamic> json) => SliderData(
        id: json["id"],
        questionId: json["question_id"],
        orderNumber: json["order_number"],
        tickNumber: json["tick_number"],
        atValue: json["at_value"],
        tickContent: json["tick_content"],
      );

  Map<String, dynamic> toJson() => {
        "order_number": orderNumber,
        "tick_number": tickNumber,
        "at_value": atValue,
        "tick_content": tickContent,
      };
}
