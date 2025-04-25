import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:graduation_project/features/booking_history/presentation/manager/booking_history_cubit/booking_history_cubit.dart';
import 'package:intl/intl.dart';
import 'package:graduation_project/features/booking/data/models/booking.model.dart';

class BookingHistoryViewBody extends StatefulWidget {
  const BookingHistoryViewBody({super.key});

  @override
  State<BookingHistoryViewBody> createState() => _BookingHistoryViewBodyState();
}

class _BookingHistoryViewBodyState extends State<BookingHistoryViewBody>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    context.read<BookingHistoryCubit>().loadBookings();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("My Bookings"),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: "Upcoming"),
            Tab(text: "Past"),
          ],
        ),
      ),
      body: BlocBuilder<BookingHistoryCubit, BookingHistoryState>(
        builder: (context, state) {
          if (state is BookingHistoryLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is BookingHistoryError) {
            return Center(child: Text(state.message));
          } else if (state is BookingHistoryLoaded) {
            return TabBarView(
              controller: _tabController,
              children: [
                _buildBookingList(state.upcomingBookings, isPast: false),
                _buildBookingList(state.pastBookings, isPast: true),
              ],
            );
          } else {
            return const SizedBox();
          }
        },
      ),
    );
  }

  Widget _buildBookingList(List<BookingModel> bookings,
      {required bool isPast}) {
    if (bookings.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.calendar_month, size: 80, color: Colors.blue),
            SizedBox(height: 10),
            Text("You have no bookings yet.", style: TextStyle(fontSize: 16)),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: bookings.length,
      itemBuilder: (context, index) {
        final booking = bookings[index];
        final start = DateFormat.jm()
            .format(DateTime.parse("${booking.date}T${booking.startTime}"));
        final end = DateFormat.jm()
            .format(DateTime.parse("${booking.date}T${booking.endTime}"));
        final day = DateFormat.yMMMEd().format(DateTime.parse(booking.date!));

        return Card(
          margin: const EdgeInsets.only(bottom: 16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Court ${booking.courtId}",
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 18)),
                const SizedBox(height: 4),
                Text("$start to $end", style: const TextStyle(fontSize: 16)),
                Text(day, style: const TextStyle(fontSize: 16)),
                const SizedBox(height: 8),
                const Text("Total Price: ${'300'} EGP",
                    style: const TextStyle(fontSize: 16)),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: isPast
                            ? null
                            : () {
                                // Handle cancellation
                              },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: isPast ? Colors.grey : Colors.red,
                        ),
                        child: Text(isPast ? "Past Booking" : "Cancel Booking"),
                      ),
                    ),
                    const SizedBox(width: 10),
                    ElevatedButton.icon(
                      onPressed: () {
                        // Maybe open maps
                      },
                      icon: const Icon(Icons.map),
                      label: const Text("Get Directions"),
                    ),
                  ],
                )
              ],
            ),
          ),
        );
      },
    );
  }
}
