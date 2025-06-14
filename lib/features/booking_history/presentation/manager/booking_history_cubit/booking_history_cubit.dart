// booking_history_cubit.dart
import 'package:bloc/bloc.dart';
import 'package:graduation_project/features/booking_history/data/models/booking/booking_history_model.dart';
import 'package:graduation_project/features/booking_history/data/repos/booking_history_repo.dart';

part 'booking_history_state.dart';

class BookingHistoryCubit extends Cubit<BookingHistoryState> {
  final BookingHistoryRepo bookinghistoryRepo;

  BookingHistoryCubit(this.bookinghistoryRepo) : super(BookingHistoryLoading());

  Future<void> loadBookings() async {
    if (isClosed) return;
    emit(BookingHistoryLoading());

    final result = await bookinghistoryRepo.getUserBookings();

    if (isClosed) return;
    result.fold(
      (failure) {
        if (!isClosed) emit(BookingHistoryError(failure.errMessage));
      },
      (bookings) {
        if (isClosed) return;
        final now = DateTime.now();
        final upcoming = bookings
            .where((b) =>
                DateTime.parse("${b.date}T${b.startTime}").isAfter(now) &&
                b.status?.toLowerCase() == 'pending')
            .toList();
        final past = bookings
            .where(
                (b) => DateTime.parse("${b.date}T${b.endTime}").isBefore(now))
            .toList();

        if (!isClosed) {
          emit(BookingHistoryLoaded(
              upcomingBookings: upcoming, pastBookings: past));
        }
      },
    );
  }

  Future<String> cancelBooking(int bookingId) async {
    final result = await bookinghistoryRepo.cancelBooking(bookingId);

    return result.fold(
      (failure) {
        throw failure.errMessage;
      },
      (message) {
        // Reload bookings after successful cancellation
        loadBookings();
        return message;
      },
    );
  }
}
