import 'package:bloc/bloc.dart';
import 'package:graduation_project/features/home/data/models/friend_request_model.dart';
import 'package:graduation_project/features/home/data/repos/friend_request_service.dart';
import 'package:meta/meta.dart';

part 'friend_requests_state.dart';

class FriendRequestsCubit extends Cubit<FriendRequestsState> {
  final FriendRequestService friendRequestService;

  FriendRequestsCubit(this.friendRequestService)
      : super(FriendRequestsInitial());

  Future<void> loadReceivedFriendRequests() async {
    try {
      emit(FriendRequestsLoading());
      final receivedRequests =
          await friendRequestService.getReceivedFriendRequests();
      emit(FriendRequestsLoaded(receivedRequests));
    } catch (e) {
      print('Error loading friend requests: $e');
      emit(FriendRequestsError(e.toString()));
    }
  }

  int get receivedRequestsCount {
    if (state is FriendRequestsLoaded) {
      return (state as FriendRequestsLoaded).receivedRequests.length;
    }
    return 0;
  }
}
