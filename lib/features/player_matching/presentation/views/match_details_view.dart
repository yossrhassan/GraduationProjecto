import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:graduation_project/features/player_matching/presentation/manager/match_cubit/match_cubit.dart';
import 'package:graduation_project/features/player_matching/presentation/manager/match_cubit/match_state.dart';
import 'package:graduation_project/features/player_matching/presentation/views/widgets/match_details_body.dart';
import 'package:graduation_project/features/player_matching/data/models/match_model.dart';
import 'package:intl/intl.dart';
import 'package:graduation_project/constants.dart';
import 'package:graduation_project/core/utils/auth_manager.dart';

class MatchDetailsView extends StatefulWidget {
  final String matchId;
  final bool isCreator;
  final MatchModel? matchData;
  final bool fromMyMatches;

  const MatchDetailsView({
    Key? key,
    required this.matchId,
    required this.isCreator,
    this.matchData,
    this.fromMyMatches = false,
  }) : super(key: key);

  @override
  State<MatchDetailsView> createState() => _MatchDetailsViewState();
}

class _MatchDetailsViewState extends State<MatchDetailsView> {
  @override
  void initState() {
    super.initState();
    // Always call API to get the most up-to-date match details
    context.read<MatchesCubit>().getMatchDetails(widget.matchId);
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MatchesCubit, MatchesState>(
      builder: (context, state) {
        // Determine current match data
        MatchModel? currentMatch;
        if (state is MatchDetailsLoaded) {
          currentMatch = state.match;
        } else if (widget.matchData != null) {
          currentMatch = widget.matchData!;
        }

        return Scaffold(
          backgroundColor: kBackGroundColor,
          appBar: AppBar(
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            title: BlocBuilder<MatchesCubit, MatchesState>(
              builder: (context, state) {
                if (state is MatchDetailsLoaded &&
                    state.match.date.isNotEmpty) {
                  final match = state.match;
                  final DateTime date = DateTime.parse(match.date);
                  final formattedDate =
                      DateFormat('EEEE, MMMM d, y').format(date);

                  // Create time range from start and end times
                  String formattedTime = '';
                  if (match.startTime.isNotEmpty && match.endTime.isNotEmpty) {
                    final startTime = _convertTo12Hour(match.startTime);
                    final endTime = _convertTo12Hour(match.endTime);
                    formattedTime = '$startTime - $endTime';
                  } else if (match.startTime.isNotEmpty) {
                    formattedTime = _convertTo12Hour(match.startTime);
                  } else if (match.endTime.isNotEmpty) {
                    formattedTime = _convertTo12Hour(match.endTime);
                  }

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        formattedDate,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        formattedTime,
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 16,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                  );
                } else if (widget.matchData != null) {
                  // Use initial match data while loading fresh data
                  final match = widget.matchData!;
                  final DateTime date = DateTime.parse(match.date);
                  final formattedDate =
                      DateFormat('EEEE, MMMM d, y').format(date);

                  // Create time range from start and end times
                  String formattedTime = '';
                  if (match.startTime.isNotEmpty && match.endTime.isNotEmpty) {
                    final startTime = _convertTo12Hour(match.startTime);
                    final endTime = _convertTo12Hour(match.endTime);
                    formattedTime = '$startTime - $endTime';
                  } else if (match.startTime.isNotEmpty) {
                    formattedTime = _convertTo12Hour(match.startTime);
                  } else if (match.endTime.isNotEmpty) {
                    formattedTime = _convertTo12Hour(match.endTime);
                  }

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        formattedDate,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        formattedTime,
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 16,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                  );
                } else if (state is MatchesLoading) {
                  return const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Loading...',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  );
                } else if (state is MatchesError) {
                  return const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Error loading match',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  );
                } else {
                  return const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Date not set',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        'Time not set',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 16,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                  );
                }
              },
            ),
            elevation: 0,
          ),
          body: BlocBuilder<MatchesCubit, MatchesState>(
            builder: (context, state) {
              MatchModel? currentMatch;

              if (state is MatchDetailsLoaded) {
                currentMatch = state.match;
              } else if (widget.matchData != null) {
                currentMatch = widget.matchData!;
              }

              if (currentMatch != null) {
                return MatchDetailsBody(
                  isCreator: widget.isCreator,
                  matchData: currentMatch,
                );
              } else if (state is MatchesLoading) {
                return const Center(child: CircularProgressIndicator());
              } else if (state is MatchesError) {
                return Center(
                  child: Text(
                    'Error: ${state.message}',
                    style: const TextStyle(color: Colors.white),
                  ),
                );
              } else {
                return const Center(child: CircularProgressIndicator());
              }
            },
          ),
        );
      },
    );
  }

  String _convertTo12Hour(String time24) {
    try {
      // Parse time in HH:mm format
      final timeParts = time24.split(':');
      if (timeParts.length >= 2) {
        int hour = int.parse(timeParts[0]);
        final minute = timeParts[1];

        String period = 'AM';
        if (hour == 0) {
          hour = 12; // Midnight
        } else if (hour == 12) {
          period = 'PM'; // Noon
        } else if (hour > 12) {
          hour = hour - 12;
          period = 'PM';
        }

        return '$hour:$minute $period';
      }
    } catch (e) {
      // If parsing fails, return the original time
      return time24;
    }
    return time24;
  }
}
