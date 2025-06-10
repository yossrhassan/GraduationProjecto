// 5. IMPLEMENTATION EXAMPLE IN MATCHES VIEW
// player_matching/presentation/views/matches_view.dart (with Cubit)
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:graduation_project/core/utils/app_router.dart';
import 'package:graduation_project/features/player_matching/data/models/match_model.dart';
import 'package:graduation_project/features/player_matching/data/models/sport_model.dart';
import 'package:graduation_project/features/player_matching/presentation/manager/match_cubit/match_cubit.dart';
import 'package:graduation_project/features/player_matching/presentation/manager/match_cubit/match_state.dart';
import 'package:graduation_project/features/player_matching/presentation/views/widgets/match_card.dart';
import 'package:graduation_project/features/player_matching/presentation/views/widgets/sport_filter_dropdown.dart';
import 'package:graduation_project/core/utils/auth_manager.dart';
import 'package:intl/intl.dart';

class MatchesView extends StatefulWidget {
  final int? initialTab;
  const MatchesView({Key? key, this.initialTab}) : super(key: key);

  @override
  State<MatchesView> createState() => _MatchesViewState();
}

class _MatchesViewState extends State<MatchesView>
    with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  late TabController _tabController;

  // Cache for storing previous data to show during loading
  List<MatchModel>? _cachedAvailableMatches;
  List<MatchModel>? _cachedMyMatches;

  // Sport filtering
  List<SportModel> _sports = [];
  SportModel? _selectedSport;
  bool _sportsLoading = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _tabController = TabController(
      length: 2,
      vsync: this,
      initialIndex: widget.initialTab ?? 0,
    );

    // Load sports first
    _loadSports();

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
          // Load available matches silently in background
          _loadAvailableMatches();
        } else {
          // Load my matches silently in background
          _loadMyMatches();
        }
      }
    });
  }

  void _loadSports() {
    setState(() {
      _sportsLoading = true;
    });
    context.read<MatchesCubit>().getSports();
  }

  void _loadAvailableMatches() {
    print(
        '🔍 Loading available matches with sport filter: ${_selectedSport?.name ?? "All Sports"} (ID: ${_selectedSport?.id})');
    context.read<MatchesCubit>().getAvailableMatches(
          sportTypeId: _selectedSport?.id,
        );
  }

  void _loadMyMatches() {
    context.read<MatchesCubit>().getMyMatches();
  }

  void _refreshCurrentTab() {
    if (_tabController.index == 0) {
      _loadAvailableMatches();
    } else {
      _loadMyMatches();
    }
  }

  void _onSportFilterChanged(SportModel? sport) {
    setState(() {
      _selectedSport = sport;
    });

    // Only filter available matches, not "My Matches"
    if (_tabController.index == 0) {
      // Clear cached data to force showing loading state and then new data
      setState(() {
        _cachedAvailableMatches = null;
      });
      _loadAvailableMatches();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _tabController.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      // Refresh matches when app comes back to foreground
      _refreshCurrentTab();
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Refresh current tab silently when returning to this page (e.g., from match details)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _refreshCurrentTab();
      }
    });
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
      body: BlocListener<MatchesCubit, MatchesState>(
        listener: (context, state) {
          if (state is SportsLoaded) {
            setState(() {
              _sports = state.sports;
              _sportsLoading = false;
            });
          }
        },
        child: Column(
          children: [
            // Sport filter dropdown - only show on Available Matches tab
            AnimatedBuilder(
              animation: _tabController,
              builder: (context, child) {
                return _tabController.index == 0
                    ? SportFilterDropdown(
                        sports: _sports,
                        selectedSport: _selectedSport,
                        onSportChanged: _onSportFilterChanged,
                        isLoading: _sportsLoading,
                      )
                    : const SizedBox.shrink();
              },
            ),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  // Available Matches Tab with BlocBuilder
                  BlocBuilder<MatchesCubit, MatchesState>(
                    builder: (context, state) {
                      print(
                          '🔍 Available matches BlocBuilder state: ${state.runtimeType}');

                      if (state is AvailableMatchesLoaded) {
                        print(
                            '🔍 Received ${state.matches.length} available matches');
                        // Update cache and show data
                        _cachedAvailableMatches = state.matches;
                        return _buildMatchesList(state.matches, false);
                      } else if (state is MatchesLoading) {
                        // Show loading during filtering
                        print('🔍 Showing loading indicator for matches');
                        return const Center(child: CircularProgressIndicator());
                      } else if (_cachedAvailableMatches != null) {
                        // Show cached data only if not currently loading
                        print(
                            '🔍 Showing cached data: ${_cachedAvailableMatches!.length} matches');
                        return _buildMatchesList(
                            _cachedAvailableMatches!, false);
                      } else if (state is MatchesError) {
                        return Center(child: Text('Error: ${state.message}'));
                      } else {
                        // Initial loading state
                        return const Center(child: CircularProgressIndicator());
                      }
                    },
                  ),
                  // My Matches Tab with BlocBuilder
                  BlocBuilder<MatchesCubit, MatchesState>(
                    builder: (context, state) {
                      if (state is MyMatchesLoaded) {
                        // Update cache and show data
                        _cachedMyMatches = state.matches;
                        return _buildMatchesList(state.matches, true);
                      } else if (_cachedMyMatches != null) {
                        // Always show cached data if available (no loading indicators during tab switches)
                        return _buildMatchesList(_cachedMyMatches!, true);
                      } else if (state is MatchesError) {
                        return Center(
                            child: Text('Error: ${state.message}',
                                style: TextStyle(color: Colors.white)));
                      } else {
                        // Only show loading spinner on initial load when no cache exists
                        return const Center(child: CircularProgressIndicator());
                      }
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
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

    // Helper function to check if user is in a match (either as creator or player)
    bool isUserInMatch(MatchModel match) {
      // Check if user is the creator
      if (match.creatorUserId == currentUserId) {
        print('Match ${match.id}: User is creator');
        return true;
      }

      // Check if user is in the players list
      if (match.players != null) {
        bool isInPlayers =
            match.players!.any((player) => player.userId == currentUserId);
        if (isInPlayers) {
          print('Match ${match.id}: User found in players list');
        } else {
          print(
              'Match ${match.id}: User NOT in players list. Players: ${match.players!.map((p) => 'ID:${p.userId}').join(', ')}');
        }
        return isInPlayers;
      }

      print(
          'Match ${match.id}: User not in match (not creator, no players list)');
      return false;
    }

    // Filter matches based on the tab
    final filteredMatches = isMyMatches
        ? matches.where((m) => isUserInMatch(m)).toList()
        : matches.where((m) => !isUserInMatch(m)).toList();

    print('Current User ID: $currentUserId');
    print('Tab: ${isMyMatches ? "My Matches" : "Available Matches"}');
    print(
        'Total matches: ${matches.length}, Filtered: ${filteredMatches.length}');

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
              // Determine user's relationship to the match
              bool isCreator = match.creatorUserId == currentUserId;
              bool hasJoined = false;

              if (!isCreator) {
                // Check if user is in players list
                if (match.players != null) {
                  hasJoined = match.players!
                      .any((player) => player.userId == currentUserId);
                }
              }

              String displayStatus;
              if (isCreator) {
                displayStatus = 'Created';
              } else if (hasJoined) {
                displayStatus = 'Joined';
              } else {
                displayStatus = match.status;
              }

              return Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: MatchCard(
                  time: match.startTime.isNotEmpty && match.endTime.isNotEmpty
                      ? _formatTime(match.startTime, match.endTime)
                      : 'Time not set',
                  location: match.title,
                  players:
                      '${(match.players?.length ?? 0) < 1 ? 1 : match.players!.length}/${match.teamSize * 2}',
                  status: displayStatus,
                  isCreator: isCreator,
                  onTap: () {
                    // Pass the complete match object instead of just loading details
                    GoRouter.of(context).push(
                      '${AppRouter.kMatchDetailsView}/${match.id}',
                      extra: {
                        'match_id': match.id,
                        'is_creator': isCreator,
                        'match_data': match, // Pass the complete match object
                        'from_my_matches':
                            isMyMatches, // Add this to know the source
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
