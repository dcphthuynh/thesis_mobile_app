// To parse this JSON data, do
//
//     final experiment = experimentFromJson(jsonString);

import 'dart:convert';

Experiment experimentFromJson(String str) =>
    Experiment.fromJson(json.decode(str));

String experimentToJson(Experiment data) => json.encode(data.toJson());

class Experiment {
  int experimentId;
  String experimentName;
  String experimenter;

  Experiment({
    required this.experimentId,
    required this.experimentName,
    required this.experimenter,
  });

  factory Experiment.fromJson(Map<String, dynamic> json) => Experiment(
        experimentId: json["experiment_id"],
        experimentName: json["experiment_name"],
        experimenter: json["experimenter"],
      );

  Map<String, dynamic> toJson() => {
        "experiment_id": experimentId,
        "experiment_name": experimentName,
        "experimenter": experimenter,
      };
}
