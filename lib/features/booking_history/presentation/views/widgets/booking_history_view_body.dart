import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:graduation_project/constants.dart';
import 'package:graduation_project/features/booking_history/data/models/booking/booking_history_model.dart';
import 'package:graduation_project/features/booking_history/presentation/manager/booking_history_cubit/booking_history_cubit.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

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
          indicatorColor: kPrimaryColor, // underline color
          labelColor: kPrimaryColor, // selected tab text color
          unselectedLabelColor: Colors.grey, // unselected tab text color
          indicatorWeight: 3, // thickness of the underline
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

  Widget _buildBookingList(List<BookingHistoryModel> bookings,
      {required bool isPast}) {
    if (bookings.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.calendar_month, size: 80, color: kPrimaryColor),
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
          color: kBackGroundColor,
          margin: const EdgeInsets.only(bottom: 16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Display facility name at the top
                Text(booking.facilityName ?? "Unknown Facility",
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 20, color: kPrimaryColor)),
                const SizedBox(height: 8),
                Text("${booking.courtName}",
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 18)),
                const SizedBox(height: 4),
                Text("$start to $end", style: const TextStyle(fontSize: 16)),
                Text(day, style: const TextStyle(fontSize: 16)),
                const SizedBox(height: 8),
                Text("Total Price: ${booking.totalPrice ?? '300'} EGP",
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
                          backgroundColor: isPast ? Colors.white : Colors.red,
                        ),
                        child: Text(
                          isPast ? "Past Booking" : "Cancel",
                          textAlign: TextAlign.center,
                          style: const TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    ElevatedButton.icon(
                      onPressed: () async {
                        Uri uri = Uri.parse(
                            'https://maps.app.goo.gl/qfYRLHfXK6tRzzU59');
                        if (await canLaunchUrl(uri)) {
                          await launchUrl(uri);
                        } else {
                          print('Could not launch the URL');
                        }
                      },
                      icon: const Icon(
                        Icons.map,
                        color: Colors.white,
                      ),
                      label: const Text("Get Directions",
                          style: TextStyle(
                            color: Colors.white,
                          )),
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