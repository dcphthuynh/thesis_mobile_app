// To parse this JSON data, do
//
//     final countOfResult = countOfResultFromJson(jsonString);

import 'dart:convert';

CountOfResult countOfResultFromJson(String str) =>
    CountOfResult.fromJson(json.decode(str));

String countOfResultToJson(CountOfResult data) => json.encode(data.toJson());

class CountOfResult {
  int count;
  String experimentName;

  CountOfResult({
    required this.count,
    required this.experimentName,
  });

  factory CountOfResult.fromJson(Map<String, dynamic> json) => CountOfResult(
        count: json["count"],
        experimentName: json["experiment_name"],
      );

  Map<String, dynamic> toJson() => {
        "count": count,
        "experiment_name": experimentName,
      };
}
