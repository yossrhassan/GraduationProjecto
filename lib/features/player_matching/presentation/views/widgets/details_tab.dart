import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:graduation_project/features/player_matching/data/models/match_model.dart';
import 'package:graduation_project/features/player_matching/data/models/player_model.dart';
import 'package:graduation_project/features/player_matching/presentation/manager/match_cubit/match_cubit.dart';
import 'package:graduation_project/features/player_matching/presentation/manager/match_cubit/match_state.dart';
import 'package:graduation_project/features/player_matching/presentation/views/widgets/match_box_details.dart';
import 'package:graduation_project/features/player_matching/presentation/views/widgets/player_avatar.dart';
import 'package:graduation_project/core/utils/auth_manager.dart';

class DetailsTab extends StatefulWidget {
// Pass from parent if user created this match

  const DetailsTab({
    super.key,
    this.isCreator = false,
    this.matchData,
  });
// Pass from parent if user created this match

  final bool isCreator;
  final MatchModel? matchData;

  @override
  State<DetailsTab> createState() => _DetailsTabState();
}

class _DetailsTabState extends State<DetailsTab> {
  String? userJoinedTeam; // Track which team the current user joined
  bool isJoining = false; // Track if join request is in progress

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
    if (widget.matchData != null) {
      final matchId = widget.matchData!.id.toString();
      final joinedTeam = AuthManager.getJoinedTeam(matchId);
      if (joinedTeam != null) {
        userJoinedTeam = joinedTeam;
        print(
            '🔄 Retrieved joined team from local storage: $joinedTeam for match $matchId');
      }
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // Reset joining state when dependencies change (e.g., navigating to a different match)
    if (widget.matchData != null) {
      final hasJoinedLocally =
          AuthManager.hasJoinedMatch(widget.matchData!.id.toString());
      if (hasJoinedLocally && isJoining) {
        setState(() {
          isJoining = false;
        });
      }
    }
  }

  void _handleJoinTeam(String team) {
    if (widget.matchData != null && !isJoining) {
      // Check if user has already joined locally before attempting
      final hasJoinedLocally =
          AuthManager.hasJoinedMatch(widget.matchData!.id.toString());
      if (hasJoinedLocally || userJoinedTeam != null) {
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
              responseAt: DateTime.now(),
              checkedInAt: DateTime.now(),
            );

            // Update the match data with the new player
            final updatedPlayers =
                List<PlayerModel>.from(widget.matchData!.players ?? []);
            updatedPlayers.add(newPlayer);

            final updatedMatch = MatchModel(
              id: widget.matchData!.id,
              creatorUserId: widget.matchData!.creatorUserId,
              bookingId: widget.matchData!.bookingId,
              sportType: widget.matchData!.sportType,
              teamSize: widget.matchData!.teamSize,
              title: widget.matchData!.title,
              description: widget.matchData!.description,
              minSkillLevel: widget.matchData!.minSkillLevel,
              maxSkillLevel: widget.matchData!.maxSkillLevel,
              isPrivate: widget.matchData!.isPrivate,
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
            cubit.getAvailableMatches();
            cubit.getMyMatches();

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

        // Always prioritize widget.matchData if available, then fall back to state
        MatchModel? currentMatch;

        if (widget.matchData != null) {
          currentMatch = widget.matchData!;
          print(
              '🎯 Using widget match data: ID=${currentMatch.id}, Players count: ${currentMatch.players?.length ?? 0}');
        } else if (state is MatchDetailsLoaded) {
          currentMatch = state.match;
          print(
              '🎯 Using state match data: ID=${currentMatch.id}, Players count: ${currentMatch.players?.length ?? 0}');
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

          // Also check local joined tracking
          final hasJoinedLocally =
              AuthManager.hasJoinedMatch(currentMatch.id.toString());

          // More comprehensive check for hiding join buttons
          final shouldHideJoinButtons = widget.isCreator ||
              userJoinedTeam != null ||
              hasJoinedLocally ||
              currentUserTeam != null ||
              isJoining; // Also hide during joining process

          print('🔍 DEBUGGING JOIN BUTTONS:');
          print('  - isCreator: ${widget.isCreator}');
          print('  - userJoinedTeam: $userJoinedTeam');
          print('  - hasJoinedLocally: $hasJoinedLocally');
          print('  - currentUserTeam: $currentUserTeam');
          print('  - isJoining: $isJoining');
          print('  - shouldHideJoinButtons: $shouldHideJoinButtons');

          return CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: MatchBoxDetails(match: currentMatch),
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

        // Get all players for this team
        final teamPlayers = players.where((p) => p.team == team).toList();

        // Special handling for Team A position 0 (Captain)
        if (team == 'A' && index == 0) {
          isCaptain = true;

          // Find the match creator (captain) - they should always be at position 0 in Team A
          final captainPlayer = teamPlayers.firstWhere(
            (p) => p.userId == widget.matchData?.creatorUserId,
            orElse: () => PlayerModel(
              id: 0,
              userId: widget.matchData?.creatorUserId ?? 0,
              userName: widget.isCreator ? 'You' : 'Captain',
              status: 'CheckedIn',
              team: 'A',
              invitedAt: DateTime.now(),
              responseAt: DateTime.now(),
              checkedInAt: DateTime.now(),
            ),
          );

          player = captainPlayer;
          isCurrentUser = captainPlayer.userId == currentUserId;
          playerName = isCurrentUser
              ? 'You'
              : (captainPlayer.userName.isNotEmpty
                  ? captainPlayer.userName
                  : 'Captain');
        } else {
          // For other positions, get non-captain players in order
          final nonCaptainPlayers = teamPlayers
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
            final hasJoinedLocally = AuthManager.hasJoinedMatch(
                widget.matchData?.id.toString() ?? '');
            final userJoinedThisTeam = userJoinedTeam == team;

            if (hasJoinedLocally &&
                userJoinedThisTeam &&
                adjustedIndex == nonCaptainPlayers.length) {
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
                responseAt: DateTime.now(),
                checkedInAt: DateTime.now(),
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
          ),
        );
      },
    );
  }
}
