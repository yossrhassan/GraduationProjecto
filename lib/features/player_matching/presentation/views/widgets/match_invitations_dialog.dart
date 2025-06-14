import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:graduation_project/constants.dart';
import 'package:graduation_project/features/player_matching/data/models/match_model.dart';
import 'package:graduation_project/features/player_matching/data/models/match_invitation_model.dart';
import 'package:graduation_project/features/player_matching/presentation/manager/match_cubit/match_cubit.dart';
import 'package:graduation_project/features/player_matching/presentation/manager/match_cubit/match_state.dart';
import 'package:intl/intl.dart';

class MatchInvitationsDialog extends StatefulWidget {
  const MatchInvitationsDialog({super.key});

  @override
  State<MatchInvitationsDialog> createState() => _MatchInvitationsDialogState();
}

class _MatchInvitationsDialogState extends State<MatchInvitationsDialog> {
  Set<int> respondingInvitations =
      {}; // Track which invitations are being responded to

  String _formatTime(String time24) {
    try {
      // Parse time in HH:mm:ss format
      final timeParts = time24.split(':');
      if (timeParts.length >= 2) {
        int hour = int.parse(timeParts[0]);
        final minute = timeParts[1];

        String period = 'AM';
        if (hour == 0) {
          hour = 12; // Midnight
        } else if (hour == 12) {
          period = 'PM'; // Noon
        } else if (hour > 12) {
          hour = hour - 12;
          period = 'PM';
        }

        return '$hour:$minute $period';
      }
    } catch (e) {
      // If parsing fails, return the original time
      return time24;
    }
    return time24;
  }

  @override
  void initState() {
    super.initState();
    // Load invitations when dialog opens
    context.read<MatchesCubit>().getMatchInvitations();
  }

  Future<void> _respondToInvitation(
      MatchInvitationModel invitation, bool accept) async {
    setState(() {
      respondingInvitations.add(invitation.matchId);
    });

    try {
      // Call the cubit method and wait for it to complete
      await context
          .read<MatchesCubit>()
          .respondToInvitation(invitation.matchId.toString(), accept);

      // Show success message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(
                  accept ? Icons.check_circle : Icons.cancel,
                  color: Colors.white,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    accept
                        ? 'Invitation accepted successfully!'
                        : 'Invitation declined successfully!',
                  ),
                ),
              ],
            ),
            backgroundColor: accept ? Colors.green : Colors.orange,
          ),
        );
      }

      // No need to refresh manually - the cubit handles state update optimistically
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content:
                Text('Failed to ${accept ? 'accept' : 'decline'} invitation'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      // Remove button loading state
      if (mounted) {
        setState(() {
          respondingInvitations.remove(invitation.matchId);
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.8,
          maxWidth: MediaQuery.of(context).size.width * 0.9,
        ),
        decoration: BoxDecoration(
          color: kBackGroundColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: kPrimaryColor, width: 2),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: kPrimaryColor,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(14),
                  topRight: Radius.circular(14),
                ),
              ),
              child: Row(
                children: [
                  const Icon(Icons.mail, color: Colors.white, size: 24),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      'Match Invitations',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close, color: Colors.white),
                  ),
                ],
              ),
            ),

            // Content
            Flexible(
              child: BlocBuilder<MatchesCubit, MatchesState>(
                builder: (context, state) {
                  // If we have a loaded state with empty invitations, show no invitations message
                  if (state is MatchInvitationsLoaded &&
                      state.invitations.isEmpty) {
                    return const Padding(
                      padding: EdgeInsets.all(40),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.mail_outline,
                            size: 64,
                            color: Colors.white54,
                          ),
                          SizedBox(height: 16),
                          Text(
                            'No pending invitations',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            'You\'ll see match invitations from friends here!',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 14,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    );
                  }

                  // Handle error state
                  if (state is MatchesError) {
                    return Padding(
                      padding: const EdgeInsets.all(40),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.error_outline,
                            size: 64,
                            color: Colors.red,
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            'Error loading invitations',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            state.message,
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 14,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 24),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              TextButton.icon(
                                onPressed: () => Navigator.of(context).pop(),
                                icon: const Icon(Icons.close,
                                    color: Colors.white70),
                                label: const Text(
                                  'Close',
                                  style: TextStyle(color: Colors.white70),
                                ),
                              ),
                              ElevatedButton.icon(
                                onPressed: () {
                                  context
                                      .read<MatchesCubit>()
                                      .getMatchInvitations();
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: kPrimaryColor,
                                  foregroundColor: Colors.white,
                                ),
                                icon: const Icon(Icons.refresh),
                                label: const Text('Retry'),
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  }

                  // Handle loaded state with invitations
                  if (state is MatchInvitationsLoaded) {
                    // Use invitations directly from state
                    final invitations = state.invitations;

                    // If no invitations, show empty state
                    if (invitations.isEmpty) {
                      return const Padding(
                        padding: EdgeInsets.all(40),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.mail_outline,
                              size: 64,
                              color: Colors.white54,
                            ),
                            SizedBox(height: 16),
                            Text(
                              'No pending invitations',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 8),
                            Text(
                              'You\'ll see match invitations from friends here!',
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 14,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      );
                    }

                    return RefreshIndicator(
                      color: kPrimaryColor,
                      onRefresh: () async {
                        context.read<MatchesCubit>().getMatchInvitations();
                        // Wait a bit for the API call to complete
                        await Future.delayed(const Duration(milliseconds: 500));
                      },
                      child: ListView.builder(
                        shrinkWrap: true,
                        padding: const EdgeInsets.all(16),
                        itemCount: invitations.length,
                        itemBuilder: (context, index) {
                          final invitation = invitations[index];
                          final isResponding = respondingInvitations
                              .contains(invitation.matchId);

                          return Container(
                            margin: const EdgeInsets.only(bottom: 16),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: Colors.white.withOpacity(0.2),
                              ),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Match info
                                  Row(
                                    children: [
                                      const Icon(
                                        Icons.sports_soccer,
                                        color: kPrimaryColor,
                                        size: 20,
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          invitation.sportName,
                                          style: const TextStyle(
                                            color: kPrimaryColor,
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),

                                  // Location
                                  Row(
                                    children: [
                                      const Icon(
                                        Icons.location_on,
                                        color: Colors.white70,
                                        size: 16,
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          invitation.matchTitle,
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 14,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),

                                  // Facility name
                                  if (invitation.facilityName.isNotEmpty) ...[
                                    Row(
                                      children: [
                                        const Icon(
                                          Icons.sports_tennis,
                                          color: Colors.white70,
                                          size: 16,
                                        ),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: Text(
                                            invitation.facilityName,
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 14,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 8),
                                  ],

                                  // Booking time
                                  if (invitation.bookingStartTime.isNotEmpty &&
                                      invitation.bookingEndTime.isNotEmpty) ...[
                                    Row(
                                      children: [
                                        const Icon(
                                          Icons.access_time,
                                          color: Colors.white70,
                                          size: 16,
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          '${_formatTime(invitation.bookingStartTime)} - ${_formatTime(invitation.bookingEndTime)}',
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 14,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 8),
                                  ],

                                  // Inviter info
                                  Row(
                                    children: [
                                      const Icon(
                                        Icons.person,
                                        color: Colors.white70,
                                        size: 16,
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        'Invited by ${invitation.inviterName}',
                                        style: const TextStyle(
                                          color: Colors.white70,
                                          fontSize: 14,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 16),

                                  // Action buttons
                                  Row(
                                    children: [
                                      Expanded(
                                        child: ElevatedButton(
                                          onPressed: isResponding
                                              ? null
                                              : () => _respondToInvitation(
                                                  invitation, false),
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.grey[600],
                                            foregroundColor: Colors.white,
                                            padding: const EdgeInsets.symmetric(
                                                vertical: 12),
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                            ),
                                          ),
                                          child: isResponding
                                              ? const SizedBox(
                                                  width: 16,
                                                  height: 16,
                                                  child:
                                                      CircularProgressIndicator(
                                                    strokeWidth: 2,
                                                    valueColor:
                                                        AlwaysStoppedAnimation<
                                                            Color>(
                                                      Colors.white,
                                                    ),
                                                  ),
                                                )
                                              : const Text(
                                                  'Decline',
                                                  style: TextStyle(
                                                    fontSize: 14,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: ElevatedButton(
                                          onPressed: isResponding
                                              ? null
                                              : () => _respondToInvitation(
                                                  invitation, true),
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: kPrimaryColor,
                                            foregroundColor: Colors.white,
                                            padding: const EdgeInsets.symmetric(
                                                vertical: 12),
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                            ),
                                          ),
                                          child: isResponding
                                              ? const SizedBox(
                                                  width: 16,
                                                  height: 16,
                                                  child:
                                                      CircularProgressIndicator(
                                                    strokeWidth: 2,
                                                    valueColor:
                                                        AlwaysStoppedAnimation<
                                                            Color>(
                                                      Colors.white,
                                                    ),
                                                  ),
                                                )
                                              : const Text(
                                                  'Accept',
                                                  style: TextStyle(
                                                    fontSize: 14,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    );
                  }

                  // Default loading state
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(40),
                      child: CircularProgressIndicator(color: kPrimaryColor),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
