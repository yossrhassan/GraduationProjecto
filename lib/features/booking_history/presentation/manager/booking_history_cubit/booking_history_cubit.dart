// booking_history_cubit.dart
import 'package:bloc/bloc.dart';
import 'package:graduation_project/features/booking_history/data/models/booking/booking_history_model.dart';
import 'package:graduation_project/features/booking_history/data/repos/booking_history_repo.dart';

part 'booking_history_state.dart';

class BookingHistoryCubit extends Cubit<BookingHistoryState> {
  final BookingHistoryRepo bookinghistoryRepo;

  BookingHistoryCubit(this.bookinghistoryRepo) : super(BookingHistoryLoading());

  Future<void> loadBookings() async {
    emit(BookingHistoryLoading());

    final result = await bookinghistoryRepo.getUserBookings();

    result.fold(
      (failure) => emit(BookingHistoryError(failure.errMessage)),
      (bookings) {
        final now = DateTime.now();
        final upcoming = bookings
            .where(
                (b) => DateTime.parse("${b.date}T${b.startTime}").isAfter(now))
            .toList();
        final past = bookings
            .where(
                (b) => DateTime.parse("${b.date}T${b.endTime}").isBefore(now))
            .toList();

        emit(BookingHistoryLoaded(
            upcomingBookings: upcoming, pastBookings: past));
      },
    );
  }
}