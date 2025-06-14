// player_matching/data/models/match_model.dart

import 'package:graduation_project/features/player_matching/data/models/player_model.dart';

class MatchModel {
  final int id;
  final int creatorUserId;
  final String? creatorUserName;
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
    this.creatorUserName,
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
    List<PlayerModel> playersList = [];
    if (json['players'] is List) {
      playersList = (json['players'] as List)
          .map((player) => PlayerModel.fromJson(player))
          .toList();
    }

    String creatorName = json['creatorUserName']?.toString() ?? '';

    if (creatorName.isEmpty &&
        json['players'] is List &&
        json['creatorUserId'] != null) {
      final playersList = json['players'] as List;
      for (final playerJson in playersList) {
        if (playerJson['userId'] == json['creatorUserId']) {
          creatorName = playerJson['userName']?.toString() ?? '';
          break;
        }
      }
    }

    if (creatorName.isEmpty) {
      creatorName = 'Creator';
    }

    if (playersList.isEmpty && json['creatorUserId'] != null) {
      playersList.add(PlayerModel(
        id: json['creatorUserId'],
        userId: json['creatorUserId'],
        userName: creatorName,
        status: 'CheckedIn',
        team: 'A',
        invitedAt: DateTime.now(),
      ));
    } else if (playersList.isNotEmpty && json['creatorUserId'] != null) {
      bool creatorExists =
          playersList.any((player) => player.userId == json['creatorUserId']);
      if (!creatorExists) {
        playersList.insert(
            0,
            PlayerModel(
              id: json['creatorUserId'],
              userId: json['creatorUserId'],
              userName: creatorName,
              status: 'CheckedIn',
              team: 'A',
              invitedAt: DateTime.now(),
            ));
      }
    }

    return MatchModel(
      id: json['id'] ?? 0,
      creatorUserId: json['creatorUserId'] ?? 0,
      creatorUserName: json['creatorUserName']?.toString(),
      bookingId: json['bookingId'] ?? 0,
      sportName: json['sportName']?.toString() ?? 'Unknown Sport',
      teamSize: json['teamSize'] ?? 1,
      title: json['title']?.toString() ?? 'Untitled Match',
      description: json['description']?.toString() ?? '',
      minSkillLevel: json['minSkillLevel'] ?? 1,
      maxSkillLevel: json['maxSkillLevel'] ?? 10,
      status: json['status']?.toString() ?? 'Unknown',
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
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
      'creatorUserName': creatorUserName,
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
