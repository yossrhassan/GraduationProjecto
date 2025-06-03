// player_matching/data/models/match_model.dart

import 'package:graduation_project/features/player_matching/data/models/player_model.dart';

class MatchModel {
  final int id;
  final int creatorUserId;
  final int bookingId;
  final String sportType;
  final int teamSize;
  final String title;
  final String description;
  final int minSkillLevel;
  final int maxSkillLevel;
  final bool isPrivate;
  final String status;
  final DateTime createdAt;
  final DateTime? completedAt;
  final List<PlayerModel>? players;
  final String date;
  final String startTime;
  final String endTime;

  MatchModel({
    required this.id,
    required this.creatorUserId,
    required this.bookingId,
    required this.sportType,
    required this.teamSize,
    required this.title,
    required this.description,
    required this.minSkillLevel,
    required this.maxSkillLevel,
    required this.isPrivate,
    required this.status,
    required this.createdAt,
    this.completedAt,
    this.players,
    required this.date,
    required this.startTime,
    required this.endTime,
  });

  factory MatchModel.fromJson(Map<String, dynamic> json) {
    print('Parsing match JSON: $json');
    // Defensive: convert null to empty string using toString()
    final date = json['date']?.toString() ?? '';
    final startTime = json['startTime']?.toString() ?? '';
    final endTime = json['endTime']?.toString() ?? '';
    if (date == '') print('Warning: date is missing in match JSON!');
    if (startTime == '') print('Warning: startTime is missing in match JSON!');
    if (endTime == '') print('Warning: endTime is missing in match JSON!');
    return MatchModel(
      id: json['id'],
      creatorUserId: json['creatorUserId'],
      bookingId: json['bookingId'],
      sportType: json['sportType'],
      teamSize: json['teamSize'],
      title: json['title'],
      description: json['description'],
      minSkillLevel: json['minSkillLevel'],
      maxSkillLevel: json['maxSkillLevel'],
      isPrivate: json['isPrivate'],
      status: json['status'],
      createdAt: DateTime.parse(json['createdAt']),
      completedAt: json['completedAt'] != null
          ? DateTime.parse(json['completedAt'])
          : null,
      players: (json['players'] as List?)
              ?.map((player) => PlayerModel.fromJson(player))
              .toList() ??
          [],
      date: date,
      startTime: startTime,
      endTime: endTime,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'creatorUserId': creatorUserId,
      'bookingId': bookingId,
      'sportType': sportType,
      'teamSize': teamSize,
      'title': title,
      'description': description,
      'minSkillLevel': minSkillLevel,
      'maxSkillLevel': maxSkillLevel,
      'isPrivate': isPrivate,
      'status': status,
      'createdAt': createdAt.toIso8601String(),
      'completedAt': completedAt?.toIso8601String(),
      'players': players?.map((player) => player.toJson()).toList() ?? [],
      'date': date,
      'startTime': startTime,
      'endTime': endTime,
    };
  }
}
