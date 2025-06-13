import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:graduation_project/core/utils/api.dart';
import 'package:graduation_project/core/utils/api_service.dart';
import 'package:graduation_project/features/booking/data/repos/booking_repo.dart';
import 'package:graduation_project/features/booking/data/repos/booking_repo_impl.dart';
import 'package:graduation_project/features/booking/data/repos/courts_repo.dart';
import 'package:graduation_project/features/booking/data/repos/courts_repo_impl.dart';
import 'package:graduation_project/features/booking_history/data/repos/booking_history_repo.dart';
import 'package:graduation_project/features/booking_history/data/repos/booking_history_repo_impl.dart';
import 'package:graduation_project/features/facilities/data/repos/facilities_repo_impl.dart';
import 'package:graduation_project/features/player_matching/data/repos/matches_repo.dart';
import 'package:graduation_project/features/player_matching/data/repos/matches_repo_impl.dart';
import 'package:graduation_project/features/player_matching/presentation/manager/match_cubit/match_cubit.dart';
import 'package:graduation_project/features/settings/data/repos/settings_repo.dart';
import 'package:graduation_project/features/settings/data/repos/user_service.dart';
import 'package:graduation_project/features/settings/data/repos/delete_account_service.dart';
import 'package:graduation_project/features/home/data/repos/friend_request_service.dart';
import 'package:graduation_project/features/chat_bot/data/repos/chat_repo.dart';
import 'package:graduation_project/features/home/presentation/manager/friend_requests_cubit.dart';

final getIt = GetIt.instance;

void setup() {
  // Register API service
  getIt.registerSingleton<ApiService>(ApiService(Dio()));

  // Register repositories
  getIt.registerSingleton<MatchesRepository>(
      MatchesRepositoryImpl(getIt.get<ApiService>()));

  getIt.registerSingleton<FacilitiesRepoImpl>(
      FacilitiesRepoImpl(getIt.get<ApiService>()));

  getIt
      .registerSingleton<BookingRepo>(BookingRepoImpl(getIt.get<ApiService>()));

  getIt.registerSingleton<BookingHistoryRepo>(
      BookingHistoryRepoImpl(getIt.get<ApiService>()));

  getIt.registerSingleton<CourtsRepo>(CourtsRepoImpl(getIt.get<ApiService>()));

  // Register chat repository
  getIt.registerSingleton<ChatRepo>(ChatRepoImpl());

  // Register settings services
  getIt.registerSingleton<UserService>(UserService(getIt.get<ApiService>()));
  getIt.registerSingleton<SettingsRepo>(SettingsRepo(getIt.get<UserService>()));
  getIt.registerSingleton<DeleteAccountService>(
      DeleteAccountService(getIt.get<ApiService>()));
  getIt.registerSingleton<FriendRequestService>(
      FriendRequestService(getIt.get<ApiService>()));

  // Register cubits that need to be globally accessible
  getIt.registerSingleton<MatchesCubit>(
      MatchesCubit(getIt.get<MatchesRepository>()));
  getIt.registerSingleton<FriendRequestsCubit>(
      FriendRequestsCubit(getIt.get<FriendRequestService>()));
}
