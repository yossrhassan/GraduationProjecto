part of 'booking_history_cubit.dart';

abstract class BookingHistoryState {}

class BookingHistoryLoading extends BookingHistoryState {}

class BookingHistoryLoaded extends BookingHistoryState {
  final List<BookingModel> upcomingBookings;
  final List<BookingModel> pastBookings;

  BookingHistoryLoaded(
      {required this.upcomingBookings, required this.pastBookings});
}

class BookingHistoryError extends BookingHistoryState {
  final String message;
  BookingHistoryError(this.message);
}
