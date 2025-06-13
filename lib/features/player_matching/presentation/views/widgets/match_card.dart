import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class MatchCard extends StatelessWidget {
  const MatchCard({
    super.key,
    required this.time,
    required this.location,
    required this.players,
    required this.status,
    required this.onTap,
    this.isCreator = false,
    this.hasJoinedTeam = false,
  });

  final String time;
  final String location;
  final String players;
  final String status;
  final VoidCallback onTap;
  final bool isCreator;
  final bool hasJoinedTeam;

  String _formatDateTime(DateTime dateTime) {
    return DateFormat('MMM d, y • h:mm a').format(dateTime);
  }

  @override
  Widget build(BuildContext context) {
    // Status display and color logic
    String displayStatus;
    Color statusColor;
    Color cardBackgroundColor = Colors.white; // Default card background
    bool hasBorder = false;

    // Check if match is cancelled first (highest priority)
    if (status.toLowerCase() == 'cancelled') {
      displayStatus = 'CANCELLED';
      statusColor = Colors.white; // White text on red background
      cardBackgroundColor =
          const Color(0xFFFFEBEE); // Light red background for card
    } else if (isCreator) {
      displayStatus = 'CREATED';
      statusColor = const Color(0xFF00A36C); // Green for created
    } else if (status.toLowerCase() == 'joined') {
      displayStatus = 'JOINED';
      statusColor = const Color(0xFF2196F3); // Blue for joined
    } else {
      displayStatus = status.toUpperCase();
      statusColor = Colors.transparent;
      hasBorder = true;
    }

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: cardBackgroundColor,
          borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 20.0),
        margin: const EdgeInsets.only(bottom: 8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  flex: 3,
                  child: Text(
                    time,
                    style: const TextStyle(
                      color: Colors.black,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 2),
                Expanded(
                  flex: 1,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.people,
                        size: 18,
                        color: Colors.black54,
                      ),
                      const SizedBox(width: 4),
                      Flexible(
                        child: Text(
                          players,
                          style: const TextStyle(
                            color: Colors.black54,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: status.toLowerCase() == 'cancelled'
                        ? const Color(
                            0xFFD32F2F) // Red background for cancelled
                        : statusColor,
                    borderRadius: BorderRadius.circular(4),
                    border:
                        hasBorder ? Border.all(color: Colors.black38) : null,
                  ),
                  child: Text(
                    displayStatus,
                    style: TextStyle(
                      color: hasBorder ? Colors.black54 : Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              location,
              style: const TextStyle(
                color: Colors.black54,
                fontSize: 16,
              ),
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
          ],
        ),
      ),
    );
  }
}
