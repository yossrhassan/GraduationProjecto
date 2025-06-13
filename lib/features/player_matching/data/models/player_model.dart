// player_matching/data/models/player_model.dart
class PlayerModel {
  final int id;
  final int userId;
  final String userName;
  final String status;
  final String team;
  final DateTime invitedAt;
  // final DateTime responseAt;
  // final DateTime checkedInAt;

  PlayerModel({
    required this.id,
    required this.userId,
    required this.userName,
    required this.status,
    required this.team,
    required this.invitedAt,
    // required this.responseAt,
    // required this.checkedInAt,
  });

  factory PlayerModel.fromJson(Map<String, dynamic> json) {
    return PlayerModel(
      id: json['id'] ?? 0,
      userId: json['userId'] ?? 0,
      userName: json['userName']?.toString() ?? 'Unknown Player',
      status: json['status']?.toString() ?? 'Unknown',
      team: json['team']?.toString() ?? 'A',
      invitedAt: json['invitedAt'] != null
          ? DateTime.parse(json['invitedAt'])
          : DateTime.now(),
      // responseAt: DateTime.parse(json['responseAt']),
      // checkedInAt: DateTime.parse(json['checkedInAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'userName': userName,
      'status': status,
      'team': team,
      'invitedAt': invitedAt.toIso8601String(),
      // 'responseAt': responseAt.toIso8601String(),
      // 'checkedInAt': checkedInAt.toIso8601String(),
    };
  }
}
