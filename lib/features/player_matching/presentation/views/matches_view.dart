import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:graduation_project/constants.dart';
import 'package:graduation_project/core/utils/app_router.dart';
import 'package:graduation_project/features/player_matching/data/models/match_model.dart';
import 'package:graduation_project/features/player_matching/data/models/player_model.dart';
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

  List<MatchModel>? _cachedAvailableMatches;
  List<MatchModel>? _cachedMyMatches;
  List<MatchModel>? _cachedCompletedMatches;

  int? _currentUserId;

  List<SportModel> _sports = [];
  SportModel? _selectedSport;
  bool _sportsLoading = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    _currentUserId = AuthManager.userId;

    _tabController = TabController(
      length: 3,
      vsync: this,
      initialIndex: widget.initialTab ?? 0,
    );

    _loadSports();

    if (widget.initialTab == 1) {
      _loadMyMatches();
    } else if (widget.initialTab == 2) {
      _loadCompletedMatches();
    } else {
      _loadAvailableMatches();
    }

    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        if (_tabController.index == 0) {
          _loadAvailableMatches();
        } else if (_tabController.index == 1) {
          _loadMyMatches();
        } else if (_tabController.index == 2) {
          _loadCompletedMatches();
        }
      }
    });
  }

  void _checkUserChange() {
    final currentUserId = AuthManager.userId;
    if (_currentUserId != currentUserId) {
      print(
          'User changed from $_currentUserId to $currentUserId - clearing cache');
      setState(() {
        _cachedAvailableMatches = null;
        _cachedMyMatches = null;
        _cachedCompletedMatches = null;
        _currentUserId = currentUserId;
      });
    }
  }

  void _loadSports() {
    _checkUserChange();
    setState(() {
      _sportsLoading = true;
    });
    context.read<MatchesCubit>().getSports();
  }

  void _loadAvailableMatches() {
    _checkUserChange();
    print(
        'Loading available matches with sport filter: ${_selectedSport?.name ?? "All Sports"} (ID: ${_selectedSport?.id})');
    context.read<MatchesCubit>().getAvailableMatches(
          sportTypeId: _selectedSport?.id,
        );
  }

  void _loadMyMatches() {
    _checkUserChange();
    print('VIEW: _loadMyMatches called');
    print('VIEW: Current user ID: ${AuthManager.userId}');
    print(
        'VIEW: Current auth token available: ${AuthManager.authToken != null}');
    context.read<MatchesCubit>().getMyMatches();
  }

  void _loadCompletedMatches() {
    _checkUserChange();
    context.read<MatchesCubit>().getCompletedMatches();
  }

  void _refreshCurrentTab() {
    _checkUserChange();
    if (_tabController.index == 0) {
      _loadAvailableMatches();
    } else if (_tabController.index == 1) {
      _loadMyMatches();
    } else if (_tabController.index == 2) {
      _loadCompletedMatches();
    }
  }

  void _onSportFilterChanged(SportModel? sport) {
    _checkUserChange();
    setState(() {
      _selectedSport = sport;
    });

    if (_tabController.index == 0) {
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
      _refreshCurrentTab();
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
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
            fontSize: 26,
            fontWeight: FontWeight.bold,
            color: kPrimaryColor,
          ),
        ),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          indicatorWeight: 3.0,
          tabs: const [
            Tab(text: 'AVAILABLE MATCHES'),
            Tab(text: 'MY MATCHES'),
            Tab(text: 'COMPLETED MATCHES'),
          ],
          labelColor: kPrimaryColor,
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
                  BlocBuilder<MatchesCubit, MatchesState>(
                    builder: (context, state) {
                      print(
                          'Available matches BlocBuilder state: ${state.runtimeType}');

                      if (state is AvailableMatchesLoaded) {
                        print(
                            'Received ${state.matches.length} available matches');
                        _cachedAvailableMatches = state.matches;
                        return _buildMatchesList(state.matches, false);
                      } else if (state is MatchesLoading) {
                        print('Showing loading indicator for matches');
                        return const Center(child: CircularProgressIndicator());
                      } else if (_cachedAvailableMatches != null) {
                        print(
                            'Showing cached data: ${_cachedAvailableMatches!.length} matches');
                        return _buildMatchesList(
                            _cachedAvailableMatches!, false);
                      } else if (state is MatchesError) {
                        return Center(child: Text('Error: ${state.message}'));
                      } else {
                        return const Center(child: CircularProgressIndicator());
                      }
                    },
                  ),
                  BlocBuilder<MatchesCubit, MatchesState>(
                    builder: (context, state) {
                      if (state is MyMatchesLoaded) {
                        _cachedMyMatches = state.matches;
                        return _buildMatchesList(state.matches, true);
                      } else if (_cachedMyMatches != null) {
                        return _buildMatchesList(_cachedMyMatches!, true);
                      } else if (state is MatchesError) {
                        return Center(
                            child: Text('Error: ${state.message}',
                                style: TextStyle(color: Colors.white)));
                      } else {
                        return const Center(child: CircularProgressIndicator());
                      }
                    },
                  ),
                  BlocBuilder<MatchesCubit, MatchesState>(
                    builder: (context, state) {
                      if (state is CompletedMatchesLoaded) {
                        _cachedCompletedMatches = state.matches;
                        return _buildMatchesList(state.matches, false);
                      } else if (_cachedCompletedMatches != null) {
                        return _buildMatchesList(
                            _cachedCompletedMatches!, false);
                      } else if (state is MatchesError) {
                        return Center(child: Text('Error: ${state.message}'));
                      } else {
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
          GoRouter.of(context).push(AppRouter.kMatchCreationView);
        },
        backgroundColor: Colors.white,
        child: const Icon(Icons.add, color: Colors.black),
      ),
    );
  }

  Widget _buildMatchesList(List<MatchModel> matches, bool isMyMatches) {
    final int? currentUserId = AuthManager.userId;

    bool isUserInMatch(MatchModel match) {
      if (match.creatorUserId == currentUserId) {
        print('Match ${match.id}: User is creator');
        return true;
      }

      if (match.players != null) {
        final uniquePlayers = <PlayerModel>[];
        final seenUserIds = <int>{};

        for (final player in match.players!) {
          if (!seenUserIds.contains(player.userId)) {
            seenUserIds.add(player.userId);
            uniquePlayers.add(player);
          }
        }

        bool isInPlayers =
            uniquePlayers.any((player) => player.userId == currentUserId);
        if (isInPlayers) {
          print('Match ${match.id}: User found in players list');
        } else {
          print(
              'Match ${match.id}: User NOT in players list. Players: ${uniquePlayers.map((p) => 'ID:${p.userId}').join(', ')}');
        }
        return isInPlayers;
      }

      print(
          'Match ${match.id}: User not in match (not creator, no players list)');
      return false;
    }

    print('FILTERING LOGIC:');
    print('Current User ID: $currentUserId');
    print('Tab: ${isMyMatches ? "My Matches" : "Available Matches"}');
    print('Total matches received: ${matches.length}');

    for (int i = 0; i < matches.length; i++) {
      final match = matches[i];
      print(
          'Match ${match.id}: Creator=${match.creatorUserId}, Players=${match.players?.length ?? 0}');
      if (match.players != null) {
        for (final player in match.players!) {
          print('  Player: ${player.userName} (ID: ${player.userId})');
        }
      }
    }

    List<MatchModel> filteredMatches;
    if (isMyMatches) {
      filteredMatches = matches;
      print(
          'MY MATCHES: Trusting backend, showing all ${matches.length} matches returned by /my-matches endpoint');
    } else {
      filteredMatches = matches
          .where(
              (m) => !isUserInMatch(m) || m.status.toLowerCase() == 'cancelled')
          .toList();
      print(
          'AVAILABLE MATCHES: Filtered out user matches (except cancelled), showing ${filteredMatches.length} of ${matches.length}');
    }

    print('Final filtered matches count: ${filteredMatches.length}');

    if (filteredMatches.isEmpty) {
      return Center(
        child: Text(
          isMyMatches ? 'You have no matches' : 'No matches available',
          style: const TextStyle(color: Colors.white),
        ),
      );
    }

    Map<String, List<MatchModel>> groupedMatches = {};
    Map<String, DateTime> dateKeyToDate = {};

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
          if (groupedMatches['Unknown Date'] == null) {
            groupedMatches['Unknown Date'] = [];
            dateKeyToDate['Unknown Date'] =
                DateTime.now().subtract(const Duration(days: 1000));
          }
          groupedMatches['Unknown Date']!.add(match);
        }
      } else {
        if (groupedMatches['Unknown Date'] == null) {
          groupedMatches['Unknown Date'] = [];
          dateKeyToDate['Unknown Date'] =
              DateTime.now().subtract(const Duration(days: 1000));
        }
        groupedMatches['Unknown Date']!.add(match);
      }
    }

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
            ...dayMatches.map((match) {
              bool isCreator = match.creatorUserId == currentUserId;
              bool hasJoined = false;

              if (!isCreator) {
                if (match.players != null) {
                  hasJoined = match.players!
                      .any((player) => player.userId == currentUserId);
                }
              }

              String displayStatus;
              if (match.status.toLowerCase() == 'cancelled') {
                displayStatus = 'Cancelled';
              } else if (isCreator) {
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
                      '${match.players?.length ?? 0}/${match.teamSize * 2}',
                  status: displayStatus,
                  isCreator: isCreator,
                  onTap: () {
                    GoRouter.of(context).push(
                      '${AppRouter.kMatchDetailsView}/${match.id}',
                      extra: {
                        'match_id': match.id,
                        'is_creator': isCreator,
                        'match_data': match,
                        'from_my_matches': isMyMatches,
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
      return DateFormat('EEEE, MMM d').format(date);
    }
  }

  String _formatTime(String startTime, String endTime) {
    try {
      final startParts = startTime.split(':');
      final endParts = endTime.split(':');

      final startHour = int.parse(startParts[0]);
      final startMinute = int.parse(startParts[1]);
      final endHour = int.parse(endParts[0]);
      final endMinute = int.parse(endParts[1]);

      final now = DateTime.now();
      final startDateTime =
          DateTime(now.year, now.month, now.day, startHour, startMinute);
      final endDateTime =
          DateTime(now.year, now.month, now.day, endHour, endMinute);

      final formattedStartTime = DateFormat('h:mm a').format(startDateTime);
      final formattedEndTime = DateFormat('h:mm a').format(endDateTime);

      return '$formattedStartTime - $formattedEndTime';
    } catch (e) {
      return '${startTime.substring(0, 5)} - ${endTime.substring(0, 5)}';
    }
  }
}
