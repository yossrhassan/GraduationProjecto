part of 'booking_cubit.dart';

@immutable
abstract class BookingState {}

class BookingInitial extends BookingState {}

class BookingSelection extends BookingState {
  final DateTime date;
  final int courtIndex;
  final List<int> selectedTimeIndices;
  final List<Map<String, String>> timeSlots;

  BookingSelection({
    required this.date,
    required this.courtIndex,
    required this.selectedTimeIndices,
    required this.timeSlots,
  });

  BookingSelection copyWith({
    DateTime? date,
    int? courtIndex,
    List<int>? selectedTimeIndices,
    List<Map<String, String>>? timeSlots,
  }) {
    return BookingSelection(
      date: date ?? this.date,
      courtIndex: courtIndex ?? this.courtIndex,
      selectedTimeIndices: selectedTimeIndices ?? this.selectedTimeIndices,
      timeSlots: timeSlots ?? this.timeSlots,
    );
  }
}

class BookingLoading extends BookingState {}

class BookingError extends BookingState {
  final String message;

  BookingError(this.message);
}

class BookingSuccess extends BookingState {}
