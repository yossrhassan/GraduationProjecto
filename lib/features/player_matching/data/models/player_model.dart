class PlayerModel {
  final int id;
  final int userId;
  final String userName;
  final String status;
  final String team;
  final DateTime invitedAt;

  PlayerModel({
    required this.id,
    required this.userId,
    required this.userName,
    required this.status,
    required this.team,
    required this.invitedAt,
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
    };
  }
}
