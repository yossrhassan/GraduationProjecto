// player_matching/data/models/match_model.dart

import 'package:graduation_project/features/player_matching/data/models/player_model.dart';

class MatchModel {
  final int id;
  final int creatorUserId;
  final int bookingId;
  final String sportName;
  final int teamSize;
  final String title;
  final String description;
  final int minSkillLevel;
  final int maxSkillLevel;
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
    required this.sportName,
    required this.teamSize,
    required this.title,
    required this.description,
    required this.minSkillLevel,
    required this.maxSkillLevel,
    required this.status,
    required this.createdAt,
    this.completedAt,
    this.players,
    required this.date,
    required this.startTime,
    required this.endTime,
  });

  factory MatchModel.fromJson(Map<String, dynamic> json) {
    // Parse players array
    List<PlayerModel> playersList = [];
    if (json['players'] is List) {
      playersList = (json['players'] as List)
          .map((player) => PlayerModel.fromJson(player))
          .toList();
    }

    // If players list is empty but we have a creator, add the creator as a player
    if (playersList.isEmpty && json['creatorUserId'] != null) {
      print(
          'Adding creator ${json['creatorUserId']} to players list for match ${json['id']}');
      playersList.add(PlayerModel(
        id: json['creatorUserId'],
        userId: json['creatorUserId'],
        userName: 'Creator',
        status: 'CheckedIn',
        team: 'A',
        invitedAt: DateTime.now(),
        responseAt: DateTime.now(),
        checkedInAt: DateTime.now(),
      ));
    }

    return MatchModel(
      id: json['id'],
      creatorUserId: json['creatorUserId'],
      bookingId: json['bookingId'],
      sportName: json['sportName'],
      teamSize: json['teamSize'],
      title: json['title'],
      description: json['description'],
      minSkillLevel: json['minSkillLevel'],
      maxSkillLevel: json['maxSkillLevel'],
      status: json['status'],
      createdAt: DateTime.parse(json['createdAt']),
      completedAt: json['completedAt'] != null
          ? DateTime.parse(json['completedAt'])
          : null,
      players: playersList,
      date: json['date']?.toString() ?? '',
      startTime: json['startTime']?.toString() ?? '',
      endTime: json['endTime']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'creatorUserId': creatorUserId,
      'bookingId': bookingId,
      'sportType': sportName,
      'teamSize': teamSize,
      'title': title,
      'description': description,
      'minSkillLevel': minSkillLevel,
      'maxSkillLevel': maxSkillLevel,
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
