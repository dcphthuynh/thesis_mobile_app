// To parse this JSON data, do
//
//     final participant = participantFromJson(jsonString);

import 'dart:convert';

Participant participantFromJson(String str) =>
    Participant.fromJson(json.decode(str));

String participantToJson(Participant data) => json.encode(data.toJson());

class Participant {
  String userId;
  String experimentId;
  String startingTime;
  String endingTime;

  Participant({
    required this.userId,
    required this.experimentId,
    required this.startingTime,
    required this.endingTime,
  });

  factory Participant.fromJson(Map<String, dynamic> json) => Participant(
        userId: json["user_id"],
        experimentId: json["experiment_id"],
        startingTime: json["starting_time"],
        endingTime: json["ending_time"],
      );

  Map<String, dynamic> toJson() => {
        "user_id": userId,
        "experiment_id": experimentId,
        "starting_time": startingTime,
        "ending_time": endingTime,
      };
}
