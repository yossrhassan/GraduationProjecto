import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:graduation_project/features/booking_history/data/models/booking/booking_history_model.dart';
import 'package:graduation_project/features/booking_history/presentation/manager/booking_history_cubit/booking_history_cubit.dart';
import 'package:graduation_project/features/player_matching/presentation/manager/match_cubit/match_cubit.dart';
import 'package:graduation_project/features/player_matching/presentation/views/widgets/custom_form_field.dart';
import 'package:graduation_project/core/utils/app_router.dart';

class MatchCreationView extends StatefulWidget {
  const MatchCreationView({Key? key}) : super(key: key);

  @override
  State<MatchCreationView> createState() => _MatchCreationViewState();
}

class _MatchCreationViewState extends State<MatchCreationView> {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  BookingHistoryModel? selectedBooking;
  String numberOfPlayers = '10 Players (5v5)';

  @override
  void initState() {
    super.initState();
    // Load bookings using the cubit
    context.read<BookingHistoryCubit>().loadBookings();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Create a match',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w500,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => GoRouter.of(context).pop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.check, color: Colors.white),
            onPressed: () {
              if (selectedBooking != null) {
                // Extract match type from the selected option
                final String matchType = numberOfPlayers.contains('5v5')
                    ? '5v5'
                    : numberOfPlayers.contains('7v7')
                        ? '7v7'
                        : '11v11';

                // Calculate total players based on match type
                final int totalPlayers =
                    int.tryParse(numberOfPlayers.split(' ')[0]) ?? 10;

                // Derive sport type from booking (assuming it's in the court name or facility name)
                String derivedSportType = 'Football'; // Default
                final courtName =
                    selectedBooking!.courtName?.toLowerCase() ?? '';
                final facilityName =
                    selectedBooking!.facilityName?.toLowerCase() ?? '';

                if (courtName.contains('basketball') ||
                    facilityName.contains('basketball')) {
                  derivedSportType = 'Basketball';
                } else if (courtName.contains('tennis') ||
                    facilityName.contains('tennis')) {
                  derivedSportType = 'Tennis';
                } else if (courtName.contains('volleyball') ||
                    facilityName.contains('volleyball')) {
                  derivedSportType = 'Volleyball';
                }

                final Map<String, dynamic> matchData = {
                  'bookingId': selectedBooking!.id,
                  'sportType': derivedSportType,
                  'teamSize': totalPlayers ~/
                      2, // Divide total players by 2 for team size
                  'title': selectedBooking!.city ??
                      selectedBooking!.facilityName ??
                      'Unknown Location', // Use city as title
                  'description':
                      'Match at ${selectedBooking!.facilityName}', // Simple default description
                  'minSkillLevel': 1, // Default minimum skill level
                  'maxSkillLevel': 10, // Default maximum skill level
                  'isPrivate': false,
                  'date': selectedBooking!.date,
                  'time':
                      '${selectedBooking!.startTime} - ${selectedBooking!.endTime}',
                  'location':
                      selectedBooking!.city ?? selectedBooking!.facilityName,
                  'court': selectedBooking!.courtName,
                  'status': 'OPEN',
                  'match_type': matchType,
                  'total_players': totalPlayers,
                  'joined_players': 1,
                  'price': selectedBooking!.totalPrice,
                  'is_creator': true,
                  'payment_at_location': true, // Default to true
                  'notes': '', // Empty notes
                  'team_a': [
                    {'id': 'current_user_id', 'name': 'You', 'is_captain': true}
                  ],
                  'team_b': []
                };

                // Create match using Cubit
                context.read<MatchesCubit>().createMatch(matchData).then((_) {
                  // Show success message
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text('Match created successfully!')),
                  );

                  // Navigate to main navigation with Player Matching tab selected
                  GoRouter.of(context).pushReplacement(
                    AppRouter.kMainNavigationView,
                    extra: {'initial_index': 2}, // 2 for Player Matching tab
                  );
                }).catchError((error) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error creating match: $error')),
                  );
                });
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                      content:
                          Text('Please select a booking to create a match')),
                );
              }
            },
          ),
        ],
      ),
      body: BlocBuilder<BookingHistoryCubit, BookingHistoryState>(
        builder: (context, state) {
          if (state is BookingHistoryLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is BookingHistoryError) {
            return Center(child: Text('Error: ${state.message}'));
          } else if (state is BookingHistoryLoaded) {
            final upcomingBookings = state.upcomingBookings;

            // Initialize selectedBooking if not already set and we have bookings
            if (selectedBooking == null && upcomingBookings.isNotEmpty) {
              selectedBooking = upcomingBookings.first;
            }

            return Form(
              key: formKey,
              child: ListView(
                padding: const EdgeInsets.all(16.0),
                children: [
                  // Booking Selection Dropdown
                  Container(
                    padding: const EdgeInsets.symmetric(
                        vertical: 16.0, horizontal: 16.0),
                    decoration: BoxDecoration(
                      color: const Color(0xFF06845A),
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<BookingHistoryModel>(
                        value: selectedBooking,
                        dropdownColor: const Color(0xFF06845A),
                        isExpanded: true,
                        icon: const Icon(Icons.arrow_drop_down,
                            color: Colors.white),
                        hint: const Text(
                          'Select a booking',
                          style: TextStyle(color: Colors.white54),
                        ),
                        selectedItemBuilder: (context) {
                          return upcomingBookings.map((booking) {
                            return Container(
                              width: double.infinity,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    '${booking.facilityName} - ${booking.courtName}',
                                    style: const TextStyle(color: Colors.white),
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 1,
                                  ),
                                  Text(
                                    '${booking.date} | ${booking.startTime} - ${booking.endTime}',
                                    style: const TextStyle(
                                        color: Colors.white70, fontSize: 12),
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 1,
                                  ),
                                ],
                              ),
                            );
                          }).toList();
                        },
                        items: upcomingBookings.map((booking) {
                          return DropdownMenuItem<BookingHistoryModel>(
                            value: booking,
                            child: Container(
                              width: double.infinity,
                              constraints: const BoxConstraints(maxWidth: 300),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    '${booking.facilityName} - ${booking.courtName}',
                                    style: const TextStyle(color: Colors.white),
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 1,
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '${booking.date} | ${booking.startTime} - ${booking.endTime}',
                                    style: const TextStyle(
                                        color: Colors.white70, fontSize: 12),
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 1,
                                  ),
                                ],
                              ),
                            ),
                          );
                        }).toList(),
                        onChanged: (BookingHistoryModel? newValue) {
                          setState(() {
                            selectedBooking = newValue;
                          });
                        },
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Display selected booking info
                  if (selectedBooking != null)
                    Container(
                      padding: const EdgeInsets.all(16.0),
                      decoration: BoxDecoration(
                        color: Colors.green.shade800,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Selected Booking',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              const Icon(Icons.calendar_today,
                                  color: Colors.white70, size: 18),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  selectedBooking!.date ?? 'Date not available',
                                  style: const TextStyle(
                                      color: Colors.white, fontSize: 14),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              const Icon(Icons.access_time,
                                  color: Colors.white70, size: 18),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  '${selectedBooking!.startTime} - ${selectedBooking!.endTime}',
                                  style: const TextStyle(
                                      color: Colors.white, fontSize: 14),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              const Icon(Icons.location_city,
                                  color: Colors.white70, size: 18),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  '${selectedBooking!.facilityName} - ${selectedBooking!.courtName}',
                                  style: const TextStyle(
                                      color: Colors.white, fontSize: 14),
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 2,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              const Icon(Icons.location_on,
                                  color: Colors.white70, size: 18),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  selectedBooking!.city ??
                                      selectedBooking!.facilityName ??
                                      'Location not available',
                                  style: const TextStyle(
                                      color: Colors.white, fontSize: 14),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              const Icon(Icons.attach_money,
                                  color: Colors.white70, size: 18),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'Price: ${selectedBooking!.totalPrice} LE/player',
                                  style: const TextStyle(
                                      color: Colors.white, fontSize: 14),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                  const SizedBox(height: 24),

                  // Number of Players
                  CustomFormField(
                    label: 'Number Of Players',
                    value: numberOfPlayers,
                    icon: Icons.chevron_right,
                    onTap: () {
                      // Show player count selection dialog
                      showDialog(
                        context: context,
                        builder: (context) => SimpleDialog(
                          title: const Text('Select Number of Players'),
                          children: [
                            '10 Players (5v5)',
                            '14 Players (7v7)',
                            '22 Players (11v11)',
                          ]
                              .map((option) => SimpleDialogOption(
                                    onPressed: () {
                                      setState(() {
                                        numberOfPlayers = option;
                                      });
                                      Navigator.pop(context);
                                    },
                                    child: Text(option),
                                  ))
                              .toList(),
                        ),
                      );
                    },
                  ),
                ],
              ),
            );
          } else {
            // Handle any other state or empty state
            return const Center(child: Text('No bookings available'));
          }
        },
      ),
    );
  }
}
