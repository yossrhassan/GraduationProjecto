import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:graduation_project/features/player_matching/data/models/match_model.dart';
import 'package:graduation_project/features/player_matching/data/models/player_model.dart';
import 'package:graduation_project/features/player_matching/presentation/manager/match_cubit/match_cubit.dart';
import 'package:graduation_project/features/player_matching/presentation/manager/match_cubit/match_state.dart';
import 'package:graduation_project/features/player_matching/presentation/views/widgets/match_box_details.dart';
import 'package:graduation_project/features/player_matching/presentation/views/widgets/player_avatar.dart';
import 'package:graduation_project/features/player_matching/presentation/views/widgets/player_profile_dialog.dart';
import 'package:graduation_project/features/player_matching/presentation/views/widgets/invite_friends_dialog.dart';
import 'package:graduation_project/core/utils/auth_manager.dart';

class MatchDetailsBody extends StatefulWidget {
// Pass from parent if user created this match

  const MatchDetailsBody({
    super.key,
    this.isCreator = false,
    this.matchData,
  });
// Pass from parent if user created this match

  final bool isCreator;
  final MatchModel? matchData;

  @override
  State<MatchDetailsBody> createState() => _MatchDetailsBodyState();
}

class _MatchDetailsBodyState extends State<MatchDetailsBody> {
  String? userJoinedTeam; // Track which team the current user joined
  bool isJoining = false; // Track if join request is in progress
  Set<int> kickedPlayerIds = {}; // Track kicked players for optimistic UI

  // Track who created the match (the captain)
  final String captainTeam = 'A'; // Captain is always initially in team A
  final int captainPosition =
      0; // Position of the captain in their team (usually 0)

  // Mock data for players in each team - will be replaced with API data
  final List<String?> teamAPlayers = List.generate(10, (index) => null);
  final List<String?> teamBPlayers = List.generate(10, (index) => null);

  @override
  void initState() {
    super.initState();

    // If user is the match creator, automatically place them as captain
    if (widget.isCreator) {
      teamAPlayers[captainPosition] = 'current_user';
    } else {
      // If not the creator, ensure there's a captain in team A
      teamAPlayers[captainPosition] = 'captain';
    }

    // Check if user has already joined this match and retrieve team info
    // TODO: Implement joined team tracking when AuthManager methods are available
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // Reset joining state when dependencies change (e.g., navigating to a different match)
    if (isJoining) {
      setState(() {
        isJoining = false;
      });
    }
  }

  void _handleJoinTeam(String team) {
    if (widget.matchData != null && !isJoining) {
      // Check if user has already joined before attempting
      if (userJoinedTeam != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('You have already joined this match!')),
        );
        return;
      }

      setState(() {
        isJoining = true;
      });

      // Use the repository directly to avoid state conflicts
      final cubit = context.read<MatchesCubit>();
      final repository = cubit.matchesRepository;

      repository.joinTeam(widget.matchData!.id.toString(), team).then((result) {
        result.fold(
          (failure) {
            setState(() {
              isJoining = false;
            });
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                  content: Text('Failed to join team: ${failure.errMessage}')),
            );
          },
          (success) {
            // Update local state immediately without backend refresh
            setState(() {
              userJoinedTeam = team;
              isJoining = false;
            });

            // Create a new PlayerModel for the current user
            final currentUserId = AuthManager.userId;
            final newPlayer = PlayerModel(
              id: currentUserId ?? 0,
              userId: currentUserId ?? 0,
              userName:
                  'You', // Will be replaced with actual name from profile later
              status: 'CheckedIn',
              team: team,
              invitedAt: DateTime.now(),
              // responseAt: DateTime.now(),
              // checkedInAt: DateTime.now(),
            );

            // Update the match data with the new player
            final updatedPlayers =
                List<PlayerModel>.from(widget.matchData!.players ?? []);
            updatedPlayers.add(newPlayer);

            final updatedMatch = MatchModel(
              id: widget.matchData!.id,
              creatorUserId: widget.matchData!.creatorUserId,
              creatorUserName: widget.matchData!.creatorUserName,
              bookingId: widget.matchData!.bookingId,
              sportName: widget.matchData!.sportName,
              teamSize: widget.matchData!.teamSize,
              title: widget.matchData!.title,
              description: widget.matchData!.description,
              minSkillLevel: widget.matchData!.minSkillLevel,
              maxSkillLevel: widget.matchData!.maxSkillLevel,
              status: widget.matchData!.status,
              createdAt: widget.matchData!.createdAt,
              completedAt: widget.matchData!.completedAt,
              players: updatedPlayers,
              date: widget.matchData!.date,
              startTime: widget.matchData!.startTime,
              endTime: widget.matchData!.endTime,
            );

            // Emit the updated match without going through loading state
            cubit.emit(MatchDetailsLoaded(updatedMatch));

            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Successfully joined Team $team!')),
            );

            // Refresh the matches lists in background to update filtering
            print(
                '🔍 DETAILS_TAB: Refreshing match lists after successful join');
            cubit.getAvailableMatches();
            cubit.getMyMatches();

            // Just stay on the current page - the match lists will refresh automatically

            print(
                'User ${AuthManager.userId} joined team $team in match ${widget.matchData!.id}');
          },
        );
      }).catchError((error) {
        // Handle any unexpected errors
        setState(() {
          isJoining = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Unexpected error: $error')),
        );
        print('Unexpected error in join team: $error');
      });
    }
  }

  void _leaveMatch() {
    if (widget.matchData != null) {
      final cubit = context.read<MatchesCubit>();
      cubit.leaveMatch(widget.matchData!.id.toString()).then((_) {
        // Show success message and navigate back
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Successfully left the match')),
        );
        Navigator.of(context).pop(); // Go back to matches list
      }).catchError((error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to leave match: $error')),
        );
      });
    }
  }

  Future<void> _kickPlayerOptimistic(int playerId) async {
    if (widget.matchData == null) return;

    // Immediately add to kicked players set for optimistic UI
    setState(() {
      kickedPlayerIds.add(playerId);
    });

    try {
      final cubit = context.read<MatchesCubit>();
      await cubit.kickPlayer(widget.matchData!.id.toString(), playerId);

      // Success - the player stays kicked
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white),
                SizedBox(width: 8),
                Text('Player kicked successfully'),
              ],
            ),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      // Error - revert the optimistic update
      if (mounted) {
        setState(() {
          kickedPlayerIds.remove(playerId);
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error, color: Colors.white),
                const SizedBox(width: 8),
                Expanded(child: Text('Error: $e')),
              ],
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _cancelMatch() async {
    if (widget.matchData != null) {
      final cubit = context.read<MatchesCubit>();

      try {
        // Wait for the cancel operation to complete
        await cubit.cancelMatch(widget.matchData!.id.toString());

        // Check if the widget is still mounted before showing snackbar
        if (mounted) {
          // Show success message and navigate back
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Match canceled successfully')),
          );
          Navigator.of(context).pop(); // Go back to matches list
        }
      } catch (error) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to cancel match: $error')),
          );
        }
      }
    }
  }

  // Helper method to organize players by team
  Map<String, List<PlayerModel>> _organizePlayersByTeam(
      List<PlayerModel>? players) {
    final Map<String, List<PlayerModel>> organizedPlayers = {
      'A': [],
      'B': [],
    };

    if (players != null) {
      for (var player in players) {
        if (player.team == 'A') {
          organizedPlayers['A']!.add(player);
        } else if (player.team == 'B') {
          organizedPlayers['B']!.add(player);
        }
      }
    }

    return organizedPlayers;
  }

  // Helper method to check if current user is already in a team
  String? _getCurrentUserTeam(List<PlayerModel>? players) {
    if (players == null) return null;

    final currentUserId = AuthManager.userId;
    if (currentUserId == null) return null;

    for (var player in players) {
      if (player.userId == currentUserId) {
        return player.team;
      }
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MatchesCubit, MatchesState>(
      builder: (context, state) {
        print('🔄 DetailsTab build - State: ${state.runtimeType}');

        // Prioritize state data (more up-to-date) over widget.matchData
        MatchModel? currentMatch;

        // Check for updated match data in various state types
        if (state is MatchDetailsLoaded) {
          currentMatch = state.match;
          print(
              '🎯 Using MatchDetailsLoaded state data: ID=${currentMatch.id}, Players count: ${currentMatch.players?.length ?? 0}');
        } else if (state is MyMatchesLoaded && widget.matchData != null) {
          // Find the updated match in MyMatches state
          try {
            final updatedMatch = state.matches.firstWhere(
              (match) => match.id == widget.matchData!.id,
            );
            currentMatch = updatedMatch;
            print(
                '🎯 Using MyMatchesLoaded state data: ID=${currentMatch.id}, Players count: ${currentMatch.players?.length ?? 0}');
          } catch (e) {
            // Match not found in state, use widget data
            currentMatch = widget.matchData!;
            print(
                '🎯 Match not found in MyMatchesLoaded, using widget data: ID=${currentMatch.id}, Players count: ${currentMatch.players?.length ?? 0}');
          }
        } else if (state is AvailableMatchesLoaded &&
            widget.matchData != null) {
          // Find the updated match in AvailableMatches state
          try {
            final updatedMatch = state.matches.firstWhere(
              (match) => match.id == widget.matchData!.id,
            );
            currentMatch = updatedMatch;
            print(
                '🎯 Using AvailableMatchesLoaded state data: ID=${currentMatch.id}, Players count: ${currentMatch.players?.length ?? 0}');
          } catch (e) {
            // Match not found in state, use widget data
            currentMatch = widget.matchData!;
            print(
                '🎯 Match not found in AvailableMatchesLoaded, using widget data: ID=${currentMatch.id}, Players count: ${currentMatch.players?.length ?? 0}');
          }
        } else if (widget.matchData != null) {
          currentMatch = widget.matchData!;
          print(
              '🎯 Using widget match data: ID=${currentMatch.id}, Players count: ${currentMatch.players?.length ?? 0}');
        }

        if (currentMatch != null) {
          final organizedPlayers = _organizePlayersByTeam(currentMatch.players);
          final currentUserTeam = _getCurrentUserTeam(currentMatch.players);

          // Debug organized players
          print(
              '👥 Team A players: ${organizedPlayers['A']?.map((p) => '${p.userName}(${p.userId})').join(', ')}');
          print(
              '👥 Team B players: ${organizedPlayers['B']?.map((p) => '${p.userName}(${p.userId})').join(', ')}');
          print('👤 Current user team: $currentUserTeam');
          print('👤 Current user ID: ${AuthManager.userId}');

          // Update userJoinedTeam if user is already in a team
          if (currentUserTeam != null && userJoinedTeam == null) {
            userJoinedTeam = currentUserTeam;
            print('🔄 Updated userJoinedTeam to: $userJoinedTeam');
          }

          // More comprehensive check for hiding join buttons
          final shouldHideJoinButtons = widget.isCreator ||
              userJoinedTeam != null ||
              currentUserTeam != null ||
              isJoining; // Also hide during joining process

          // Check if user has joined the match (for management interface)
          // Show management interface for both creators and users who have joined
          final userHasJoinedTeam =
              currentUserTeam != null || userJoinedTeam != null;
          final hasUserJoined = widget.isCreator || userHasJoinedTeam;

          print('🔍 DEBUGGING JOIN BUTTONS:');
          print('  - isCreator: ${widget.isCreator}');
          print('  - userJoinedTeam: $userJoinedTeam');
          print('  - currentUserTeam: $currentUserTeam');
          print('  - isJoining: $isJoining');
          print('  - shouldHideJoinButtons: $shouldHideJoinButtons');

          print('🔍 DEBUGGING MANAGEMENT INTERFACE:');
          print('  - widget.isCreator: ${widget.isCreator}');
          print('  - userJoinedTeam: $userJoinedTeam');
          print('  - currentUserTeam: $currentUserTeam');
          print('  - userHasJoinedTeam: $userHasJoinedTeam');
          print('  - hasUserJoined: $hasUserJoined');
          print('  - Should show management interface: $hasUserJoined');

          if (hasUserJoined) {
            print(
                '🎨 RENDERING MANAGEMENT INTERFACE - This should be visible!');
          }

          return CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: MatchBoxDetails(match: currentMatch),
                ),
              ),
              // Management Interface - Only show if user has joined
              if (hasUserJoined)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Container(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              // Invite Friends
                              Expanded(
                                child: Container(
                                  height: 70,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Material(
                                    color: Colors.transparent,
                                    child: InkWell(
                                      borderRadius: BorderRadius.circular(8),
                                      onTap: () {
                                        if (widget.matchData != null) {
                                          showDialog(
                                            context: context,
                                            builder: (context) =>
                                                InviteFriendsDialog(
                                              matchId: widget.matchData!.id
                                                  .toString(),
                                            ),
                                          );
                                        }
                                      },
                                      child: const Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Icon(Icons.people_outline,
                                              size: 32, color: Colors.black54),
                                          SizedBox(height: 8),
                                          Text(
                                            'INVITE FRIENDS',
                                            style: TextStyle(
                                              color: Colors.black87,
                                              fontSize: 12,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              // Share Match
                              Expanded(
                                child: Container(
                                  height: 70,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Material(
                                    color: Colors.transparent,
                                    child: InkWell(
                                      borderRadius: BorderRadius.circular(8),
                                      onTap: () {
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          const SnackBar(
                                              content: Text(
                                                  'Share Match feature coming soon!')),
                                        );
                                      },
                                      child: const Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Icon(Icons.share_outlined,
                                              size: 32, color: Colors.black54),
                                          SizedBox(height: 8),
                                          Text(
                                            'SHARE MATCH',
                                            style: TextStyle(
                                              color: Colors.black87,
                                              fontSize: 12,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          // Leave/Cancel Match
                          Container(
                            width: double.infinity,
                            height: 70,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Material(
                              color: Colors.transparent,
                              child: InkWell(
                                borderRadius: BorderRadius.circular(8),
                                onTap: () {
                                  final isCreator = widget.isCreator;
                                  showDialog(
                                    context: context,
                                    builder: (context) => AlertDialog(
                                      title: Text(isCreator
                                          ? 'Cancel Match'
                                          : 'Leave Match'),
                                      content: Text(isCreator
                                          ? 'Are you sure you want to cancel this match?'
                                          : 'Are you sure you want to leave this match?'),
                                      actions: [
                                        TextButton(
                                          onPressed: () =>
                                              Navigator.pop(context),
                                          child: const Text('Cancel'),
                                        ),
                                        TextButton(
                                          onPressed: () {
                                            Navigator.pop(context);
                                            if (isCreator) {
                                              // Call cancel match functionality
                                              _cancelMatch();
                                            } else {
                                              // Call leave match functionality
                                              _leaveMatch();
                                            }
                                          },
                                          child: Text(isCreator
                                              ? 'Cancel Match'
                                              : 'Leave'),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                        widget.isCreator
                                            ? Icons.cancel
                                            : Icons.exit_to_app,
                                        size: 32,
                                        color: Colors.black54),
                                    const SizedBox(height: 8),
                                    Text(
                                      widget.isCreator
                                          ? 'CANCEL MATCH'
                                          : 'LEAVE MATCH',
                                      style: const TextStyle(
                                        color: Colors.black87,
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Team A
                      Expanded(
                        child: Column(
                          children: [
                            const SizedBox(height: 16),
                            const Text(
                              'Team A',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            if (!shouldHideJoinButtons)
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 4.0),
                                child: ElevatedButton(
                                  onPressed: isJoining
                                      ? null
                                      : () => _handleJoinTeam('A'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.white,
                                    minimumSize:
                                        const Size(double.infinity, 32),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                  ),
                                  child: Text(
                                    isJoining ? 'Joining...' : 'Join Team A',
                                    style: const TextStyle(
                                      color: Colors.black,
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            const SizedBox(height: 4),
                            // Team A players
                            _buildTeamPlayers('A', organizedPlayers['A']!,
                                currentMatch.teamSize),
                          ],
                        ),
                      ),
                      // Team B
                      Expanded(
                        child: Column(
                          children: [
                            const SizedBox(height: 16),
                            const Text(
                              'Team B',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            if (!shouldHideJoinButtons)
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 4.0),
                                child: ElevatedButton(
                                  onPressed: isJoining
                                      ? null
                                      : () => _handleJoinTeam('B'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.white,
                                    minimumSize:
                                        const Size(double.infinity, 32),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                  ),
                                  child: Text(
                                    isJoining ? 'Joining...' : 'Join Team B',
                                    style: const TextStyle(
                                      color: Colors.black,
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            const SizedBox(height: 4),
                            // Team B players
                            _buildTeamPlayers('B', organizedPlayers['B']!,
                                currentMatch.teamSize),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        } else {
          print('❓ No match data available in both widget and state');
          return const Center(child: CircularProgressIndicator());
        }
      },
    );
  }

  Widget _buildTeamPlayers(
      String team, List<PlayerModel> players, int teamSize) {
    final currentUserId = AuthManager.userId;

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: teamSize,
      padding: EdgeInsets.zero,
      itemBuilder: (context, index) {
        PlayerModel? player;
        bool isCaptain = false;
        bool isCurrentUser = false;
        String? playerName;

        // Get all players for this team and remove duplicates based on userId
        // Also filter out kicked players for optimistic UI
        final teamPlayers = players
            .where((p) => p.team == team && !kickedPlayerIds.contains(p.userId))
            .toList();

        // Remove duplicate players based on userId
        final uniqueTeamPlayers = <PlayerModel>[];
        final seenUserIds = <int>{};

        for (final p in teamPlayers) {
          if (!seenUserIds.contains(p.userId)) {
            seenUserIds.add(p.userId);
            uniqueTeamPlayers.add(p);
          }
        }

        // Special handling for Team A position 0 (Captain)
        if (team == 'A' && index == 0) {
          isCaptain = true;

          // Find the match creator (captain) in the unique players list
          final captainIndex = uniqueTeamPlayers.indexWhere(
            (p) => p.userId == widget.matchData?.creatorUserId,
          );

          if (captainIndex != -1) {
            player = uniqueTeamPlayers[captainIndex];
            isCurrentUser = player.userId == currentUserId;
            playerName = isCurrentUser
                ? 'You'
                : (player.userName.isNotEmpty ? player.userName : 'Captain');
          } else {
            // Creator not found in players list, create a placeholder
            final creatorName = widget.matchData?.creatorUserName ?? 'Captain';
            player = PlayerModel(
              id: 0,
              userId: widget.matchData?.creatorUserId ?? 0,
              userName: widget.isCreator ? 'You' : creatorName,
              status: 'CheckedIn',
              team: 'A',
              invitedAt: DateTime.now(),
            );
            isCurrentUser = widget.matchData?.creatorUserId == currentUserId;
            playerName = isCurrentUser ? 'You' : creatorName;
          }
        } else {
          // For other positions, get non-captain players in order
          final nonCaptainPlayers = uniqueTeamPlayers
              .where((p) => p.userId != widget.matchData?.creatorUserId)
              .toList();

          final adjustedIndex = team == 'A' ? index - 1 : index;

          if (adjustedIndex >= 0 && adjustedIndex < nonCaptainPlayers.length) {
            player = nonCaptainPlayers[adjustedIndex];
            isCurrentUser = player.userId == currentUserId;
            playerName = isCurrentUser
                ? 'You'
                : (player.userName.isNotEmpty ? player.userName : 'Player');
          } else {
            // Check if the current user should be in this position (just joined but not in players list yet)
            final userJoinedThisTeam = userJoinedTeam == team;

            if (userJoinedThisTeam &&
                adjustedIndex == nonCaptainPlayers.length &&
                !seenUserIds.contains(currentUserId)) {
              // This is likely the current user who just joined
              isCurrentUser = true;
              playerName = 'You';
              // Create a temporary player model for display
              player = PlayerModel(
                id: 0,
                userId: currentUserId ?? 0,
                userName: 'You',
                status: 'CheckedIn',
                team: team,
                invitedAt: DateTime.now(),
              );
            }
          }
        }

        // Debug player information
        print('🎮 Team $team Position $index:');
        if (player != null) {
          print('  - Player: ${player.userName} (ID: ${player.userId})');
          print('  - isCurrentUser: $isCurrentUser');
          print('  - isCaptain: $isCaptain');
          print('  - playerName: $playerName');
        } else {
          print('  - Empty slot');
        }

        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 4.0),
          child: PlayerAvatar(
            isUser: isCurrentUser,
            isCaptain: isCaptain,
            playerName: playerName,
            onTap: player != null && !isCurrentUser
                ? () {
                    PlayerProfileDialog.show(
                      context,
                      player!,
                      isCaptain,
                      matchId: widget.matchData?.id.toString(),
                      isMatchCreator: widget.isCreator,
                      onKickPlayer:
                          widget.isCreator ? _kickPlayerOptimistic : null,
                    );
                  }
                : null,
          ),
        );
      },
    );
  }
}
