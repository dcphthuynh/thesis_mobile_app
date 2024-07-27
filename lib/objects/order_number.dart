// To parse this JSON data, do
//
//     final listOfOrderNumber = listOfOrderNumberFromJson(jsonString);

import 'dart:convert';

ListOfOrderNumber listOfOrderNumberFromJson(String str) =>
    ListOfOrderNumber.fromJson(json.decode(str));

String listOfOrderNumberToJson(ListOfOrderNumber data) =>
    json.encode(data.toJson());

class ListOfOrderNumber {
  int orderNumber;

  ListOfOrderNumber({required this.orderNumber});

  factory ListOfOrderNumber.fromJson(Map<String, dynamic> json) =>
      ListOfOrderNumber(orderNumber: json["order_number"]);

  Map<String, dynamic> toJson() => {
        "order_number": orderNumber,
      };
}
