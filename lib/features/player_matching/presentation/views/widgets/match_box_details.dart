import 'package:flutter/material.dart';
import 'package:graduation_project/features/player_matching/data/models/match_model.dart';
import 'package:intl/intl.dart';

class MatchBoxDetails extends StatelessWidget {
  final MatchModel match;

  const MatchBoxDetails({super.key, required this.match});

  String _formatTime(String startTime, String endTime) {
    try {
      if (startTime.isNotEmpty && endTime.isNotEmpty) {
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
      }
      return 'Time not set';
    } catch (e) {
      return 'Time not set';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.green.shade800,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Match Details',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),

          Row(
            children: [
              const Icon(
                Icons.location_on,
                color: Colors.white70,
                size: 18,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  match.title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Time
          Row(
            children: [
              const Icon(
                Icons.access_time,
                color: Colors.white70,
                size: 18,
              ),
              const SizedBox(width: 8),
              Text(
                _formatTime(match.startTime, match.endTime),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          Row(
            children: [
              const Icon(
                Icons.people,
                color: Colors.white70,
                size: 18,
              ),
              const SizedBox(width: 8),
              Text(
                '${match.players?.length ?? 0}/${match.teamSize * 2} Players',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          Row(
            children: [
              const Icon(
                Icons.sports_soccer,
                color: Colors.white70,
                size: 18,
              ),
              const SizedBox(width: 8),
              Text(
                match.sportName,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                ),
              ),
            ],
          ),

          if (match.description.isNotEmpty) ...[
            const SizedBox(height: 8),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(
                  Icons.description,
                  color: Colors.white70,
                  size: 18,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    match.description,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
