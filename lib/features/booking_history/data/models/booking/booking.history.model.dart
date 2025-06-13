import 'package:equatable/equatable.dart';

class BookingHistoryModel extends Equatable {
  final int? id;
  final int? userId;
  final String? userName;
  final int? courtId;
  final String? courtName;
  final String? facilityName;
  final String? city;
  final String? date;
  final String? startTime;
  final String? endTime;
  final String? status;
  final num? totalPrice;

  const BookingHistoryModel({
    this.id,
    this.userId,
    this.userName,
    this.courtId,
    this.courtName,
    this.facilityName,
    this.city,
    this.date,
    this.startTime,
    this.endTime,
    this.status,
    this.totalPrice,
  });

  factory BookingHistoryModel.fromJson(Map<String, dynamic> json) =>
      BookingHistoryModel(
        id: json['id'] as int?,
        userId: json['userId'] as int?,
        userName: json['userName'] as String?,
        courtId: json['courtId'] as int?,
        courtName: json['courtName'] as String?,
        facilityName: json['facilityName'] as String?,
        city: json['city'] as String?,
        date: json['date'] as String?,
        startTime: json['startTime'] as String?,
        endTime: json['endTime'] as String?,
        status: json['status'] as String?,
        totalPrice: json['totalPrice'] as num?,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'userId': userId,
        'userName': userName,
        'courtId': courtId,
        'courtName': courtName,
        'facilityName': facilityName,
        'city': city,
        'date': date,
        'startTime': startTime,
        'endTime': endTime,
        'status': status,
        'totalPrice': totalPrice,
      };

  @override
  List<Object?> get props {
    return [
      id,
      userId,
      userName,
      courtId,
      courtName,
      facilityName,
      city,
      date,
      startTime,
      endTime,
      status,
      totalPrice,
    ];
  }
}
