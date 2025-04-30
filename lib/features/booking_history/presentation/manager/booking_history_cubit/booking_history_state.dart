// booking_history_state.dart (part of booking_history_cubit.dart)
part of 'booking_history_cubit.dart';

abstract class BookingHistoryState {}

class BookingHistoryLoading extends BookingHistoryState {}

class BookingHistoryLoaded extends BookingHistoryState {
  final List<BookingHistoryModel> upcomingBookings;
  final List<BookingHistoryModel> pastBookings;

  BookingHistoryLoaded(
      {required this.upcomingBookings, required this.pastBookings});
}

class BookingHistoryError extends BookingHistoryState {
  final String message;
  BookingHistoryError(this.message);
}