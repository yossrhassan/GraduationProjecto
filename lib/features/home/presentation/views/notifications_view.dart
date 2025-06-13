import 'package:flutter/material.dart';
import 'package:graduation_project/constants.dart';
import 'package:graduation_project/features/home/data/models/friend_request_model.dart';
import 'package:graduation_project/features/home/data/repos/friend_request_service.dart';
import 'package:graduation_project/core/utils/service_locator.dart';
import 'package:graduation_project/core/utils/auth_manager.dart';

class NotificationsView extends StatefulWidget {
  const NotificationsView({super.key});

  @override
  State<NotificationsView> createState() => _NotificationsViewState();
}

class _NotificationsViewState extends State<NotificationsView>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<FriendRequestModel> receivedRequests = [];
  List<FriendRequestModel> sentRequests = [];
  List<FriendRequestModel> acceptedRequests = [];
  bool isLoading = true;
  late FriendRequestService friendRequestService;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    friendRequestService = getIt<FriendRequestService>();
    _loadFriendRequests();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadFriendRequests() async {
    setState(() {
      isLoading = true;
    });

    try {
      final results = await Future.wait([
        friendRequestService.getReceivedFriendRequests(),
        friendRequestService.getSentFriendRequests(),
        friendRequestService.getAcceptedFriendRequests(),
      ]);

      setState(() {
        receivedRequests = results[0];
        sentRequests = results[1];
        acceptedRequests = results[2];
        isLoading = false;
      });
    } catch (e) {
      print('Error loading friend requests: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _acceptFriendRequest(int requestId, int index) async {
    try {
      print(
          '🔄 NotificationsView: Starting to accept friend request ID: $requestId');

      final result = await friendRequestService.acceptFriendRequest(
        requestId: requestId,
      );

      print('✅ NotificationsView: Accept result: $result');

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result),
            backgroundColor: Colors.green,
          ),
        );

        setState(() {
          receivedRequests.removeAt(index);
        });

        print('🔄 NotificationsView: Reloading friend requests after accept');
        _loadFriendRequests();
      }
    } catch (e) {
      print('❌ NotificationsView: Error accepting request: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error accepting request: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _rejectFriendRequest(int requestId, int index) async {
    try {
      final result = await friendRequestService.rejectFriendRequest(
        requestId: requestId,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result),
            backgroundColor: Colors.orange,
          ),
        );

        setState(() {
          receivedRequests.removeAt(index);
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error rejecting request: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackGroundColor,
      appBar: AppBar(
        backgroundColor: kBackGroundColor,
        elevation: 0,
        title: const Text(
          'Friends',
          style: TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.bold,
            color: kPrimaryColor,
          ),
        ),
        iconTheme: const IconThemeData(color: kPrimaryColor),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: kPrimaryColor,
          labelColor: kPrimaryColor,
          unselectedLabelColor: Colors.grey,
          tabs: [
            Tab(
              text: 'Received (${receivedRequests.length})',
              icon: const Icon(Icons.inbox),
            ),
            Tab(
              text: 'Sent (${sentRequests.length})',
              icon: const Icon(Icons.outbox),
            ),
            Tab(
              text: 'Friends (${acceptedRequests.length})',
              icon: const Icon(Icons.people),
            ),
          ],
        ),
      ),
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(kPrimaryColor),
              ),
            )
          : TabBarView(
              controller: _tabController,
              children: [
                _buildReceivedRequestsList(),
                _buildSentRequestsList(),
                _buildAcceptedRequestsList(),
              ],
            ),
    );
  }

  Widget _buildReceivedRequestsList() {
    if (receivedRequests.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.inbox_outlined, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text('No pending friend requests',
                style: TextStyle(fontSize: 18, color: Colors.grey)),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadFriendRequests,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: receivedRequests.length,
        itemBuilder: (context, index) {
          final request = receivedRequests[index];
          return _buildReceivedRequestCard(request, index);
        },
      ),
    );
  }

  Widget _buildSentRequestsList() {
    if (sentRequests.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.outbox_outlined, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text('No sent friend requests',
                style: TextStyle(fontSize: 18, color: Colors.grey)),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadFriendRequests,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: sentRequests.length,
        itemBuilder: (context, index) {
          final request = sentRequests[index];
          return _buildSentRequestCard(request);
        },
      ),
    );
  }

  Widget _buildAcceptedRequestsList() {
    if (acceptedRequests.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.people_outline, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text('No friends yet',
                style: TextStyle(fontSize: 18, color: Colors.grey)),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadFriendRequests,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: acceptedRequests.length,
        itemBuilder: (context, index) {
          final request = acceptedRequests[index];
          return _buildAcceptedRequestCard(request);
        },
      ),
    );
  }

  Widget _buildReceivedRequestCard(FriendRequestModel request, int index) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: kPrimaryColor.withOpacity(0.1),
                  child: Text(
                    request.senderName.isNotEmpty
                        ? request.senderName[0].toUpperCase()
                        : '?',
                    style: const TextStyle(
                        color: kPrimaryColor, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(request.senderName,
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 16)),
                      if (request.senderEmail != null)
                        Text(request.senderEmail!,
                            style: TextStyle(
                                color: Colors.grey[600], fontSize: 14)),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _acceptFriendRequest(request.id, index),
                    icon: const Icon(Icons.check, color: Colors.white),
                    label: const Text('Accept'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8)),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _rejectFriendRequest(request.id, index),
                    icon: const Icon(Icons.close, color: Colors.white),
                    label: const Text('Reject'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8)),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSentRequestCard(FriendRequestModel request) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: kPrimaryColor.withOpacity(0.1),
              child: Text(
                request.receiverName.isNotEmpty
                    ? request.receiverName[0].toUpperCase()
                    : '?',
                style: const TextStyle(
                    color: kPrimaryColor, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(request.receiverName,
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 16)),
                  if (request.receiverEmail != null)
                    Text(request.receiverEmail!,
                        style:
                            TextStyle(color: Colors.grey[600], fontSize: 14)),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.orange.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Text('Pending',
                  style: TextStyle(
                      color: Colors.orange,
                      fontWeight: FontWeight.bold,
                      fontSize: 12)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAcceptedRequestCard(FriendRequestModel request) {
    // Determine which user is the friend (not the current user)
    final currentUserId = AuthManager.userId;
    final friendName = currentUserId == request.senderId
        ? request.receiverName
        : request.senderName;
    final friendEmail = currentUserId == request.senderId
        ? request.receiverEmail
        : request.senderEmail;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: kPrimaryColor.withOpacity(0.1),
              child: Text(
                friendName.isNotEmpty ? friendName[0].toUpperCase() : '?',
                style: const TextStyle(
                    color: kPrimaryColor, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(friendName,
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 16)),
                  if (friendEmail != null)
                    Text(friendEmail!,
                        style:
                            TextStyle(color: Colors.grey[600], fontSize: 14)),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Text('Friends',
                  style: TextStyle(
                      color: Colors.green,
                      fontWeight: FontWeight.bold,
                      fontSize: 12)),
            ),
          ],
        ),
      ),
    );
  }
}
