import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:graduation_project/constants.dart';
import 'package:graduation_project/features/player_matching/data/models/player_model.dart';
import 'package:graduation_project/features/settings/data/models/user_model.dart';
import 'package:graduation_project/features/settings/data/repos/user_service.dart';
import 'package:graduation_project/core/utils/service_locator.dart';
import 'package:graduation_project/core/utils/auth_manager.dart';
import 'package:graduation_project/core/utils/show_snack_bar.dart';
import 'package:graduation_project/features/home/data/repos/friend_request_service.dart';
import 'package:graduation_project/features/home/data/models/friend_request_model.dart';

class PlayerProfileView extends StatefulWidget {
  final PlayerModel player;
  final bool isCaptain;

  const PlayerProfileView({
    super.key,
    required this.player,
    required this.isCaptain,
  });

  @override
  State<PlayerProfileView> createState() => _PlayerProfileViewState();
}

class _PlayerProfileViewState extends State<PlayerProfileView> {
  UserModel? userDetails;
  bool isLoading = true;
  bool isSendingFriendRequest = false;
  bool isAlreadyFriend = false;

  @override
  void initState() {
    super.initState();
    _loadUserDetails();
    _checkFriendshipStatus();
  }

  Future<void> _loadUserDetails() async {
    try {
      final userService = getIt<UserService>();
      final userData = await userService.getUserProfile(widget.player.userId);
      setState(() {
        userDetails = userData;
        isLoading = false;
      });
    } catch (e) {
      print('Error loading user details: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _checkFriendshipStatus() async {
    try {
      final friendRequestService = getIt<FriendRequestService>();
      final acceptedRequests =
          await friendRequestService.getAcceptedFriendRequests();

      if (mounted) {
        setState(() {
          isAlreadyFriend = acceptedRequests.any((request) =>
              (request.senderId == widget.player.userId ||
                  request.receiverId == widget.player.userId));
        });
      }
    } catch (e) {
      print('Error checking friendship status: $e');
    }
  }

  Future<void> _sendFriendRequest() async {
    if (isSendingFriendRequest) return;

    setState(() {
      isSendingFriendRequest = true;
    });

    try {
      final friendRequestService = getIt<FriendRequestService>();
      final result = await friendRequestService.sendFriendRequest(
        receiverId: widget.player.userId,
      );

      if (mounted) {
        Color snackBarColor;
        IconData snackBarIcon;

        if (result.contains('A friend request already sent to this user')) {
          snackBarColor = Colors.red;
          snackBarIcon = Icons.error_outline;
        } else if (result.contains('sent successfully') ||
            result.contains('Friend request sent')) {
          snackBarColor = Colors.green;
          snackBarIcon = Icons.check_circle_outline;
        } else {
          snackBarColor = Colors.red;
          snackBarIcon = Icons.error_outline;
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(snackBarIcon, color: Colors.white),
                const SizedBox(width: 8),
                Expanded(child: Text(result)),
              ],
            ),
            backgroundColor: snackBarColor,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error_outline, color: Colors.white),
                const SizedBox(width: 8),
                Expanded(child: Text('Error: ${e.toString()}')),
              ],
            ),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          isSendingFriendRequest = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => GoRouter.of(context).pop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.more_vert, color: Colors.white),
            onPressed: () {},
          ),
        ],
      ),
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            )
          : Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Player Avatar
                  Stack(
                    children: [
                      Container(
                        width: 150,
                        height: 150,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white,
                          border: Border.all(color: Colors.white, width: 4),
                        ),
                        child: ClipOval(
                          child: Container(
                            color: Colors.grey.shade600,
                            child: const Icon(
                              Icons.person,
                              size: 80,
                              color: Colors.white54,
                            ),
                          ),
                        ),
                      ),
                      if (widget.isCaptain)
                        Positioned(
                          bottom: 10,
                          right: 10,
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: const BoxDecoration(
                              color: Colors.amber,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.star,
                              size: 24,
                              color: Colors.white,
                            ),
                          ),
                        ),
                    ],
                  ),

                  const SizedBox(height: 30),

                  Text(
                    widget.player.userName.isNotEmpty
                        ? widget.player.userName
                        : 'Player',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 8),

                  if (widget.isCaptain)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.amber,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Text(
                        'CAPTAIN',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1,
                        ),
                      ),
                    ),

                  const SizedBox(height: 20),

                  if (userDetails?.phoneNumber?.isNotEmpty == true)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 10),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(25),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.phone,
                            color: Colors.white70,
                            size: 16,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            userDetails!.phoneNumber,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    ),

                  const Spacer(),

                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 40),
                    child: SizedBox(
                      width: double.infinity,
                      child: isAlreadyFriend
                          ? ElevatedButton.icon(
                              onPressed: null,
                              icon: const Icon(Icons.check_circle,
                                  color: Colors.green),
                              label: const Text(
                                'Friends',
                                style: TextStyle(
                                  color: Colors.green,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.white,
                                padding:
                                    const EdgeInsets.symmetric(vertical: 15),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(25),
                                ),
                                elevation: 0,
                              ),
                            )
                          : ElevatedButton.icon(
                              onPressed: isSendingFriendRequest
                                  ? null
                                  : _sendFriendRequest,
                              icon: isSendingFriendRequest
                                  ? const SizedBox(
                                      width: 16,
                                      height: 16,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        valueColor:
                                            AlwaysStoppedAnimation<Color>(
                                                Colors.black),
                                      ),
                                    )
                                  : const Icon(Icons.person_add,
                                      color: Colors.black),
                              label: Text(
                                isSendingFriendRequest
                                    ? 'Sending...'
                                    : 'Add as a Friend',
                                style: TextStyle(
                                  color: isSendingFriendRequest
                                      ? Colors.grey
                                      : Colors.black,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.white,
                                padding:
                                    const EdgeInsets.symmetric(vertical: 15),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(25),
                                ),
                                elevation: 0,
                              ),
                            ),
                    ),
                  ),

                  const SizedBox(height: 40),
                ],
              ),
            ),
    );
  }
}
