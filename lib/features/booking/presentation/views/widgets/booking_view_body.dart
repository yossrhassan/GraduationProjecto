import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:graduation_project/constants.dart';
import 'package:graduation_project/core/utils/app_router.dart';
import 'package:graduation_project/core/utils/auth_manager.dart';
import 'package:graduation_project/features/booking/presentation/manager/booking_cubit/booking_cubit.dart';
import 'package:graduation_project/features/booking/presentation/views/widgets/bottom_booking_confirmation.dart';
import 'package:graduation_project/features/booking/presentation/views/widgets/date_picker.dart';

class BookingViewBody extends StatefulWidget {
  const BookingViewBody({super.key});

  @override
  State<BookingViewBody> createState() => _BookingViewBodyState();
}

class _BookingViewBodyState extends State<BookingViewBody> {
  int? selectedCourtIndex = 0;
  final Map<String, List<int>> selectedSlots = {};
  final Map<String, List<int>> confirmedSlots = {};
  final int priceSlot = 300;

  List<String> courts = ["Court 1", "Court 2", "Court 3", "Court 4"];

  String getKey(DateTime date, int courtIndex) {
    return '${date.toIso8601String().split("T").first}|$courtIndex';
  }

  @override
  void initState() {
    super.initState();
    final cubit = context.read<BookingCubit>();
    if (cubit.state is BookingInitial) {
      cubit.updateBooking(DateTime.now(), 0); // ✅ only set default once
    }

    final state = cubit.state;
    if (state is BookingSelection) {
      cubit.updateBooking(state.date, state.courtIndex);
    }

    // Check authentication status
    _checkAuthentication();

    // Fetch bookings from API on app startup
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // This ensures the widget is fully built before fetching data
      context.read<BookingCubit>().fetchExistingBookings();
    });
  }

  void _checkAuthentication() {
    // If no token, redirect to login
    if (AuthManager.authToken == null || !AuthManager.isAuthenticated) {
      Future.delayed(Duration.zero, () {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please login first to book courts'),
            backgroundColor: Colors.orange,
          ),
        );
        GoRouter.of(context).push(AppRouter.kLoginView);
      });
    }
  }

  void handleConfirmation(DateTime date, int courtIndex) async {
    if (!AuthManager.isAuthenticated) {
      // Redirect to login if not authenticated
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("You need to login first"),
          backgroundColor: Colors.red,
        ),
      );
      GoRouter.of(context).push(AppRouter.kLoginView);
      return;
    }

    try {
      // Store the selected date and court index before making the API call
      final selectedDate = date;
      final selectedCourtIndex = courtIndex;

      // Call the cubit to confirm booking with API
      final success = await context.read<BookingCubit>().confirmBooking(
            selectedDate,
            selectedCourtIndex,
            selectedSlots[getKey(selectedDate, selectedCourtIndex)] ?? [],
          );

      // Show appropriate message based on API response
      if (success) {
        setState(() {
          // Clear the selected slots since they're now confirmed
          selectedSlots[getKey(selectedDate, selectedCourtIndex)] = [];
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Booking Confirmed!")),
        );

        // Refresh the bookings display - but keep the selected date and court!
        context.read<BookingCubit>().fetchExistingBookings();

        // The cubit should keep the date/court selection, but for extra safety:
        context
            .read<BookingCubit>()
            .updateBooking(selectedDate, selectedCourtIndex);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Failed to confirm booking. Please try again."),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      String errorMessage = "Error: $e";
      if (e.toString().contains('401') ||
          e.toString().contains('Authentication required')) {
        // Handle authentication error specifically
        errorMessage = "Your session has expired. Please login again.";
        await AuthManager.clearAuthToken();
        GoRouter.of(context).push(AppRouter.kLoginView);
      } else if (e.toString().contains('400')) {
        // Handle 400 errors with specific message
        errorMessage =
            "Invalid booking request: ${e.toString().replaceFirst('Exception: Request failed with status: 400, body: ', '')}";
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMessage),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackGroundColor,
      appBar: AppBar(
        backgroundColor: kBackGroundColor,
        title: const Text("Cairo Stadium",
            style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w500,
                color: kPrimaryColor)),
        centerTitle: true,
      ),
      body: BlocBuilder<BookingCubit, BookingState>(builder: (context, state) {
        // Handle loading state
        if (state is BookingLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        // Handle error state
        if (state is BookingError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  state.message,
                  style: TextStyle(color: Colors.red),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    context
                        .read<BookingCubit>()
                        .updateBooking(DateTime.now(), selectedCourtIndex ?? 0);

                    // Also refresh bookings data
                    context.read<BookingCubit>().fetchExistingBookings();
                  },
                  child: Text('Retry'),
                ),
              ],
            ),
          );
        }

        DateTime selectedDate = DateTime.now();
        int selectedCourt = 0;
        List<Map<String, String>> timeSlots = [];

        if (state is BookingSelection) {
          selectedDate = state.date;
          selectedCourt = state.courtIndex;
          timeSlots = state.timeSlots;
          // Synchronize our local selected court with state
          if (selectedCourtIndex != selectedCourt) {
            selectedCourtIndex = selectedCourt;
          }
        }

        String key = getKey(selectedDate, selectedCourtIndex ?? 0);
        List<int> selectedTimeIndices = selectedSlots[key] ?? [];
        List<int> confirmedTimeIndices = confirmedSlots[key] ?? [];

        return Column(
          children: [
            const DatePickerWidget(),
            SizedBox(
              height: 50,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: courts.length,
                itemBuilder: (context, index) {
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        selectedCourtIndex = index;
                      });
                      context
                          .read<BookingCubit>()
                          .updateCourt(selectedCourtIndex ?? 0);
                    },
                    child: Container(
                      alignment: Alignment.center,
                      margin: const EdgeInsets.symmetric(horizontal: 10),
                      padding: const EdgeInsets.all(15),
                      decoration: BoxDecoration(
                        color: selectedCourtIndex == index
                            ? Colors.green
                            : Colors.grey[800],
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Text(
                        courts[index],
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('$priceSlot EGP', style: const TextStyle(fontSize: 18)),
                const SizedBox(width: 10),
                const Text('Court Size : 5 vs 5',
                    style: TextStyle(fontSize: 18))
              ],
            ),
            const SizedBox(height: 10),
            Expanded(
              child: timeSlots.isEmpty
                  ? const Center(
                      child:
                          CircularProgressIndicator()) // Show loading if no time slots
                  : ListView.builder(
                      itemCount: timeSlots.length,
                      itemBuilder: (context, index) {
                        final startTime =
                            DateTime.parse(timeSlots[index]['startTime']!);
                        bool isToday = selectedDate.day == DateTime.now().day &&
                            selectedDate.month == DateTime.now().month &&
                            selectedDate.year == DateTime.now().year;
                        bool isPastTime = isToday &&
                            context
                                .read<BookingCubit>()
                                .isPastTimeSlot(startTime);
                        bool isBooked = context
                            .read<BookingCubit>()
                            .isSlotBooked(
                                selectedDate, selectedCourtIndex ?? 0, index);
                        bool isConfirmed = confirmedTimeIndices.contains(index);

                        return GestureDetector(
                          onTap: isPastTime || isBooked || isConfirmed
                              ? null
                              : () {
                                  setState(() {
                                    if (selectedTimeIndices.contains(index)) {
                                      selectedTimeIndices.remove(index);
                                    } else {
                                      selectedTimeIndices.add(index);
                                    }
                                    selectedSlots[key] = selectedTimeIndices;
                                    context
                                        .read<BookingCubit>()
                                        .updateSelectedTimes(
                                            selectedTimeIndices);
                                  });
                                },
                          child: Column(
                            children: [
                              Container(
                                alignment: Alignment.center,
                                margin:
                                    const EdgeInsets.symmetric(horizontal: 30),
                                padding: const EdgeInsets.all(15),
                                decoration: BoxDecoration(
                                  color: isPastTime
                                      ? Colors.red
                                      : isConfirmed
                                          ? Colors.red
                                          : isBooked
                                              ? Colors.red
                                              : selectedTimeIndices
                                                      .contains(index)
                                                  ? Colors.green
                                                  : Colors.grey[800],
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      timeSlots[index]['start']!,
                                      style: const TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.w500,
                                          color: Colors.white),
                                    ),
                                    const SizedBox(width: 10),
                                    const Icon(Icons.arrow_forward,
                                        size: 30, color: Colors.white),
                                    const SizedBox(width: 10),
                                    Text(
                                      timeSlots[index]['end']!,
                                      style: const TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.w500,
                                          color: Colors.white),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 10),
                            ],
                          ),
                        );
                      },
                    ),
            ),
            if (selectedTimeIndices.isNotEmpty)
              BottomBookingConfirmation(
                selectedDate: selectedDate,
                timeSlots: timeSlots,
                selectedTimeIndices: selectedTimeIndices,
                onConfirm: () =>
                    handleConfirmation(selectedDate, selectedCourtIndex ?? 0),
                priceSlot: priceSlot,
              )
          ],
        );
      }),
    );
  }
}
