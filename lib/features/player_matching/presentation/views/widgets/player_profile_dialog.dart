import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:graduation_project/features/player_matching/data/models/player_model.dart';
import 'package:graduation_project/constants.dart';
import 'package:graduation_project/core/utils/app_router.dart';
import 'package:graduation_project/core/utils/auth_manager.dart';
import 'package:graduation_project/core/utils/service_locator.dart';
import 'package:graduation_project/features/player_matching/presentation/manager/match_cubit/match_cubit.dart';
import 'package:go_router/go_router.dart';

class PlayerProfileDialog {
  static void show(
    BuildContext context,
    PlayerModel player,
    bool isCaptain, {
    String? matchId,
    bool isMatchCreator = false,
    Function(int)? onKickPlayer,
  }) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => PlayerProfileBottomSheet(
        player: player,
        isCaptain: isCaptain,
        matchId: matchId,
        isMatchCreator: isMatchCreator,
        onKickPlayer: onKickPlayer,
      ),
    );
  }
}

class PlayerProfileBottomSheet extends StatefulWidget {
  final PlayerModel player;
  final bool isCaptain;
  final String? matchId;
  final bool isMatchCreator;
  final Function(int)? onKickPlayer;

  const PlayerProfileBottomSheet({
    super.key,
    required this.player,
    required this.isCaptain,
    this.matchId,
    this.isMatchCreator = false,
    this.onKickPlayer,
  });

  @override
  State<PlayerProfileBottomSheet> createState() =>
      _PlayerProfileBottomSheetState();
}

class _PlayerProfileBottomSheetState extends State<PlayerProfileBottomSheet> {
  bool isKicking = false;

  Future<void> _kickPlayer() async {
    if (widget.onKickPlayer == null) return;

    // Show confirmation dialog
    final shouldKick = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: kBackGroundColor,
        title: const Text(
          'Kick Player',
          style: TextStyle(color: Colors.white),
        ),
        content: Text(
          'Are you sure you want to kick ${widget.player.userName.isNotEmpty ? widget.player.userName : 'this player'} from the match?',
          style: const TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child:
                const Text('Cancel', style: TextStyle(color: Colors.white70)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Kick Player'),
          ),
        ],
      ),
    );

    if (shouldKick != true) return;

    // Close the dialog immediately and let the parent handle the kick
    Navigator.of(context).pop();

    // Call the parent's kick method which handles optimistic UI
    widget.onKickPlayer!(widget.player.userId);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Handle indicator
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.white30,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 24),

          // Player Avatar
          Stack(
            children: [
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.green.shade700,
                  border: Border.all(color: Colors.white, width: 3),
                ),
                child: const Icon(
                  Icons.person,
                  size: 50,
                  color: Colors.white54,
                ),
              ),
              if (widget.isCaptain)
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: const BoxDecoration(
                      color: Colors.amber,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.star,
                      size: 20,
                      color: Colors.white,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),

          // Player Name
          Text(
            widget.player.userName.isNotEmpty
                ? widget.player.userName
                : 'Player',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),

          // Captain badge
          if (widget.isCaptain)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.amber,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text(
                'CAPTAIN',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

          const SizedBox(height: 24),

          // Player Details
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildDetailRow('Team', 'Team ${widget.player.team}'),
                const SizedBox(height: 12),
                _buildDetailRow('Joined', _formatDate(widget.player.invitedAt)),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Action Buttons
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () {
                Navigator.pop(context);
                GoRouter.of(context).push(
                  AppRouter.kPlayerProfileView,
                  extra: {
                    'player': widget.player,
                    'isCaptain': widget.isCaptain,
                  },
                );
              },
              icon: const Icon(Icons.person, color: Colors.white),
              label: const Text('View Profile'),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.white,
                side: const BorderSide(color: Colors.white),
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),

          // Kick Player Button (only for match creators)
          if (widget.isMatchCreator &&
              widget.onKickPlayer != null &&
              !widget.isCaptain)
            Column(
              children: [
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _kickPlayer,
                    icon: const Icon(Icons.person_remove, color: Colors.white),
                    label: const Text('Kick Player'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
              ],
            ),

          const SizedBox(height: 12),

          // Close button
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Close',
              style: TextStyle(color: Colors.white70),
            ),
          ),

          // Add some bottom padding for safe area
          SizedBox(height: MediaQuery.of(context).padding.bottom),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 80,
          child: Text(
            label,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 14,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays > 0) {
      return '${difference.inDays} day(s) ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hour(s) ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} minute(s) ago';
    } else {
      return 'Just now';
    }
  }
}
