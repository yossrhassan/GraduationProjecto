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

final getIt = GetIt.instance;

void setup() {
  // Register API service
  getIt.registerSingleton<ApiService>(ApiService(Dio()));

  // Register repositories
  getIt.registerSingleton<FacilitiesRepoImpl>(
      FacilitiesRepoImpl(getIt.get<ApiService>()));
  getIt
      .registerSingleton<BookingRepo>(BookingRepoImpl(getIt.get<ApiService>()));
  getIt.registerSingleton<BookingHistoryRepo>(
      BookingHistoryRepoImpl(getIt.get<ApiService>()));

      getIt.registerSingleton<CourtsRepo>(CourtsRepoImpl(getIt.get<ApiService>()));
}
