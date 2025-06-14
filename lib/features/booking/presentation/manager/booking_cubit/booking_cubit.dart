import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:graduation_project/features/booking/data/models/booking.model.dart';
import 'package:graduation_project/features/booking/data/repos/booking_repo.dart';
import 'package:get_it/get_it.dart';

part 'booking_state.dart';

class BookingCubit extends Cubit<BookingState> {
  Map<String, Set<int>> bookedSlots = {};
  final BookingRepo bookingRepo;
  int? courtId;

  BookingCubit(this.bookingRepo) : super(BookingInitial()) {
    fetchExistingBookings();
  }

  DateTime? _lastSelectedDate;
  int? _lastCourtIndex;

  void setCourtId(int id) {
    courtId = id;
    fetchExistingBookings();
  }

  Future<void> fetchExistingBookings() async {
    print('Fetching existing bookings for facility ID: $courtId');

    if (courtId == null) {
      print('No facility ID set, skipping booking fetch');
      return;
    }

    final result = await bookingRepo.getBookings(courtId: courtId);

    result.fold((failure) {
      print(' Failed to load bookings: ${failure.errMessage}');
    }, (response) {
      print(' Bookings response: $response');

      if (response is Map<String, dynamic>) {
        bookedSlots.clear();

        final dynamic rawBookingSlots = response['bookingSlots'];
        final dynamic rawCourtId = response['courtId'];

        if (rawBookingSlots is Map<String, dynamic> && rawCourtId is int) {
          int? currentCourtIndex;
          if (state is BookingSelection) {
            currentCourtIndex = (state as BookingSelection).courtIndex;
          }

          print(
              'Processing bookings for court ID: $rawCourtId (UI index: $currentCourtIndex)');

          rawBookingSlots.forEach((dateString, slotsList) {
            final date = DateTime.parse(dateString);

            if (slotsList is List) {
              for (var slot in slotsList) {
                if (slot is Map<String, dynamic>) {
                  final startTimeString = slot['startTime'] as String;
                  final endTimeString = slot['endTime'] as String;

                  final startTime =
                      DateTime.parse("${dateString}T$startTimeString");
                  final endTime =
                      DateTime.parse("${dateString}T$endTimeString");

                  final slotIndices =
                      _getSlotIndicesForTimeRange(startTime, endTime);

                  if (currentCourtIndex != null) {
                    for (var slotIndex in slotIndices) {
                      bookSlot(currentCourtIndex, date, slotIndex);
                      print(
                          'Booking slot: date=$dateString, courtIndex=$currentCourtIndex, slotIndex=$slotIndex');
                    }
                  }
                }
              }
            }
          });

          print(' Booked slots parsed and saved.');
        } else {
          print(' Unexpected structure for bookingSlots or courtId.');
        }
      }

      if (state is BookingSelection) {
        final current = state as BookingSelection;
        emit(BookingSelection(
          date: current.date,
          courtIndex: current.courtIndex,
          selectedTimeIndices: current.selectedTimeIndices,
          timeSlots: generateTimeSlots(current.date),
        ));
      }
    });
  }

  List<int> _getSlotIndicesForTimeRange(DateTime startTime, DateTime endTime) {
    List<int> indices = [];
    List<Map<String, String>> timeSlots = generateTimeSlots(
        DateTime(startTime.year, startTime.month, startTime.day));

    for (int i = 0; i < timeSlots.length; i++) {
      DateTime slotStart = DateTime.parse(timeSlots[i]['startTime']!);
      DateTime slotEnd = DateTime.parse(timeSlots[i]['endTime']!);

      if ((slotStart.isAtSameMomentAs(startTime) ||
              slotStart.isAfter(startTime)) &&
          (slotEnd.isAtSameMomentAs(endTime) || slotEnd.isBefore(endTime))) {
        indices.add(i);
      }
    }

    return indices;
  }

  void selectDate(DateTime selectedDate) {
    if (state is BookingSelection) {
      final current = state as BookingSelection;
      final timeSlots = generateTimeSlots(selectedDate);
      emit(current.copyWith(
        date: selectedDate,
        timeSlots: timeSlots,
        selectedTimeIndices: [],
      ));
    }
  }

  Future<bool> confirmBooking(DateTime selectedDate, int courtIndex,
      List<int> selectedTimeIndices) async {
    if (selectedTimeIndices.isEmpty) {
      emit(BookingError('No time slots selected'));
      return false;
    }

    if (courtId == null) {
      emit(BookingError('No court selected'));
      return false;
    }

    for (var index in selectedTimeIndices) {
      if (index is! int) {
        print(
            'Invalid index type in selectedTimeIndices: $index (${index.runtimeType})');
        emit(BookingError('Invalid time slot index type'));
        return false;
      }
      if (isSlotBooked(selectedDate, courtIndex, index)) {
        emit(BookingError('Selected slot is already booked'));
        return false;
      }
      if (isPastTimeSlot(DateTime.parse(
          generateTimeSlots(selectedDate)[index]['startTime']!))) {
        emit(BookingError('Selected slot is in the past'));
        return false;
      }
    }

    emit(BookingLoading());
    final timeSlots = generateTimeSlots(selectedDate);
    List<List<int>> groupedIndices =
        _groupConsecutiveIndices(selectedTimeIndices);
    bool allSuccess = true;

    for (var group in groupedIndices) {
      if (group.isEmpty) continue;

      print('Processing group: $group');

      final startSlotIndex = group.first;
      final endSlotIndex = group.last;

      final startTimeString = timeSlots[startSlotIndex]['startTime'];
      final endTimeString = timeSlots[endSlotIndex]['endTime'];

      final booking = BookingModel(
        courtId: courtId,
        date: selectedDate.toIso8601String().split('T').first,
        startTime: startTimeString,
        endTime: endTimeString,
      );

      print('Booking payload: ${booking.toJson()}');
      final result = await bookingRepo.confirmBookingApi(booking);

      result.fold(
        (failure) {
          print('Booking failed: ${failure.errMessage}');
          emit(BookingError(failure.errMessage));
          allSuccess = false;
          if (failure.errMessage.contains('Authentication required') ||
              failure.errMessage.contains('401')) {
            throw Exception('Authentication required: ${failure.errMessage}');
          }
        },
        (success) {
          if (success) {
            for (var index in group) {
              bookSlot(courtIndex, selectedDate, index);
            }
          } else {
            emit(BookingError('Booking failed'));
            allSuccess = false;
          }
        },
      );
    }

    final updatedTimeSlots = generateTimeSlots(selectedDate);
    emit(BookingSelection(
      date: _lastSelectedDate ?? selectedDate,
      courtIndex: _lastCourtIndex ?? courtIndex,
      selectedTimeIndices: [],
      timeSlots: updatedTimeSlots,
    ));

    if (allSuccess) {
      emit(BookingSuccess());
      await Future.delayed(Duration(milliseconds: 200));
      emit(BookingSelection(
        date: selectedDate,
        courtIndex: courtIndex,
        selectedTimeIndices: [],
        timeSlots: updatedTimeSlots,
      ));
    }

    return allSuccess;
  }

  List<List<int>> _groupConsecutiveIndices(List<int> indices) {
    if (indices.isEmpty) return [];
    indices.sort();
    List<List<int>> groups = [];
    List<int> currentGroup = [indices.first];

    for (int i = 1; i < indices.length; i++) {
      if (indices[i] == indices[i - 1] + 1) {
        currentGroup.add(indices[i]);
      } else {
        groups.add(currentGroup);
        currentGroup = [indices[i]];
      }
    }
    groups.add(currentGroup);
    return groups;
  }

  void updateCourt(int courtIndex) {
    _lastCourtIndex = courtIndex;
    if (state is BookingSelection) {
      final current = state as BookingSelection;
      emit(current.copyWith(
        courtIndex: courtIndex,
        selectedTimeIndices: [],
        timeSlots: generateTimeSlots(current.date),
      ));
    }
  }

  void updateSelectedTimes(List<int> selectedTimeIndices) {
    if (state is BookingSelection) {
      final current = state as BookingSelection;
      emit(current.copyWith(selectedTimeIndices: selectedTimeIndices));
    }
  }

  void updateDate(DateTime date) {
    _lastSelectedDate = date;
    if (state is BookingSelection) {
      final current = state as BookingSelection;
      emit(current.copyWith(
        date: date,
        timeSlots: generateTimeSlots(date),
        selectedTimeIndices: [],
      ));
    }
  }

  void updateBooking(DateTime date, int courtIndex) {
    final timeSlots = generateTimeSlots(date);
    emit(BookingSelection(
      date: date,
      courtIndex: courtIndex,
      selectedTimeIndices: [],
      timeSlots: timeSlots,
    ));
  }

  List<Map<String, String>> generateTimeSlots(DateTime date) {
    List<Map<String, String>> timeSlots = [];
    DateTime startTime = DateTime(date.year, date.month, date.day, 6, 0);

    for (int i = 0; i < 24; i++) {
      DateTime endTime = startTime.add(const Duration(hours: 1));
      timeSlots.add({
        'start':
            "${startTime.hour > 12 ? startTime.hour - 12 : startTime.hour}:${startTime.minute.toString().padLeft(2, '0')} ${startTime.hour >= 12 ? 'PM' : 'AM'}",
        'end':
            "${endTime.hour > 12 ? endTime.hour - 12 : endTime.hour}:${endTime.minute.toString().padLeft(2, '0')} ${endTime.hour >= 12 ? 'PM' : 'AM'}",
        'startTime': startTime.toIso8601String(),
        'endTime': endTime.toIso8601String(),
      });
      startTime = endTime;
    }

    return timeSlots;
  }

  void bookSlot(int courtIndex, DateTime selectedDate, int slotIndex) {
    final dateKey =
        "${selectedDate.toIso8601String().split('T').first}_court_$courtIndex";

    if (!bookedSlots.containsKey(dateKey)) {
      bookedSlots[dateKey] = Set<int>();
    }

    bookedSlots[dateKey]?.add(slotIndex);
  }

  bool isSlotBooked(DateTime selectedDate, int courtIndex, int slotIndex) {
    final dateKey =
        "${selectedDate.toIso8601String().split('T').first}_court_$courtIndex";
    final isBooked = bookedSlots[dateKey]?.contains(slotIndex) ?? false;
    print(
        'Checking if slot is booked: date=${selectedDate.toIso8601String().split('T').first}, courtIndex=$courtIndex, slotIndex=$slotIndex, isBooked=$isBooked');
    return isBooked;
  }

  bool isPastTimeSlot(DateTime slotTime) {
    DateTime now = DateTime.now();
    DateTime currentTime =
        DateTime(now.year, now.month, now.day, now.hour, now.minute);
    return currentTime.isAfter(slotTime);
  }
}
