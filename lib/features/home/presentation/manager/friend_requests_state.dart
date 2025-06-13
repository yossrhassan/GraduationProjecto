part of 'friend_requests_cubit.dart';

@immutable
sealed class FriendRequestsState {}

final class FriendRequestsInitial extends FriendRequestsState {}

final class FriendRequestsLoading extends FriendRequestsState {}

final class FriendRequestsLoaded extends FriendRequestsState {
  final List<FriendRequestModel> receivedRequests;

  FriendRequestsLoaded(this.receivedRequests);
}

final class FriendRequestsError extends FriendRequestsState {
  final String message;

  FriendRequestsError(this.message);
}
