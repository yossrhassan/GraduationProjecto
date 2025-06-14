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
  const MatchDetailsBody({
    super.key,
    this.isCreator = false,
    this.matchData,
  });

  final bool isCreator;
  final MatchModel? matchData;

  @override
  State<MatchDetailsBody> createState() => _MatchDetailsBodyState();
}

class _MatchDetailsBodyState extends State<MatchDetailsBody> {
  String? userJoinedTeam;
  bool isJoining = false;
  Set<int> kickedPlayerIds = {};

  final String captainTeam = 'A';
  final int captainPosition = 0;

  final List<String?> teamAPlayers = List.generate(10, (index) => null);
  final List<String?> teamBPlayers = List.generate(10, (index) => null);

  @override
  void initState() {
    super.initState();

    if (widget.isCreator) {
      teamAPlayers[captainPosition] = 'current_user';
    } else {
      teamAPlayers[captainPosition] = 'captain';
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (isJoining) {
      setState(() {
        isJoining = false;
      });
    }
  }

  void _handleJoinTeam(String team) {
    if (widget.matchData != null && !isJoining) {
      if (userJoinedTeam != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('You have already joined this match!')),
        );
        return;
      }

      setState(() {
        isJoining = true;
      });

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
            setState(() {
              userJoinedTeam = team;
              isJoining = false;
            });

            final currentUserId = AuthManager.userId;
            final newPlayer = PlayerModel(
              id: currentUserId ?? 0,
              userId: currentUserId ?? 0,
              userName: 'You',
              status: 'CheckedIn',
              team: team,
              invitedAt: DateTime.now(),
            );

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

            cubit.emit(MatchDetailsLoaded(updatedMatch));

            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Successfully joined Team $team!')),
            );

            cubit.getAvailableMatches();
            cubit.getMyMatches();
          },
        );
      }).catchError((error) {
        setState(() {
          isJoining = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Unexpected error: $error')),
        );
      });
    }
  }

  void _leaveMatch() {
    if (widget.matchData != null) {
      final cubit = context.read<MatchesCubit>();
      cubit.leaveMatch(widget.matchData!.id.toString()).then((_) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Successfully left the match')),
        );
        Navigator.of(context).pop();
      }).catchError((error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to leave match: $error')),
        );
      });
    }
  }

  Future<void> _kickPlayerOptimistic(int playerId) async {
    if (widget.matchData == null) return;

    setState(() {
      kickedPlayerIds.add(playerId);
    });

    try {
      final cubit = context.read<MatchesCubit>();
      await cubit.kickPlayer(widget.matchData!.id.toString(), playerId);

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
        await cubit.cancelMatch(widget.matchData!.id.toString());

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Match canceled successfully')),
          );
          Navigator.of(context).pop();
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
        print('DetailsTab build - State: ${state.runtimeType}');

        MatchModel? currentMatch;

        if (state is MatchDetailsLoaded) {
          currentMatch = state.match;
          print(
              '🎯 Using MatchDetailsLoaded state data: ID=${currentMatch.id}, Players count: ${currentMatch.players?.length ?? 0}');
        } else if (state is MyMatchesLoaded && widget.matchData != null) {
          try {
            final updatedMatch = state.matches.firstWhere(
              (match) => match.id == widget.matchData!.id,
            );
            currentMatch = updatedMatch;
            print(
                '🎯 Using MyMatchesLoaded state data: ID=${currentMatch.id}, Players count: ${currentMatch.players?.length ?? 0}');
          } catch (e) {
            currentMatch = widget.matchData!;
            print(
                '🎯 Match not found in MyMatchesLoaded, using widget data: ID=${currentMatch.id}, Players count: ${currentMatch.players?.length ?? 0}');
          }
        } else if (state is AvailableMatchesLoaded &&
            widget.matchData != null) {
          try {
            final updatedMatch = state.matches.firstWhere(
              (match) => match.id == widget.matchData!.id,
            );
            currentMatch = updatedMatch;
            print(
                '🎯 Using AvailableMatchesLoaded state data: ID=${currentMatch.id}, Players count: ${currentMatch.players?.length ?? 0}');
          } catch (e) {
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

          print(
              '👥 Team A players: ${organizedPlayers['A']?.map((p) => '${p.userName}(${p.userId})').join(', ')}');
          print(
              '👥 Team B players: ${organizedPlayers['B']?.map((p) => '${p.userName}(${p.userId})').join(', ')}');
          print('👤 Current user team: $currentUserTeam');
          print('👤 Current user ID: ${AuthManager.userId}');

          if (currentUserTeam != null && userJoinedTeam == null) {
            userJoinedTeam = currentUserTeam;
            print('Updated userJoinedTeam to: $userJoinedTeam');
          }

          final shouldHideJoinButtons = widget.isCreator ||
              userJoinedTeam != null ||
              currentUserTeam != null ||
              isJoining;

          final userHasJoinedTeam =
              currentUserTeam != null || userJoinedTeam != null;
          final hasUserJoined = widget.isCreator || userHasJoinedTeam;

          print('DEBUGGING JOIN BUTTONS:');
          print('  - isCreator: ${widget.isCreator}');
          print('  - userJoinedTeam: $userJoinedTeam');
          print('  - currentUserTeam: $currentUserTeam');
          print('  - isJoining: $isJoining');
          print('  - shouldHideJoinButtons: $shouldHideJoinButtons');

          print('DEBUGGING MANAGEMENT INTERFACE:');
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
              if (hasUserJoined)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Container(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: [
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
                                  if (widget.matchData != null) {
                                    showDialog(
                                      context: context,
                                      builder: (context) => InviteFriendsDialog(
                                        matchId:
                                            widget.matchData!.id.toString(),
                                      ),
                                    );
                                  }
                                },
                                child: const Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
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
                          const SizedBox(height: 8),
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
                                      content: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(isCreator
                                              ? 'Are you sure you want to cancel this match?'
                                              : 'Are you sure you want to leave this match?'),
                                          if (isCreator) ...[
                                            const SizedBox(height: 16),
                                            Container(
                                              padding: const EdgeInsets.all(12),
                                              decoration: BoxDecoration(
                                                color: Colors.orange.shade50,
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                                border: Border.all(
                                                  color: Colors.orange.shade200,
                                                  width: 1,
                                                ),
                                              ),
                                              child: Row(
                                                children: [
                                                  Icon(
                                                    Icons.warning_amber_rounded,
                                                    color:
                                                        Colors.orange.shade700,
                                                    size: 20,
                                                  ),
                                                  const SizedBox(width: 8),
                                                  Expanded(
                                                    child: Text(
                                                      'Note: If you cancel the match, you cannot create it again.',
                                                      style: TextStyle(
                                                        color: Colors
                                                            .orange.shade800,
                                                        fontSize: 13,
                                                        fontWeight:
                                                            FontWeight.w500,
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ],
                                      ),
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
                                              _cancelMatch();
                                            } else {
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
                                padding: const EdgeInsets.symmetric(
                                    vertical: 8.0, horizontal: 4.0),
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: Colors.transparent,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: Colors.green,
                                      width: 2,
                                    ),
                                  ),
                                  child: ElevatedButton(
                                    onPressed: isJoining
                                        ? null
                                        : () => _handleJoinTeam('A'),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.transparent,
                                      shadowColor: Colors.transparent,
                                      minimumSize:
                                          const Size(double.infinity, 44),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                    ),
                                    child: Text(
                                      isJoining ? 'Joining...' : 'Join Team A',
                                      style: const TextStyle(
                                        color: Colors.green,
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            const SizedBox(height: 4),
                            _buildTeamPlayers('A', organizedPlayers['A']!,
                                currentMatch.teamSize),
                          ],
                        ),
                      ),
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
                                padding: const EdgeInsets.symmetric(
                                    vertical: 8.0, horizontal: 4.0),
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: Colors.transparent,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: Colors.green,
                                      width: 2,
                                    ),
                                  ),
                                  child: ElevatedButton(
                                    onPressed: isJoining
                                        ? null
                                        : () => _handleJoinTeam('B'),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.transparent,
                                      shadowColor: Colors.transparent,
                                      minimumSize:
                                          const Size(double.infinity, 44),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                    ),
                                    child: Text(
                                      isJoining ? 'Joining...' : 'Join Team B',
                                      style: const TextStyle(
                                        color: Colors.green,
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            const SizedBox(height: 4),
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

        final teamPlayers = players
            .where((p) => p.team == team && !kickedPlayerIds.contains(p.userId))
            .toList();

        final uniqueTeamPlayers = <PlayerModel>[];
        final seenUserIds = <int>{};

        for (final p in teamPlayers) {
          if (!seenUserIds.contains(p.userId)) {
            seenUserIds.add(p.userId);
            uniqueTeamPlayers.add(p);
          }
        }

        if (team == 'A' && index == 0) {
          isCaptain = true;

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
            final userJoinedThisTeam = userJoinedTeam == team;

            if (userJoinedThisTeam &&
                adjustedIndex == nonCaptainPlayers.length &&
                !seenUserIds.contains(currentUserId)) {
              isCurrentUser = true;
              playerName = 'You';
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

        print('🎮 Team $team Position $index:');
        if (player != null) {
          print('  - Player: ${player.userName} (ID: ${player.userId})');
          print('  - Status: ${player.status}');
          print('  - Is Captain: $isCaptain');
          print('  - Is Current User: $isCurrentUser');
        } else {
          print('  - Empty position');
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
