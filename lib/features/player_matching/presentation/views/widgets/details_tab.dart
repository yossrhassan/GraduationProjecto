import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:graduation_project/features/player_matching/data/models/match_model.dart';
import 'package:graduation_project/features/player_matching/presentation/manager/match_cubit/match_cubit.dart';
import 'package:graduation_project/features/player_matching/presentation/manager/match_cubit/match_state.dart';
import 'package:graduation_project/features/player_matching/presentation/views/widgets/match_box_details.dart';
import 'package:graduation_project/features/player_matching/presentation/views/widgets/player_avatar.dart';

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
  }

  void _handleJoinTeam(String team) {
    if (widget.matchData != null) {
      context
          .read<MatchesCubit>()
          .joinTeam(widget.matchData!.id.toString(), team);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MatchesCubit, MatchesState>(
      builder: (context, state) {
        if (state is MatchDetailsLoaded) {
          final match = state.match;
          // Use the match data to populate the UI
          return CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: MatchBoxDetails(match: match),
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
                            if (!widget
                                .isCreator) // Only show join button if not the creator
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 4.0),
                                child: ElevatedButton(
                                  onPressed: () => _handleJoinTeam('A'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.white,
                                    minimumSize:
                                        const Size(double.infinity, 32),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                  ),
                                  child: const Text(
                                    'Join Team A',
                                    style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            const SizedBox(height: 4),
                            // Scrollable list of players
                            ListView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: teamAPlayers.length,
                              padding: EdgeInsets.zero,
                              itemBuilder: (context, index) {
                                final player = teamAPlayers[index];
                                final bool isCurrentUser =
                                    player == 'current_user';
                                final bool isCaptain = index == captainPosition;

                                // If there's no player in this slot, show empty avatar
                                if (player == null) {
                                  return const Padding(
                                    padding:
                                        EdgeInsets.symmetric(vertical: 4.0),
                                    child: PlayerAvatar(
                                        isUser: false, isCaptain: false),
                                  );
                                }

                                // Show the player avatar with appropriate label
                                return Padding(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 4.0),
                                  child: PlayerAvatar(
                                    isUser: isCurrentUser && !isCaptain,
                                    isCaptain: isCaptain,
                                  ),
                                );
                              },
                            ),
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
                            if (!widget
                                .isCreator) // Only show join button if not the creator
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 4.0),
                                child: ElevatedButton(
                                  onPressed: () => _handleJoinTeam('B'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.white,
                                    minimumSize:
                                        const Size(double.infinity, 32),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                  ),
                                  child: const Text(
                                    'Join Team B',
                                    style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            const SizedBox(height: 4),
                            ListView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: teamBPlayers.length,
                              padding: EdgeInsets.zero,
                              itemBuilder: (context, index) {
                                final player = teamBPlayers[index];
                                final bool isCurrentUser =
                                    player == 'current_user';
                                final bool isCaptain =
                                    false; // Team B never has the captain

                                // If there's no player in this slot, show empty avatar
                                if (player == null) {
                                  return const Padding(
                                    padding:
                                        EdgeInsets.symmetric(vertical: 4.0),
                                    child: PlayerAvatar(
                                        isUser: false, isCaptain: false),
                                  );
                                }

                                // Show the player avatar with appropriate label
                                return Padding(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 4.0),
                                  child: PlayerAvatar(
                                    isUser: isCurrentUser && !isCaptain,
                                    isCaptain: isCaptain,
                                  ),
                                );
                              },
                            ),
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
          return const Center(child: CircularProgressIndicator());
        }
      },
    );
  }
}
