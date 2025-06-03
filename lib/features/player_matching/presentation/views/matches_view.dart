// 5. IMPLEMENTATION EXAMPLE IN MATCHES VIEW
// player_matching/presentation/views/matches_view.dart (with Cubit)
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:graduation_project/core/utils/app_router.dart';
import 'package:graduation_project/features/player_matching/data/models/match_model.dart';
import 'package:graduation_project/features/player_matching/presentation/manager/match_cubit/match_cubit.dart';
import 'package:graduation_project/features/player_matching/presentation/manager/match_cubit/match_state.dart';
import 'package:graduation_project/features/player_matching/presentation/views/widgets/match_card.dart';
import 'package:graduation_project/core/utils/auth_manager.dart';
import 'package:intl/intl.dart';

class MatchesView extends StatefulWidget {
  final int? initialTab;
  const MatchesView({Key? key, this.initialTab}) : super(key: key);

  @override
  State<MatchesView> createState() => _MatchesViewState();
}

class _MatchesViewState extends State<MatchesView>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: 2,
      vsync: this,
      initialIndex: widget.initialTab ?? 0,
    );

    // Load matches based on initial tab
    if (widget.initialTab == 1) {
      _loadMyMatches();
    } else {
      _loadAvailableMatches();
    }

    // Add listener to load appropriate data when tab changes
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        if (_tabController.index == 0) {
          _loadAvailableMatches();
        } else {
          _loadMyMatches();
        }
      }
    });
  }

  void _loadAvailableMatches() {
    context.read<MatchesCubit>().getAvailableMatches();
  }

  void _loadMyMatches() {
    context.read<MatchesCubit>().getMyMatches();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Matches',
          style: TextStyle(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.w500,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.chat_bubble_outline, color: Colors.white),
            onPressed: () {
              // Open chat or messages
            },
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          indicatorWeight: 3.0,
          tabs: const [
            Tab(text: 'AVAILABLE MATCHES'),
            Tab(text: 'MY MATCHES'),
          ],
          labelColor: Colors.white,
        ),
        elevation: 0,
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Available Matches Tab with BlocBuilder
          BlocBuilder<MatchesCubit, MatchesState>(
            builder: (context, state) {
              if (state is MatchesLoading) {
                return const Center(child: CircularProgressIndicator());
              } else if (state is AvailableMatchesLoaded) {
                return _buildMatchesList(state.matches, false);
              } else if (state is MatchesError) {
                return Center(child: Text('Error: ${state.message}'));
              } else {
                // Initial state or other unhandled states
                return const Center(child: Text('No matches available'));
              }
            },
          ),
          // My Matches Tab with BlocBuilder
          BlocBuilder<MatchesCubit, MatchesState>(
            builder: (context, state) {
              if (state is MatchesLoading) {
                return const Center(child: CircularProgressIndicator());
              } else if (state is MyMatchesLoaded) {
                return _buildMatchesList(state.matches, true);
              } else if (state is MatchesError) {
                return Center(
                    child: Text('Error: ${state.message}',
                        style: TextStyle(color: Colors.white)));
              } else {
                return const Center(
                    child: Text('You have no matches',
                        style: TextStyle(color: Colors.white)));
              }
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Navigate to match creation
          GoRouter.of(context).push(AppRouter.kMatchCreationView);
        },
        backgroundColor: Colors.white,
        child: const Icon(Icons.add, color: Colors.black),
      ),
    );
  }

  Widget _buildMatchesList(List<MatchModel> matches, bool isMyMatches) {
    // Get the current user ID from your auth/session
    final int? currentUserId =
        AuthManager.userId; // Make sure this is set after login

    // Filter matches based on the tab
    final filteredMatches = isMyMatches
        ? matches.where((m) => m.creatorUserId == currentUserId).toList()
        : matches.where((m) => m.creatorUserId != currentUserId).toList();

    if (filteredMatches.isEmpty) {
      return Center(
        child: Text(
          isMyMatches ? 'You have no matches' : 'No matches available',
          style: const TextStyle(color: Colors.white),
        ),
      );
    }

    // Group matches by date
    Map<String, List<MatchModel>> groupedMatches = {};
    Map<String, DateTime> dateKeyToDate =
        {}; // To keep track of actual dates for sorting

    for (var match in filteredMatches) {
      if (match.date.isNotEmpty) {
        try {
          final matchDate = DateTime.parse(match.date);
          final dateKey = _formatDateHeader(matchDate);
          if (groupedMatches[dateKey] == null) {
            groupedMatches[dateKey] = [];
            dateKeyToDate[dateKey] = matchDate;
          }
          groupedMatches[dateKey]!.add(match);
        } catch (e) {
          // If date parsing fails, put in "Unknown Date" group
          if (groupedMatches['Unknown Date'] == null) {
            groupedMatches['Unknown Date'] = [];
            dateKeyToDate['Unknown Date'] = DateTime.now()
                .subtract(const Duration(days: 1000)); // Put at beginning
          }
          groupedMatches['Unknown Date']!.add(match);
        }
      } else {
        // If no date, put in "Unknown Date" group
        if (groupedMatches['Unknown Date'] == null) {
          groupedMatches['Unknown Date'] = [];
          dateKeyToDate['Unknown Date'] = DateTime.now()
              .subtract(const Duration(days: 1000)); // Put at beginning
        }
        groupedMatches['Unknown Date']!.add(match);
      }
    }

    // Sort the date keys chronologically
    final sortedDateKeys = groupedMatches.keys.toList()
      ..sort((a, b) {
        final dateA = dateKeyToDate[a] ?? DateTime.now();
        final dateB = dateKeyToDate[b] ?? DateTime.now();
        return dateA.compareTo(dateB);
      });

    return ListView.builder(
      padding: const EdgeInsets.all(16.0),
      itemCount: sortedDateKeys.length,
      itemBuilder: (context, index) {
        final dateKey = sortedDateKeys[index];
        final dayMatches = groupedMatches[dateKey]!;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Day header
            Padding(
              padding: const EdgeInsets.only(left: 8.0, top: 16.0, bottom: 8.0),
              child: Text(
                dateKey,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            // Matches for this day
            ...dayMatches.map((match) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: MatchCard(
                  time: match.startTime.isNotEmpty && match.endTime.isNotEmpty
                      ? _formatTime(match.startTime, match.endTime)
                      : 'Time not set',
                  location: match.title,
                  players:
                      '${match.players?.length ?? 0}/${match.teamSize * 2}',
                  status: match.status,
                  isCreator: match.creatorUserId == currentUserId,
                  onTap: () {
                    // Pass the complete match object instead of just loading details
                    GoRouter.of(context).push(
                      '${AppRouter.kMatchDetailsView}/${match.id}',
                      extra: {
                        'match_id': match.id,
                        'is_creator': match.creatorUserId == currentUserId,
                        'match_data': match, // Pass the complete match object
                      },
                    );
                  },
                ),
              );
            }).toList(),
          ],
        );
      },
    );
  }

  String _formatDateHeader(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final tomorrow = today.add(const Duration(days: 1));
    final yesterday = today.subtract(const Duration(days: 1));
    final matchDate = DateTime(date.year, date.month, date.day);

    if (matchDate == today) {
      return 'Today';
    } else if (matchDate == tomorrow) {
      return 'Tomorrow';
    } else if (matchDate == yesterday) {
      return 'Yesterday';
    } else {
      // Show day of week and date for other dates
      return DateFormat('EEEE, MMM d').format(date);
    }
  }

  String _formatTime(String startTime, String endTime) {
    try {
      // Parse time strings (assuming format "HH:mm:ss" or "HH:mm")
      final startParts = startTime.split(':');
      final endParts = endTime.split(':');

      final startHour = int.parse(startParts[0]);
      final startMinute = int.parse(startParts[1]);
      final endHour = int.parse(endParts[0]);
      final endMinute = int.parse(endParts[1]);

      // Create DateTime objects for formatting
      final now = DateTime.now();
      final startDateTime =
          DateTime(now.year, now.month, now.day, startHour, startMinute);
      final endDateTime =
          DateTime(now.year, now.month, now.day, endHour, endMinute);

      final formattedStartTime = DateFormat('h:mm a').format(startDateTime);
      final formattedEndTime = DateFormat('h:mm a').format(endDateTime);

      return '$formattedStartTime - $formattedEndTime';
    } catch (e) {
      // If parsing fails, return original format
      return '${startTime.substring(0, 5)} - ${endTime.substring(0, 5)}';
    }
  }
}
