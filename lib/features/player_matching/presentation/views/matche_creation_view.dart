import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';
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
  final TextEditingController notesController = TextEditingController();
  final TextEditingController titleController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();

  BookingHistoryModel? selectedBooking;
  String numberOfPlayers = '10 Players (5v5)';
  bool paymentAtLocation = true;
  String sportType = 'Football'; // Default sport type
  int minSkillLevel = 1;
  int maxSkillLevel = 5;
  bool isPrivate = false;

  @override
  void initState() {
    super.initState();
    // Load bookings using the cubit
    context.read<BookingHistoryCubit>().loadBookings();
  }

  @override
  void dispose() {
    notesController.dispose();
    titleController.dispose();
    descriptionController.dispose();
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
              if (formKey.currentState!.validate() && selectedBooking != null) {
                // Create match data from form inputs and selected booking
                final String matchId = const Uuid().v4();

                // Extract match type from the selected option
                final String matchType = numberOfPlayers.contains('5v5')
                    ? '5v5'
                    : numberOfPlayers.contains('7v7')
                        ? '7v7'
                        : '11v11';

                // Calculate total players based on match type
                final int totalPlayers =
                    int.tryParse(numberOfPlayers.split(' ')[0]) ?? 10;

                final Map<String, dynamic> matchData = {
                  'bookingId': selectedBooking!.id,
                  'sportType': sportType,
                  'teamSize': totalPlayers ~/
                      2, // Divide total players by 2 for team size
                  'title': '6 october', // Set city name as title
                  'description': descriptionController.text,
                  'minSkillLevel': minSkillLevel,
                  'maxSkillLevel': maxSkillLevel,
                  'isPrivate': isPrivate,
                  // Additional data for UI
                  'id': matchId,
                  'date': selectedBooking!.date,
                  'time':
                      '${selectedBooking!.startTime} - ${selectedBooking!.endTime}',
                  'location': selectedBooking!.facilityName,
                  'court': selectedBooking!.courtName,
                  'status': 'OPEN',
                  'match_type': matchType,
                  'total_players': totalPlayers,
                  'joined_players': 1,
                  'price': selectedBooking!.totalPrice,
                  'is_creator': true,
                  'payment_at_location': paymentAtLocation,
                  'notes': notesController.text,
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

                  // Navigate to matches view and switch to "My Matches" tab
                  GoRouter.of(context).pushReplacement(
                    AppRouter.kMatchesView,
                    extra: {'initial_tab': 1}, // 1 for "My Matches" tab
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
                        items: upcomingBookings.map((booking) {
                          return DropdownMenuItem<BookingHistoryModel>(
                            value: booking,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '${booking.facilityName} - ${booking.courtName}',
                                  style: const TextStyle(color: Colors.white),
                                ),
                                Text(
                                  '${booking.date} | ${booking.startTime} - ${booking.endTime}',
                                  style: const TextStyle(
                                      color: Colors.white70, fontSize: 14),
                                ),
                              ],
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
                              Text(
                                selectedBooking!.date ?? 'Date not available',
                                style: const TextStyle(
                                    color: Colors.white, fontSize: 14),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              const Icon(Icons.access_time,
                                  color: Colors.white70, size: 18),
                              const SizedBox(width: 8),
                              Text(
                                '${selectedBooking!.startTime} - ${selectedBooking!.endTime}',
                                style: const TextStyle(
                                    color: Colors.white, fontSize: 14),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              const Icon(Icons.location_on,
                                  color: Colors.white70, size: 18),
                              const SizedBox(width: 8),
                              Text(
                                '${selectedBooking!.facilityName} - ${selectedBooking!.courtName}',
                                style: const TextStyle(
                                    color: Colors.white, fontSize: 14),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              const Icon(Icons.attach_money,
                                  color: Colors.white70, size: 18),
                              const SizedBox(width: 8),
                              Text(
                                'Price: ${selectedBooking!.totalPrice} LE/player',
                                style: const TextStyle(
                                    color: Colors.white, fontSize: 14),
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

                  const SizedBox(height: 12),

                  // Invite Friends
                  CustomFormField(
                    label: 'Invite Friends',
                    value: 'Optional',
                    icon: Icons.chevron_right,
                    onTap: () {
                      // Show friend invitation dialog or navigate to friends selection
                    },
                  ),

                  const SizedBox(height: 12),

                  // Add Guests
                  CustomFormField(
                    label: 'Add Guests',
                    value: 'Optional',
                    icon: Icons.chevron_right,
                    onTap: () {
                      // Show guest addition dialog
                    },
                  ),

                  const SizedBox(height: 12),

                  // Payment at location toggle
                  Container(
                    padding: const EdgeInsets.symmetric(
                        vertical: 16.0, horizontal: 16.0),
                    decoration: BoxDecoration(
                      color: const Color(0xFF06845A),
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Payment at location',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16.0,
                          ),
                        ),
                        Switch(
                          value: paymentAtLocation,
                          onChanged: (value) {
                            setState(() {
                              paymentAtLocation = value;
                            });
                          },
                          activeColor: Colors.white,
                          activeTrackColor: Colors.green.shade300,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 12),

                  // Match Title
                  Container(
                    padding: const EdgeInsets.symmetric(
                        vertical: 16.0, horizontal: 16.0),
                    decoration: BoxDecoration(
                      color: const Color(0xFF06845A),
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    child: TextFormField(
                      controller: titleController,
                      decoration: const InputDecoration(
                        hintText: 'Match Location',
                        hintStyle: TextStyle(color: Colors.white70),
                        border: InputBorder.none,
                      ),
                      style: const TextStyle(color: Colors.white),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a match title';
                        }
                        return null;
                      },
                    ),
                  ),

                  const SizedBox(height: 12),

                  // Sport Type Selection
                  Container(
                    padding: const EdgeInsets.symmetric(
                        vertical: 16.0, horizontal: 16.0),
                    decoration: BoxDecoration(
                      color: const Color(0xFF06845A),
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: sportType,
                        dropdownColor: const Color(0xFF06845A),
                        isExpanded: true,
                        icon: const Icon(Icons.arrow_drop_down,
                            color: Colors.white),
                        style: const TextStyle(color: Colors.white),
                        items: [
                          'Football',
                          'Basketball',
                          'Tennis',
                          'Volleyball'
                        ].map((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                        onChanged: (String? newValue) {
                          if (newValue != null) {
                            setState(() {
                              sportType = newValue;
                            });
                          }
                        },
                      ),
                    ),
                  ),

                  const SizedBox(height: 12),

                  // Description
                  Container(
                    padding: const EdgeInsets.symmetric(
                        vertical: 16.0, horizontal: 16.0),
                    decoration: BoxDecoration(
                      color: const Color(0xFF06845A),
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    child: TextFormField(
                      controller: descriptionController,
                      decoration: const InputDecoration(
                        hintText: 'Match Description',
                        hintStyle: TextStyle(color: Colors.white70),
                        border: InputBorder.none,
                      ),
                      style: const TextStyle(color: Colors.white),
                      maxLines: 3,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a match description';
                        }
                        return null;
                      },
                    ),
                  ),

                  const SizedBox(height: 12),

                  // Skill Level Range
                  Container(
                    padding: const EdgeInsets.symmetric(
                        vertical: 16.0, horizontal: 16.0),
                    decoration: BoxDecoration(
                      color: const Color(0xFF06845A),
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Skill Level Range',
                          style: TextStyle(color: Colors.white, fontSize: 16),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Expanded(
                              child: DropdownButtonFormField<int>(
                                value: minSkillLevel,
                                dropdownColor: const Color(0xFF06845A),
                                decoration: const InputDecoration(
                                  labelText: 'Min Level',
                                  labelStyle: TextStyle(color: Colors.white70),
                                  border: InputBorder.none,
                                ),
                                style: const TextStyle(color: Colors.white),
                                items: List.generate(5, (index) => index + 1)
                                    .map((int value) {
                                  return DropdownMenuItem<int>(
                                    value: value,
                                    child: Text('Level $value'),
                                  );
                                }).toList(),
                                onChanged: (int? newValue) {
                                  if (newValue != null) {
                                    setState(() {
                                      minSkillLevel = newValue;
                                    });
                                  }
                                },
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: DropdownButtonFormField<int>(
                                value: maxSkillLevel,
                                dropdownColor: const Color(0xFF06845A),
                                decoration: const InputDecoration(
                                  labelText: 'Max Level',
                                  labelStyle: TextStyle(color: Colors.white70),
                                  border: InputBorder.none,
                                ),
                                style: const TextStyle(color: Colors.white),
                                items: List.generate(5, (index) => index + 1)
                                    .map((int value) {
                                  return DropdownMenuItem<int>(
                                    value: value,
                                    child: Text('Level $value'),
                                  );
                                }).toList(),
                                onChanged: (int? newValue) {
                                  if (newValue != null) {
                                    setState(() {
                                      maxSkillLevel = newValue;
                                    });
                                  }
                                },
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 12),

                  // Private Match Toggle
                  Container(
                    padding: const EdgeInsets.symmetric(
                        vertical: 16.0, horizontal: 16.0),
                    decoration: BoxDecoration(
                      color: const Color(0xFF06845A),
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Private Match',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16.0,
                          ),
                        ),
                        Switch(
                          value: isPrivate,
                          onChanged: (value) {
                            setState(() {
                              isPrivate = value;
                            });
                          },
                          activeColor: Colors.white,
                          activeTrackColor: Colors.green.shade300,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 12),

                  // Match Notes
                  Container(
                    padding: const EdgeInsets.all(8.0),
                    decoration: BoxDecoration(
                      color: const Color(0xFF06845A),
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    child: TextField(
                      controller: notesController,
                      decoration: const InputDecoration(
                        hintText: 'Match Notes',
                        hintStyle: TextStyle(color: Colors.white70),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.all(8.0),
                      ),
                      style: const TextStyle(color: Colors.white),
                      maxLines: 3,
                    ),
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
