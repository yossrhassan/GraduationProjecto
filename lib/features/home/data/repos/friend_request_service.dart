import 'package:graduation_project/core/utils/api_service.dart';
import 'package:graduation_project/core/utils/auth_manager.dart';
import 'package:graduation_project/features/home/data/models/friend_request_model.dart';

class FriendRequestService {
  final ApiService apiService;

  FriendRequestService(this.apiService);

  Future<String> sendFriendRequest({required int receiverId}) async {
    try {
      print(
          'FriendRequestService: Sending friend request to userId: $receiverId');

      final response = await apiService.post(
        endPoint: 'FriendRequest/friend-request/send?receiverId=$receiverId',
        data: {},
      );

      print('FriendRequestService: Response: $response');

      if (response is String) {
        return response;
      } else if (response is Map<String, dynamic>) {
        if (response['success'] == true) {
          return response['message'] ?? 'Friend request sent successfully!';
        } else {
          return response['message'] ?? 'Failed to send friend request';
        }
      }

      return 'Friend request sent successfully!';
    } catch (e) {
      print('FriendRequestService Error: $e');

      String errorMessage = e.toString().toLowerCase();

      if (errorMessage.contains('friend request already exists') ||
          errorMessage.contains('already exists between') ||
          errorMessage.contains('already sent') ||
          errorMessage.contains('duplicate request') ||
          errorMessage.contains('400')) {
        return 'A friend request already exists between you and this user';
      } else if (errorMessage.contains('404')) {
        return 'User not found';
      } else if (errorMessage.contains('401') || errorMessage.contains('403')) {
        return 'Authentication error. Please login again.';
      } else if (errorMessage.contains('500')) {
        return 'Server error. Please try again later.';
      }

      return 'Failed to send friend request. Please try again.';
    }
  }

  Future<String> acceptFriendRequest({required int requestId}) async {
    try {
      print('FriendRequestService: Accepting friend request ID: $requestId');

      print('FriendRequestService: Using query parameter approach');

      final response = await apiService.post(
        endPoint: 'FriendRequest/friend-request/accept?requestId=$requestId',
        data: {},
      );

      print('FriendRequestService Accept Response: $response');
      print(
          'FriendRequestService Accept Response Type: ${response.runtimeType}');

      if (response is String) {
        return response;
      } else if (response is Map<String, dynamic>) {
        if (response['success'] == true) {
          return response['message'] ?? 'Friend request accepted successfully!';
        } else {
          return response['message'] ?? 'Failed to accept friend request';
        }
      }

      return 'Friend request accepted successfully!';
    } catch (e) {
      print('FriendRequestService Accept Error: $e');
      print('FriendRequestService Accept Error Type: ${e.runtimeType}');
      return 'Failed to accept friend request. Please try again.';
    }
  }

  Future<String> rejectFriendRequest({required int requestId}) async {
    try {
      print('FriendRequestService: Rejecting friend request ID: $requestId');

      final response = await apiService.post(
        endPoint: 'FriendRequest/friend-request/reject?requestId=$requestId',
        data: {},
      );

      print('FriendRequestService Reject Response: $response');

      if (response is String) {
        return response;
      } else if (response is Map<String, dynamic>) {
        if (response['success'] == true) {
          return response['message'] ?? 'Friend request rejected successfully!';
        } else {
          return response['message'] ?? 'Failed to reject friend request';
        }
      }

      return 'Friend request rejected successfully!';
    } catch (e) {
      print('FriendRequestService Reject Error: $e');
      return 'Failed to reject friend request. Please try again.';
    }
  }

  Future<List<FriendRequestModel>> getReceivedFriendRequests() async {
    try {
      print('FriendRequestService: Getting received friend requests');

      final response = await apiService.get(
        endPoint: 'FriendRequest/friend-requests/received',
      );

      print('FriendRequestService Received Response: $response');

      if (response is Map<String, dynamic>) {
        if (response['success'] == true && response['data'] is List) {
          final List<dynamic> data = response['data'];
          return data.map((item) => FriendRequestModel.fromJson(item)).toList();
        }
      } else if (response is List) {
        return response
            .map((item) => FriendRequestModel.fromJson(item))
            .toList();
      }

      return [];
    } catch (e) {
      print('FriendRequestService Received Error: $e');
      return [];
    }
  }

  Future<List<FriendRequestModel>> getSentFriendRequests() async {
    try {
      print('FriendRequestService: Getting sent friend requests');

      final response = await apiService.get(
        endPoint: 'FriendRequest/friend-requests/sent',
      );

      print('FriendRequestService Sent Response: $response');

      if (response is Map<String, dynamic>) {
        if (response['success'] == true && response['data'] is List) {
          final List<dynamic> data = response['data'];
          return data.map((item) => FriendRequestModel.fromJson(item)).toList();
        }
      } else if (response is List) {
        return response
            .map((item) => FriendRequestModel.fromJson(item))
            .toList();
      }

      return [];
    } catch (e) {
      print('FriendRequestService Sent Error: $e');
      return [];
    }
  }

  Future<List<FriendRequestModel>> getPendingFriendRequests() async {
    try {
      print('FriendRequestService: Getting pending friend requests');

      final response = await apiService.get(
        endPoint: 'FriendRequest/friend-requests/pending',
      );

      print('FriendRequestService Pending Response: $response');

      if (response is Map<String, dynamic>) {
        if (response['success'] == true && response['data'] is List) {
          final List<dynamic> data = response['data'];
          return data.map((item) => FriendRequestModel.fromJson(item)).toList();
        }
      } else if (response is List) {
        return response
            .map((item) => FriendRequestModel.fromJson(item))
            .toList();
      }

      return [];
    } catch (e) {
      print('FriendRequestService Pending Error: $e');
      return [];
    }
  }

  Future<List<FriendRequestModel>> getAcceptedFriendRequests() async {
    try {
      print('FriendRequestService: Getting accepted friend requests');

      final response = await apiService.get(
        endPoint: 'FriendRequest/friend-requests/accepted',
      );

      print('FriendRequestService Accepted Response: $response');

      if (response is Map<String, dynamic>) {
        if (response['success'] == true && response['data'] is List) {
          final List<dynamic> data = response['data'];
          return data.map((item) => FriendRequestModel.fromJson(item)).toList();
        }
      } else if (response is List) {
        return response
            .map((item) => FriendRequestModel.fromJson(item))
            .toList();
      }

      return [];
    } catch (e) {
      print('FriendRequestService Accepted Error: $e');
      return [];
    }
  }
}
