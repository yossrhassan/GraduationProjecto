import 'package:equatable/equatable.dart';

class BookingModel extends Equatable {
  final int? courtId;
  final String? date;
  final String? startTime;
  final String? endTime;

  const BookingModel({this.courtId, this.date, this.startTime, this.endTime});

  factory BookingModel.fromJson(Map<String, dynamic> json) => BookingModel(
        courtId: json['courtId'] as int?,
        date: json['date'] as String?,
        startTime: json['startTime'] as String?,
        endTime: json['endTime'] as String?,
      );

  Map<String, dynamic> toJson() {
    // Convert startTime and endTime to time-only format (HH:mm:ss)
    String? formattedStartTime;
    String? formattedEndTime;
    if (startTime != null) {
      final startDateTime = DateTime.parse(startTime!);
      formattedStartTime =
          '${startDateTime.hour.toString().padLeft(2, '0')}:${startDateTime.minute.toString().padLeft(2, '0')}:${startDateTime.second.toString().padLeft(2, '0')}';
    }
    if (endTime != null) {
      final endDateTime = DateTime.parse(endTime!);
      formattedEndTime =
          '${endDateTime.hour.toString().padLeft(2, '0')}:${endDateTime.minute.toString().padLeft(2, '0')}:${endDateTime.second.toString().padLeft(2, '0')}';
    }

    return {
      'courtId': courtId,
      'date': date,
      'startTime': formattedStartTime,
      'endTime': formattedEndTime,
    };
  }

  @override
  List<Object?> get props => [courtId, date, startTime, endTime];
}