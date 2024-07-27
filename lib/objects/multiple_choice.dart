import 'dart:convert';

MultipleChoice multipleChoiceFromJson(String str) =>
    MultipleChoice.fromJson(json.decode(str));

String multipleChoiceToJson(MultipleChoice data) => json.encode(data.toJson());

class MultipleChoice {
  int questionId;
  int orderNumber;
  String title;
  int choiceNumber;
  String choiceContent;

  MultipleChoice({
    required this.questionId,
    required this.orderNumber,
    required this.title,
    required this.choiceNumber,
    required this.choiceContent,
  });

  factory MultipleChoice.fromJson(Map<String, dynamic> json) => MultipleChoice(
        questionId: json["question_id"],
        orderNumber: json["order_number"],
        title: json["title"],
        choiceNumber: json["choice_number"],
        choiceContent: json["choice_content"],
      );

  Map<String, dynamic> toJson() => {
        "order_number": orderNumber,
        "title": title,
        "choice_number": choiceNumber,
        "choice_content": choiceContent,
      };
}
