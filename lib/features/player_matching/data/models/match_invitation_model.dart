class MatchInvitationModel {
  final int matchId;
  final String matchTitle;
  final int sportId;
  final String sportName;
  final int inviterId;
  final String inviterName;
  final String bookingStartTime;
  final String bookingEndTime;
  final String facilityName;
  final String city;

  MatchInvitationModel({
    required this.matchId,
    required this.matchTitle,
    required this.sportId,
    required this.sportName,
    required this.inviterId,
    required this.inviterName,
    required this.bookingStartTime,
    required this.bookingEndTime,
    required this.facilityName,
    required this.city,
  });

  factory MatchInvitationModel.fromJson(Map<String, dynamic> json) {
    return MatchInvitationModel(
      matchId: json['matchId'] ?? 0,
      matchTitle: json['matchTitle'] ?? '',
      sportId: json['sportId'] ?? 0,
      sportName: json['sportName'] ?? '',
      inviterId: json['inviterId'] ?? 0,
      inviterName: json['inviterName'] ?? '',
      bookingStartTime: json['bookingStartTime'] ?? '',
      bookingEndTime: json['bookingEndTime'] ?? '',
      facilityName: json['facilityName'] ?? '',
      city: json['city'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'matchId': matchId,
      'matchTitle': matchTitle,
      'sportId': sportId,
      'sportName': sportName,
      'inviterId': inviterId,
      'inviterName': inviterName,
      'bookingStartTime': bookingStartTime,
      'bookingEndTime': bookingEndTime,
      'facilityName': facilityName,
      'city': city,
    };
  }

  @override
  String toString() {
    return 'MatchInvitationModel(matchId: $matchId, matchTitle: $matchTitle, sportName: $sportName, inviterName: $inviterName, facilityName: $facilityName, startTime: $bookingStartTime, endTime: $bookingEndTime)';
  }
}
