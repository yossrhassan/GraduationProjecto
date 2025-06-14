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

    Navigator.of(context).pop();

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
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.white30,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 24),
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
          if (widget.isMatchCreator &&
              widget.onKickPlayer != null &&
              !widget.isCaptain)
            Column(
              children: [
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: isKicking ? null : _kickPlayer,
                    icon: const Icon(Icons.person_remove, color: Colors.white),
                    label: Text(
                      isKicking ? 'Kicking...' : 'Kick Player',
                      style: const TextStyle(color: Colors.white),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 16,
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
